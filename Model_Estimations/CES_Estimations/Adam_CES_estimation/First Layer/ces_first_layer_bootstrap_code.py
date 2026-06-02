import os
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor as Executor, as_completed

import numpy as np
import pandas as pd
import tensorflow as tf


# ============================================================
# CONFIGURATION
# ============================================================

DATA_PATH = r"C:\Users\adity\Dropbox\Adi-Simone-Ghassane\Natural Capital\CES ML Estimation\matlab_data_nomin_noene.xlsx"

MAIN_EPOCHS = 15000
BOOTSTRAP_EPOCHS = 5000
N_BOOTSTRAP_SAMPLES = 100

N_WORKERS = max(1, os.cpu_count() - 1)

INITIAL_LEARNING_RATE = 0.2
BETA_1 = 0.9
BETA_2 = 0.999
EPSILON = 1e-7
DECAY_RATE = 1e-3
DECAY_STEPS = 5000

OUTPUT_PATH = Path.cwd() / "ces_first_layer_results.xlsx"


# ============================================================
# INITIAL GUESSES
# ============================================================

beta_k_guess = 0.15
beta_eco_guess = 0.002
beta_c_guess = 0.4
beta_m_guess = 0.1
beta_ene_guess = 0.2
beta_hc_guess = 0.5
rho_guess = 1.2


def logit(beta):
    return np.log(beta) - np.log(1 - beta)


mu_k_init = logit(beta_k_guess)
mu_eco_init = logit(beta_eco_guess)
mu_c_init = logit(beta_c_guess)
mu_m_init = logit(beta_m_guess)
mu_ene_init = logit(beta_ene_guess)
lambda_init = np.log(1 + rho_guess)


# ============================================================
# MODEL
# ============================================================

class CESModel(tf.Module):
    def __init__(self):
        super().__init__()

        self.gamma = tf.Variable(0.3850, dtype=tf.float32, trainable=True)

        self.mu_k = tf.Variable(mu_k_init, dtype=tf.float32, trainable=True)
        self.mu_eco = tf.Variable(mu_eco_init, dtype=tf.float32, trainable=True)
        self.mu_c = tf.Variable(mu_c_init, dtype=tf.float32, trainable=True)
        self.mu_m = tf.Variable(mu_m_init, dtype=tf.float32, trainable=True)
        self.mu_ene = tf.Variable(mu_ene_init, dtype=tf.float32, trainable=True)

        self.lambda_ = tf.Variable(lambda_init, dtype=tf.float32, trainable=True)
        self.upsilon = tf.Variable(0.9, dtype=tf.float32, trainable=True)

    def _logit_inverse(self, mu):
        return 1 / (1 + tf.exp(-mu))

    def _rho_from_lambda(self, lambda_):
        return tf.exp(lambda_) - 1

    def get_beta_values(self):
        beta_k = self._logit_inverse(self.mu_k).numpy()
        beta_eco = self._logit_inverse(self.mu_eco).numpy()
        beta_c = self._logit_inverse(self.mu_c).numpy()
        beta_m = self._logit_inverse(self.mu_m).numpy()
        beta_ene = self._logit_inverse(self.mu_ene).numpy()

        beta_hc = 1 - (
            beta_k + beta_eco + beta_c + beta_m + beta_ene
        )

        return {
            "beta_k": float(beta_k),
            "beta_eco": float(beta_eco),
            "beta_c": float(beta_c),
            "beta_m": float(beta_m),
            "beta_ene": float(beta_ene),
            "beta_hc": float(beta_hc),
        }

    def __call__(self, x_k, x_eco, x_c, x_m, x_ene, x_hc):
        beta_k = self._logit_inverse(self.mu_k)
        beta_eco = self._logit_inverse(self.mu_eco)
        beta_c = self._logit_inverse(self.mu_c)
        beta_m = self._logit_inverse(self.mu_m)
        beta_ene = self._logit_inverse(self.mu_ene)

        beta_hc = 1 - (
            beta_k + beta_eco + beta_c + beta_m + beta_ene
        )

        rho = self._rho_from_lambda(self.lambda_)

        ces = (
            beta_k * tf.pow(x_k, rho)
            + beta_eco * tf.pow(x_eco, rho)
            + beta_c * tf.pow(x_c, rho)
            + beta_m * tf.pow(x_m, rho)
            + beta_ene * tf.pow(x_ene, rho)
            + beta_hc * tf.pow(x_hc, rho)
        )

        output = tf.math.log(self.gamma) + (
            self.upsilon / rho
        ) * tf.math.log(ces)

        return output


# ============================================================
# TRAINING UTILITIES
# ============================================================

def create_optimizer():
    return tf.optimizers.Adam(
        learning_rate=tf.keras.optimizers.schedules.ExponentialDecay(
            initial_learning_rate=INITIAL_LEARNING_RATE,
            decay_steps=DECAY_STEPS,
            decay_rate=DECAY_RATE,
            staircase=False,
        ),
        beta_1=BETA_1,
        beta_2=BETA_2,
        epsilon=EPSILON,
    )


def loss_function(y_true, y_pred):
    return tf.reduce_mean(tf.square(y_true - y_pred))


