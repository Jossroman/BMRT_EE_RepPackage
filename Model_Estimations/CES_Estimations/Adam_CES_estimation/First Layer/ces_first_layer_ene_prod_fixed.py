# -*- coding: utf-8 -*-
"""
Created on Thu Sep 12 16:50:44 2024

ces_first_layer_ene_prod
"""

import tensorflow as tf
import pandas as pd
import numpy as np
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
import os

# ============================================================
# Initial parameter guesses
# ============================================================

beta_k_guess = 0.25
beta_ene_guess = 0.20
beta_hc_guess = 0.55
rho_guess = 1.20

mu_k_init = np.log(beta_k_guess) - np.log(1 - beta_k_guess)
mu_ene_init = np.log(beta_ene_guess) - np.log(1 - beta_ene_guess)
lambda_init = np.log(1 + rho_guess)


# ============================================================
# CES model
# ============================================================

class CESModel(tf.Module):
    def __init__(self):
        self.gamma = tf.Variable(0.3850, dtype=tf.float32, trainable=True)

        self.mu_k = tf.Variable(mu_k_init, dtype=tf.float32, trainable=True)
        self.mu_ene = tf.Variable(mu_ene_init, dtype=tf.float32, trainable=True)

        self.lambda_ = tf.Variable(lambda_init, dtype=tf.float32, trainable=True)

    def _logit_inverse(self, mu):
        return 1 / (1 + tf.exp(-mu))

    def _rho_from_lambda(self, lambda_):
        return tf.exp(lambda_) - 1

    def get_beta_values(self):
        beta_k = self._logit_inverse(self.mu_k).numpy()
        beta_ene = self._logit_inverse(self.mu_ene).numpy()
        beta_hc = 1 - beta_k - beta_ene

        return {
            "beta_k": beta_k,
            "beta_ene": beta_ene,
            "beta_hc": beta_hc
        }

    def __call__(self, x_k, x_ene, x_hc):
        beta_k = self._logit_inverse(self.mu_k)
        beta_ene = self._logit_inverse(self.mu_ene)
        beta_hc = 1 - beta_k - beta_ene

        rho = self._rho_from_lambda(self.lambda_)

        k = tf.pow(x_k, rho)
        ene = tf.pow(x_ene, rho)
        hc = tf.pow(x_hc, rho)

        ces = beta_k * k + beta_ene * ene + beta_hc * hc

        output = tf.math.log(self.gamma) + (1 / rho) * tf.math.log(ces)

        return output


# ============================================================
# Loss and optimizer
# ============================================================

def loss_function(y_true, y_pred):
    return tf.reduce_mean(tf.square(y_true - y_pred))


initial_learning_rate = 0.15
beta_1 = 0.9
beta_2 = 0.999
epsilon = 1e-7
decay_rate = 1e-3


def create_optimizer():
    return tf.optimizers.Adam(
        learning_rate=tf.keras.optimizers.schedules.ExponentialDecay(
            initial_learning_rate=initial_learning_rate,
            decay_steps=5000,
            decay_rate=decay_rate,
            staircase=False
        ),
        beta_1=beta_1,
        beta_2=beta_2,
        epsilon=epsilon
    )


def train_local_model(model, optimizer, x_k, x_ene, x_hc, y_true, n_epochs, label=""):
    for epoch in range(n_epochs):
        with tf.GradientTape() as tape:
            y_pred = model(x_k, x_ene, x_hc)
            loss = loss_function(y_true, y_pred)

        gradients = tape.gradient(loss, model.trainable_variables)
        optimizer.apply_gradients(zip(gradients, model.trainable_variables))

        if epoch % 1000 == 0:
            print(f"{label} Epoch {epoch}: Loss = {loss.numpy()}")

    return loss


