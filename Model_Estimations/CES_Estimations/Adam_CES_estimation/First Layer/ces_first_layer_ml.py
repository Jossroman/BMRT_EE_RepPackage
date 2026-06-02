# -*- coding: utf-8 -*-
"""
Created on Thu Sep 12 16:50:44 2024

ces_first_layer_ml
"""

import tensorflow as tf
import pandas as pd
import numpy as np
#import multiprocessing
from pathlib import Path

#Input the guesses here for the share and the elasticity of substitution parameters

# Tensorflow's accelerated linear algebra XLA set to true
tf.config.optimizer.set_jit(True)

beta_k_guess = 0.15
beta_eco_guess = 0.002
beta_c_guess = 0.4
beta_m_guess = 0.1
beta_ene_guess = 0.2
beta_hc_guess = 0.5
rho_guess = 1.2

# this is to convert them to reparametrised parameters. logit transformation.
mu_k_init = np.log(beta_k_guess) - np.log(1 - beta_k_guess)
mu_eco_init = np.log(beta_eco_guess) - np.log(1 - beta_eco_guess)
mu_c_init = np.log(beta_c_guess) - np.log(1 - beta_c_guess)
mu_m_init = np.log(beta_m_guess) - np.log(1 - beta_m_guess)
mu_ene_init = np.log(beta_ene_guess) - np.log(1 - beta_ene_guess)
mu_hc_init = np.log(beta_hc_guess) - np.log(1 - beta_hc_guess)
lambda_init = np.log(1 + rho_guess)



# Define the CES model
class CESModel(tf.Module):
    def __init__(self):
        self.gamma = tf.Variable(0.3850, dtype=tf.float32, trainable=True)
        
        #this is the reparametrised versions
        
        #share parameters
        self.mu_k = tf.Variable(mu_k_init, dtype=tf.float32, trainable=True)
        self.mu_eco = tf.Variable(mu_eco_init, dtype=tf.float32, trainable=True)
        self.mu_c = tf.Variable(mu_c_init, dtype=tf.float32, trainable=True)
        self.mu_m = tf.Variable(mu_m_init, dtype=tf.float32, trainable=True)
        self.mu_ene = tf.Variable(mu_ene_init, dtype=tf.float32, trainable=True)
        #self.mu_hc = tf.Variable(mu_hc_init, dtype=tf.float32, trainable=True)
        
        #elasticity parameter
        self.lambda_ = tf.Variable(lambda_init, dtype=tf.float32, trainable=True)
        self.upsilon = tf.Variable(0.9, dtype = tf.float32, trainable = True)
    
    def _logit_inverse(self, mu):
        """Inverse logit transformation to recover beta from mu."""
        epsilon = 1e-10 
        return 1 / (1 + tf.exp(-mu + epsilon))

    def _rho_from_lambda(self, lambda_):
        """Recover rho from lambda using rho = exp(lambda) - 1."""
        return tf.exp(lambda_) - 1
    
    def get_beta_values(self):
        """Returns the current estimated beta values."""
        beta_k = self._logit_inverse(self.mu_k).numpy()
        beta_eco = self._logit_inverse(self.mu_eco).numpy()
        beta_c = self._logit_inverse(self.mu_c).numpy()
        beta_m = self._logit_inverse(self.mu_m).numpy()
        beta_ene = self._logit_inverse(self.mu_ene).numpy()
        #beta_hc = self._logit_inverse(self.mu_hc).numpy()
        beta_hc = 1 - (beta_k + beta_eco + beta_c + beta_m + beta_ene)
        
        return {
            'beta_k': beta_k,
            'beta_eco': beta_eco,
            'beta_c': beta_c,
            'beta_m': beta_m,
            'beta_ene': beta_ene,
            'beta_hc': beta_hc
        }

    def __call__(self, x_k, x_eco, x_c, x_m, x_ene, x_hc):
        # Recover the beta parameters from the logit-transformed mu values
        beta_k = self._logit_inverse(self.mu_k)
        beta_eco = self._logit_inverse(self.mu_eco)
        beta_c = self._logit_inverse(self.mu_c)
        beta_m = self._logit_inverse(self.mu_m)
        beta_ene = self._logit_inverse(self.mu_ene)
        #beta_hc = self._logit_inverse(self.mu_hc)
        beta_hc = 1 - (beta_k + beta_eco + beta_c + beta_m + beta_ene)
        
        
        # Recover rho from lambda
        rho = self._rho_from_lambda(self.lambda_)

        # Compute the CES function
        k = tf.pow(x_k, rho)
        eco = tf.pow(x_eco, rho)
        crop = tf.pow(x_c, rho)
        mins = tf.pow(x_m, rho)
        ene = tf.pow(x_ene, rho)
        hc = tf.pow(x_hc, rho)

        # CES aggregation formula using the beta and rho values
        ces = beta_k * k + beta_eco * eco + beta_c * crop + beta_m * mins + beta_ene * ene + beta_hc * hc
        output = tf.math.log(self.gamma) + (self.upsilon / rho) * tf.math.log(ces)
        
        #output = tf.math.log(self.gamma) + (1 / rho) * tf.math.log(ces)
        return output