def extract_arrays(df):
    return (
        df["pk_n"].values.astype(np.float32),
        df["for_notim_n"].values.astype(np.float32),
        df["land_n"].values.astype(np.float32),
        df["min_n"].values.astype(np.float32),
        df["ene_n"].values.astype(np.float32),
        df["hc_n"].values.astype(np.float32),
        df["ln_gdp"].values.astype(np.float32),
    )


def train_model(df, n_epochs, print_every=None, label="Training"):
    x_k, x_eco, x_c, x_m, x_ene, x_hc, y_true = extract_arrays(df)

    model = CESModel()
    optimizer = create_optimizer()

    @tf.function
    def train_step(x_k, x_eco, x_c, x_m, x_ene, x_hc, y_true):
        with tf.GradientTape() as tape:
            y_pred = model(x_k, x_eco, x_c, x_m, x_ene, x_hc)
            loss = loss_function(y_true, y_pred)

        gradients = tape.gradient(loss, model.trainable_variables)
        optimizer.apply_gradients(
            zip(gradients, model.trainable_variables)
        )

        return loss

    final_loss = None

    for epoch in range(n_epochs):
        final_loss = train_step(
            x_k, x_eco, x_c, x_m, x_ene, x_hc, y_true
        )

        if print_every is not None and epoch % print_every == 0:
            print(f"{label}, epoch {epoch}: loss = {final_loss.numpy()}")

    return model, float(final_loss.numpy())


def extract_results(model, final_loss=None, bootstrap_id=None):
    rho_estimated = model._rho_from_lambda(model.lambda_.numpy())
    theta = 1 / (1 - rho_estimated)

    beta_values = model.get_beta_values()

    result = {
        "gamma": float(model.gamma.numpy()),
        "lambda": float(model.lambda_.numpy()),
        "rho": float(rho_estimated.numpy()),
        "theta": float(theta.numpy()),
        "upsilon": float(model.upsilon.numpy()),
        **beta_values,
    }

    if final_loss is not None:
        result["loss"] = final_loss

    if bootstrap_id is not None:
        result["bootstrap_id"] = bootstrap_id

    return result


# ============================================================
# BOOTSTRAP WORKER
# ============================================================

def run_bootstrap_iteration(args):
    df, i = args

    tf.config.optimizer.set_jit(True)

    try:
        tf.config.threading.set_intra_op_parallelism_threads(1)
        tf.config.threading.set_inter_op_parallelism_threads(1)
    except RuntimeError:
        pass

    np.random.seed(i)
    tf.random.set_seed(i)

    df_bootstrap = df.sample(
        frac=1,
        replace=True,
        random_state=i,
    )

    model, final_loss = train_model(
        df_bootstrap,
        n_epochs=BOOTSTRAP_EPOCHS,
        print_every=None,
        label=f"Bootstrap {i}",
    )

    return extract_results(
        model,
        final_loss=final_loss,
        bootstrap_id=i,
    )


# ============================================================
# MAIN SCRIPT
# ============================================================

def main():
    tf.config.optimizer.set_jit(True)

    print("Loading data...")
    df = pd.read_excel(DATA_PATH)

    print("Training model on full sample...")
    main_model, main_loss = train_model(
        df,
        n_epochs=MAIN_EPOCHS,
        print_every=100,
        label="Full sample",
    )

    main_results = extract_results(main_model, final_loss=main_loss)

    print("\nEstimated parameters on full sample:")
    for key, value in main_results.items():
        print(f"{key}: {value}")

    print("\nStarting parallel bootstrap...")
    print(f"Bootstrap samples: {N_BOOTSTRAP_SAMPLES}")
    print(f"Workers: {N_WORKERS}")

    bootstrap_results = []

    tasks = [(df, i) for i in range(N_BOOTSTRAP_SAMPLES)]

    with Executor(max_workers=N_WORKERS) as executor:
        futures = [
            executor.submit(run_bootstrap_iteration, task)
            for task in tasks
        ]

        for completed, future in enumerate(as_completed(futures), start=1):
            result = future.result()
            bootstrap_results.append(result)

            print(
                f"Completed bootstrap {completed}/"
                f"{N_BOOTSTRAP_SAMPLES} "
                f"(id={result['bootstrap_id']}, loss={result['loss']})"
            )

    bootstrap_df = pd.DataFrame(bootstrap_results)
    bootstrap_df = bootstrap_df.sort_values("bootstrap_id")

    parameter_columns = [
        "gamma",
        "lambda",
        "rho",
        "theta",
        "upsilon",
        "beta_k",
        "beta_eco",
        "beta_c",
        "beta_m",
        "beta_ene",
        "beta_hc",
    ]

    summary_df = pd.DataFrame({
        "parameter": parameter_columns,
        "full_sample_estimate": [
            main_results[param] for param in parameter_columns
        ],
        "bootstrap_average": [
            bootstrap_df[param].mean() for param in parameter_columns
        ],
        "bootstrap_standard_error": [
            bootstrap_df[param].std(ddof=1) for param in parameter_columns
        ],
    })

    with pd.ExcelWriter(OUTPUT_PATH) as writer:
        summary_df.to_excel(writer, sheet_name="summary", index=False)
        bootstrap_df.to_excel(writer, sheet_name="bootstrap_draws", index=False)

    print("\nBootstrap summary:")
    print(summary_df)

    print(f"\nSaved results to: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()