def extract_results(model, loss=None, bootstrap_id=None):
    beta_values = model.get_beta_values()

    rho_estimated = model._rho_from_lambda(model.lambda_.numpy())
    theta = 1 / (1 - rho_estimated)

    result = {
        "gamma": model.gamma.numpy(),
        "lambda": model.lambda_.numpy(),
        "theta": theta.numpy() if hasattr(theta, "numpy") else theta,
        "beta_k": beta_values["beta_k"],
        "beta_ene": beta_values["beta_ene"],
        "beta_hc": beta_values["beta_hc"],
    }

    if loss is not None:
        result["loss"] = loss.numpy() if hasattr(loss, "numpy") else loss

    if bootstrap_id is not None:
        result["bootstrap_id"] = bootstrap_id

    return result


# ============================================================
# Load data
# ============================================================

df = pd.read_excel(
    r"C:\Users\adity\Dropbox\Adi-Simone-Ghassane\Natural Capital\CES ML Estimation\matlab_data_nomin_noene.xlsx"
)

x_k = df["pk_n"].values.astype(np.float32)
x_ene = df["ene_n"].values.astype(np.float32)
x_hc = df["hc_n"].values.astype(np.float32)
y_true = df["ln_gdp"].values.astype(np.float32)


# ============================================================
# Full-sample estimation
# ============================================================

MAIN_EPOCHS = 5000

model = CESModel()
optimizer = create_optimizer()

loss = train_local_model(
    model,
    optimizer,
    x_k,
    x_ene,
    x_hc,
    y_true,
    MAIN_EPOCHS,
    label="Full sample,"
)

full_sample_results = extract_results(model, loss=loss)

print("\nEstimated full-sample parameters:")
for key, value in full_sample_results.items():
    print(f"{key} = {value}")


# ============================================================
# Bootstrap estimation
# ============================================================

N_BOOTSTRAP_SAMPLES = 50
BOOTSTRAP_EPOCHS = 3000
N_WORKERS = max(1, os.cpu_count() - 1)


def run_bootstrap_iteration(task):
    df, i = task

    df_bootstrap = df.sample(frac=1, replace=True, random_state=i)

    x_k = df_bootstrap["pk_n"].values.astype(np.float32)
    x_ene = df_bootstrap["ene_n"].values.astype(np.float32)
    x_hc = df_bootstrap["hc_n"].values.astype(np.float32)
    y_true = df_bootstrap["ln_gdp"].values.astype(np.float32)

    bootstrap_model = CESModel()
    bootstrap_optimizer = create_optimizer()

    loss = train_local_model(
        bootstrap_model,
        bootstrap_optimizer,
        x_k,
        x_ene,
        x_hc,
        y_true,
        BOOTSTRAP_EPOCHS,
        label=f"Bootstrap {i},"
    )

    return extract_results(
        bootstrap_model,
        loss=loss,
        bootstrap_id=i
    )


tasks = [(df, i) for i in range(N_BOOTSTRAP_SAMPLES)]
bootstrap_results = []

with ThreadPoolExecutor(max_workers=N_WORKERS) as executor:
    futures = [executor.submit(run_bootstrap_iteration, task) for task in tasks]

    for future in as_completed(futures):
        result = future.result()
        bootstrap_results.append(result)
        print(f"Bootstrap iteration {result['bootstrap_id']} completed")


bootstrap_results = sorted(bootstrap_results, key=lambda x: x["bootstrap_id"])
bootstrap_df = pd.DataFrame(bootstrap_results)


# ============================================================
# Bootstrap summary
# ============================================================

parameters = ["gamma", "lambda", "theta", "beta_k", "beta_ene", "beta_hc"]

summary_rows = []

for parameter in parameters:
    summary_rows.append({
        "parameter": parameter,
        "full_sample_estimate": full_sample_results[parameter],
        "bootstrap_average": bootstrap_df[parameter].mean(),
        "bootstrap_standard_error": bootstrap_df[parameter].std(ddof=1)
    })

summary_df = pd.DataFrame(summary_rows)

print("\nBootstrap summary:")
print(summary_df)


# ============================================================
# Save results
# ============================================================

output_path = Path.cwd() / "ces_first_layer_ene_prod_results_fixed.xlsx"

with pd.ExcelWriter(output_path) as writer:
    summary_df.to_excel(writer, sheet_name="summary", index=False)
    bootstrap_df.to_excel(writer, sheet_name="bootstrap_draws", index=False)

print(f"\nSaved results to: {output_path}")