# Define the loss function
def loss_function(y_true, y_pred):
    return (tf.reduce_mean(tf.square(y_true - y_pred)))

# Load the dataset
df = pd.read_excel(r"C:\Users\adity\Dropbox\Adi-Simone-Ghassane\Natural Capital\CES ML Estimation\matlab_data_nomin_noene.xlsx")  # Replace with your actual dataset file name

# Assuming the dataset has columns 'capital', 'eco', 'crop', 'min', 'ene', 'hc' for input features, and 'output' for the target
x_k = df['pk_n'].values.astype(np.float32)
x_eco = df['for_notim_n'].values.astype(np.float32)
x_c = df['land_n'].values.astype(np.float32)
x_m = df['min_n'].values.astype(np.float32)
x_ene = df['ene_n'].values.astype(np.float32)
x_hc = df['hc_n'].values.astype(np.float32)
y_true = df['ln_gdp'].values.astype(np.float32)


# Instantiate the CES model
model = CESModel()

# Define the optimizer (Adam in this case)
# Define the Adam optimizer with custom decay rates
initial_learning_rate = 0.2
beta_1 = 0.9  # Default: 0.9, the exponential decay rate for the first moment estimates
beta_2 = 0.999  # Default: 0.999, the exponential decay rate for the second moment estimates
epsilon = 1e-7  # Default: 1e-7, a small constant to prevent division by zero
decay_rate = 1e-3 # Add learning rate decay over time

# Initialize the Adam optimizer with a learning rate decay
optimizer = tf.optimizers.Adam(
    learning_rate=tf.keras.optimizers.schedules.ExponentialDecay(
        initial_learning_rate=initial_learning_rate,
        decay_steps=5000,  # How often to decay the learning rate (in steps)
        decay_rate=decay_rate,  # The rate at which the learning rate decays
        staircase=False  # If True, learning rate decays at discrete intervals
    ),
    beta_1=beta_1,
    beta_2=beta_2,
    epsilon=epsilon
)

# Define the training step
@tf.function
def train_step(x_k, x_eco, x_c, x_m, x_ene, x_hc, y_true):
    with tf.GradientTape() as tape:
        # Make a prediction using the current model parameters
        y_pred = model(x_k, x_eco, x_c, x_m, x_ene, x_hc)
        # Calculate the loss between the predicted and true values
        loss = loss_function(y_true, y_pred)
    # Compute gradients and apply them using the optimizer
    gradients = tape.gradient(loss, model.trainable_variables)
    optimizer.apply_gradients(zip(gradients, model.trainable_variables))
    return loss

# Training loop - feeding in the data
for epoch in range(15000):
    loss = train_step(x_k, x_eco, x_c, x_m, x_ene, x_hc, y_true)  # Feed the data into the training step
    if epoch % 100 == 0:
        print(f'Epoch {epoch}: Loss = {loss.numpy()}')

# After training, print the estimated parameters
print("Estimated parameters:")
print(f"gamma = {model.gamma.numpy()}")
print(f"lambda = {model.lambda_.numpy()}")

# Convert rho to elasticity of substitution theta
rho_estimated = model._rho_from_lambda(model.lambda_.numpy())
theta = 1 / (1 - rho_estimated)
print(f"Elasticity of substitution (theta) = {theta}")

upsilon = model.upsilon.numpy()
print(f"Returns to scale parameter: {upsilon}")

final_beta_values = model.get_beta_values()
print(f"Final estimated beta values: {final_beta_values}")


# Bootstrapping configuration
n_bootstrap_samples = 50  # Number of bootstrap samples
n_epochs = 5000  # Number of training epochs for each bootstrap sample

# Arrays to store bootstrap estimates
gamma_estimates = []
lambda_estimates = []
#upsilon_estimates = []
beta_k_estimates = []
beta_eco_estimates = []
beta_c_estimates = []
beta_m_estimates = []
beta_ene_estimates = []
beta_hc_estimates = []
theta_estimates = []

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


# Define a function to run a single bootstrap iteration
def run_bootstrap_iteration(df_bootstrap, i):
    # Get the resampled dataset
    x_k = df_bootstrap['pk_n'].values.astype(np.float32)
    x_eco = df_bootstrap['for_notim_n'].values.astype(np.float32)
    x_c = df_bootstrap['land_n'].values.astype(np.float32)
    x_m = df_bootstrap['min_n'].values.astype(np.float32)
    x_ene = df_bootstrap['ene_n'].values.astype(np.float32)
    x_hc = df_bootstrap['hc_n'].values.astype(np.float32)
    y_true = df_bootstrap['ln_gdp'].values.astype(np.float32)
    
    # Instantiate a new CES model and optimizer for this bootstrap sample
    model = CESModel()
    optimizer = create_optimizer()  # Reinitialize optimizer
    
    # Training loop for the bootstrap sample
    for epoch in range(n_epochs):
        loss = train_step(x_k, x_eco, x_c, x_m, x_ene, x_hc, y_true)
        with tf.GradientTape() as tape:
            # Make a prediction using the current model parameters
            y_pred = model(x_k, x_eco, x_c, x_m, x_ene, x_hc)
            # Calculate the loss between the predicted and true values
            loss = loss_function(y_true, y_pred)
        # Compute gradients and apply them using the optimizer
        gradients = tape.gradient(loss, model.trainable_variables)
        optimizer.apply_gradients(zip(gradients, model.trainable_variables))

        if epoch % 1000 == 0:
            print(f'Bootstrap {i}, Epoch {epoch}: Loss = {loss.numpy()}')
    
    # Store the estimated parameters after training
    gamma_estimates.append(model.gamma.numpy())
    lambda_estimates.append(model.lambda_.numpy())
    #upsilon_estimates.append(model.upsilon.numpy())
    
    # Get the beta values and append to respective lists
    beta_values = model.get_beta_values()
    beta_k_estimates.append(beta_values['beta_k'])
    beta_eco_estimates.append(beta_values['beta_eco'])
    beta_c_estimates.append(beta_values['beta_c'])
    beta_m_estimates.append(beta_values['beta_m'])
    beta_ene_estimates.append(beta_values['beta_ene'])
    beta_hc_estimates.append(beta_values['beta_hc'])
    
    # Calculate and store the elasticity of substitution (theta)
    rho_estimated = model._rho_from_lambda(model.lambda_.numpy())
    theta_estimates.append(1 / (1 - rho_estimated))
    

# Main bootstrapping loop
for i in range(n_bootstrap_samples):
    # Resample the data with replacement
    df_bootstrap = df.sample(frac=1, replace=True, random_state=i)
    
    # Run the bootstrap iteration
    run_bootstrap_iteration(df_bootstrap, i)  # Pass the iteration index
    
    if i % 10 == 0:
        print(f'Bootstrap iteration {i} completed')

# After all bootstrap samples, calculate standard errors for each parameter
gamma_se = np.std(gamma_estimates)
lambda_se = np.std(lambda_estimates)
#upsilon_se = np.std(upsilon_estimates)
beta_k_se = np.std(beta_k_estimates)
beta_eco_se = np.std(beta_eco_estimates)
beta_c_se = np.std(beta_c_estimates)
beta_m_se = np.std(beta_m_estimates)
beta_ene_se = np.std(beta_ene_estimates)
beta_hc_se = np.std(beta_hc_estimates)
theta_se = np.std(theta_estimates)

gamma_avg = np.mean(gamma_estimates)
lambda_avg = np.mean(lambda_estimates)
#upsilon_avg = np.mean(upsilon_estimates)
beta_k_avg = np.mean(beta_k_estimates)
beta_eco_avg = np.mean(beta_eco_estimates)
beta_c_avg = np.mean(beta_c_estimates)
beta_m_avg = np.mean(beta_m_estimates)
beta_ene_avg = np.mean(beta_ene_estimates)
beta_hc_avg = np.mean(beta_hc_estimates)
theta_avg = np.mean(theta_estimates)


# Print the standard errors
print("Standard errors for the parameters after bootstrapping:")
print(f"gamma SE: {gamma_se}")
print(f"lambda SE: {lambda_se}")
#print(f"upsilon SE: {upsilon_se}")
print(f"beta_k SE: {beta_k_se}")
print(f"beta_eco SE: {beta_eco_se}")
print(f"beta_c SE: {beta_c_se}")
print(f"beta_m SE: {beta_m_se}")
print(f"beta_ene SE: {beta_ene_se}")
print(f"beta_hc SE: {beta_hc_se}")
print(f"theta SE: {theta_se}")


# Print the averages
print("Average values for the parameters after bootstrapping:")
print(f"gamma: {gamma_avg}")
print(f"lambda: {lambda_avg}")
#print(f"upsilon: {upsilon_avg}")
print(f"beta_k: {beta_k_avg}")
print(f"beta_eco: {beta_eco_avg}")
print(f"beta_c: {beta_c_avg}")
print(f"beta_m: {beta_m_avg}")
print(f"beta_ene: {beta_ene_avg}")
print(f"beta_hc: {beta_hc_avg}")
print(f"theta: {theta_avg}")

results_df = pd.DataFrame([
    {"parameter": "gamma", "average": gamma_avg, "standard_error": gamma_se},
    {"parameter": "lambda", "average": lambda_avg, "standard_error": lambda_se},
    {"parameter": "theta", "average": theta_avg, "standard_error": theta_se},

    {"parameter": "beta_k", "average": beta_k_avg, "standard_error": beta_k_se},
    {"parameter": "beta_eco", "average": beta_eco_avg, "standard_error": beta_eco_se},
    {"parameter": "beta_c", "average": beta_c_avg, "standard_error": beta_c_se},
    {"parameter": "beta_m", "average": beta_m_avg, "standard_error": beta_m_se},
    {"parameter": "beta_ene", "average": beta_ene_avg, "standard_error": beta_ene_se},
    {"parameter": "beta_hc", "average": beta_hc_avg, "standard_error": beta_hc_se},
])

output_path = Path.cwd() / "ces_first_layer_results.xlsx"
results_df.to_excel(output_path, index=False)

print(f"Saved results to: {output_path}")

