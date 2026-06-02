import os
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"

import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf

# Initial guesses for parameters
beta_k_guess = 0.15
beta_eco_guess = 0.002
beta_c_guess = 0.4
beta_m_guess = 0.1
beta_ene_guess = 0.2
beta_hc_guess = 0.5
rho_guess = 1.2

# Logit transformation for share parameters (reparametrization)
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
        super().__init__()
        self.gamma = tf.Variable(0.3850, dtype=tf.float32, trainable=True)
        
        # Reparametrized versions (share parameters)
        self.mu_k = tf.Variable(mu_k_init, dtype=tf.float32, trainable=True)
        self.mu_eco = tf.Variable(mu_eco_init, dtype=tf.float32, trainable=True)
        self.mu_c = tf.Variable(mu_c_init, dtype=tf.float32, trainable=True)
        self.mu_m = tf.Variable(mu_m_init, dtype=tf.float32, trainable=True)
        self.mu_ene = tf.Variable(mu_ene_init, dtype=tf.float32, trainable=True)
        
        # Elasticity parameter
        self.lambda_ = tf.Variable(lambda_init, dtype=tf.float32, trainable=True)
        self.upsilon = tf.Variable(0.9, dtype=tf.float32, trainable=True)
    
    def _logit_inverse(self, mu):
        """Inverse logit transformation to recover beta from mu."""
        epsilon = 1e-10 
        return 1 / (1 + tf.exp(-mu + epsilon))
    
    def _rho_from_lambda(self, lambda_):
        """Recover rho from lambda using rho = exp(lambda) - 1."""
        return tf.exp(lambda_) - 1
    
    def get_beta_values(self):
        """Returns the current estimated beta values as Python floats."""
        beta_k = float(self._logit_inverse(self.mu_k).numpy())
        beta_eco = float(self._logit_inverse(self.mu_eco).numpy())
        beta_c = float(self._logit_inverse(self.mu_c).numpy())
        beta_m = float(self._logit_inverse(self.mu_m).numpy())
        beta_ene = float(self._logit_inverse(self.mu_ene).numpy())
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
        return output

# Define the loss function
def loss_function(y_true, y_pred):
    return tf.reduce_mean(tf.square(y_true - y_pred))

# Load the dataset
data_path = r"C:\Users\adity\Dropbox\Adi-Simone-Ghassane\Natural Capital\CES ML Estimation\matlab_data_nomin_noene.xlsx"
df = pd.read_excel(data_path)

# Check if the 'year' column exists
if 'year' not in df.columns:
    raise ValueError("The dataset must contain a 'year' column.")

# Initialize dictionaries to store results
# Rolling Estimation
theta_estimates_rolling = {}
upsilon_estimates_rolling = {}
beta_estimates_rolling = {}

# Reduced Window Estimation
theta_estimates_reduced = {}
upsilon_estimates_reduced = {}
beta_estimates_reduced = {}

# Define a function for model training and estimation
def train_and_estimate(df_train, year_label, optimizer, estimation_type='Rolling'):
    # Extract the data for training
    x_k = df_train['pk_n'].values.astype(np.float32)
    x_eco = df_train['for_notim_n'].values.astype(np.float32)
    x_c = df_train['land_n'].values.astype(np.float32)
    x_m = df_train['min_n'].values.astype(np.float32)
    x_ene = df_train['ene_n'].values.astype(np.float32)
    x_hc = df_train['hc_n'].values.astype(np.float32)
    y_true = df_train['ln_gdp'].values.astype(np.float32)
    
    # Instantiate a new CES model
    model = CESModel()
    
    # Define the training step
    @tf.function
    def train_step(x_k, x_eco, x_c, x_m, x_ene, x_hc, y_true):
        with tf.GradientTape() as tape:
            y_pred = model(x_k, x_eco, x_c, x_m, x_ene, x_hc)
            loss = loss_function(y_true, y_pred)
        gradients = tape.gradient(loss, model.trainable_variables)
        optimizer.apply_gradients(zip(gradients, model.trainable_variables))
        return loss
    
    # Train the model
    for epoch in range(10000):
        loss = train_step(x_k, x_eco, x_c, x_m, x_ene, x_hc, y_true)
        if epoch % 1000 == 0:
            print(f'{estimation_type} Estimation - {year_label}, Epoch {epoch}: Loss = {loss.numpy()}')
    
    # After training, store the estimated parameters
    rho_tensor = model._rho_from_lambda(model.lambda_.numpy())
    rho_estimated = rho_tensor.numpy()
    
    if rho_estimated == 1:
        print(f"Rho estimated as 1 for {year_label}, which may lead to division by zero.")
        theta = np.nan
    else:
        theta = 1 / (1 - rho_estimated)
    
    upsilon = float(model.upsilon.numpy())
    beta_values = model.get_beta_values()
    
    return theta, upsilon, beta_values

# ------------------ Rolling Estimation ------------------ #
print("\n=== Starting Rolling Estimation ===")
for year in range(1995, 2015):
    print(f"\nStarting Rolling Estimation for year {year}")
    # Filter the dataframe for the current year
    df_year = df[df['year'] == year]
    
    # Check if data exists for the current year
    if df_year.empty:
        print(f"No data found for year {year}. Skipping.")
        continue
    
    # Define the optimizer
    initial_learning_rate = 0.2
    optimizer_rolling = tf.optimizers.Adam(
        learning_rate=tf.keras.optimizers.schedules.ExponentialDecay(
            initial_learning_rate=initial_learning_rate,
            decay_steps=5000,
            decay_rate=1e-3,
            staircase=False
        ),
        beta_1=0.9,
        beta_2=0.999,
        epsilon=1e-7
    )
    
    # Train the model and get estimates
    theta, upsilon, beta_values = train_and_estimate(
        df_train=df_year,
        year_label=f"Year {year}",
        optimizer=optimizer_rolling,
        estimation_type='Rolling'
    )
    
    # Store the estimates
    theta_estimates_rolling[year] = theta
    upsilon_estimates_rolling[year] = upsilon
    beta_estimates_rolling[year] = beta_values

# ------------------ Reduced Window Estimation ------------------ #
print("\n=== Starting Reduced Window Estimation ===")
# Define the maximum end year for the reduced window
max_end_year = 2014
min_end_year = 1995  # Adjust as needed

for end_year in range(max_end_year, min_end_year - 1, -1):
    window_label = f"1995-{end_year}"
    print(f"\nStarting Reduced Window Estimation for window {window_label}")
    
    # Filter the dataframe for the window years
    df_window = df[(df['year'] >= 1995) & (df['year'] <= end_year)]
    
    # Check if data exists for the current window
    if df_window.empty:
        print(f"No data found for window {window_label}. Skipping.")
        continue
    
    # Define the optimizer
    initial_learning_rate = 0.2
    optimizer_reduced = tf.optimizers.Adam(
        learning_rate=tf.keras.optimizers.schedules.ExponentialDecay(
            initial_learning_rate=initial_learning_rate,
            decay_steps=5000,
            decay_rate=1e-3,
            staircase=False
        ),
        beta_1=0.9,
        beta_2=0.999,
        epsilon=1e-7
    )
    
    # Train the model and get estimates
    theta, upsilon, beta_values = train_and_estimate(
        df_train=df_window,
        year_label=f"Window {window_label}",
        optimizer=optimizer_reduced,
        estimation_type='Reduced Window'
    )
    
    # Store the estimates
    theta_estimates_reduced[window_label] = theta
    upsilon_estimates_reduced[window_label] = upsilon
    beta_estimates_reduced[window_label] = beta_values

# ------------------ Plotting and Exporting Results ------------------ #

# Function to plot parameters
def plot_parameter(years, values, parameter_name, estimation_type='Rolling'):
    plt.figure(figsize=(10, 6))
    plt.plot(years, values, marker='o', linestyle='-', label=f'{parameter_name}')
    plt.xlabel('Year' if estimation_type == 'Rolling' else 'Window End Year')
    plt.ylabel(parameter_name)
    plt.title(f'{parameter_name} Estimates Over Time ({estimation_type} Estimation)')
    plt.grid(True)
    plt.legend()
    plt.tight_layout()
    plt.show()

# Plotting Rolling Estimation Results
print("\n=== Plotting Rolling Estimation Results ===")
# Extract and sort years
rolling_years = sorted(theta_estimates_rolling.keys())
rolling_theta = [theta_estimates_rolling[year] for year in rolling_years]

# Plot Theta
plot_parameter(
    years=rolling_years,
    values=rolling_theta,
    parameter_name='Elasticity of Substitution (Theta)',
    estimation_type='Rolling'
)

# Extract and plot each beta parameter
beta_keys = list(beta_estimates_rolling[rolling_years[0]].keys()) if rolling_years else []
beta_data_rolling = {key: [beta_estimates_rolling[year][key] for year in rolling_years] for key in beta_keys}

for key in beta_keys:
    beta_values = beta_data_rolling[key]
    plot_parameter(
        years=rolling_years,
        values=beta_values,
        parameter_name=f'Share Parameter ({key})',
        estimation_type='Rolling'
    )

# Plotting Reduced Window Estimation Results
print("\n=== Plotting Reduced Window Estimation Results ===")
# Extract and sort window labels based on end year
def extract_end_year(window_label):
    return int(window_label.split('-')[1])

reduced_window_labels = sorted(theta_estimates_reduced.keys(), key=extract_end_year, reverse=True)
reduced_theta = [theta_estimates_reduced[window] for window in reduced_window_labels]

# Plot Theta
plot_parameter(
    years=reduced_window_labels,
    values=reduced_theta,
    parameter_name='Elasticity of Substitution (Theta)',
    estimation_type='Reduced Window'
)

# Extract and plot each beta parameter
beta_keys_reduced = list(beta_estimates_reduced[reduced_window_labels[0]].keys()) if reduced_window_labels else []
beta_data_reduced = {key: [beta_estimates_reduced[window][key] for window in reduced_window_labels] for key in beta_keys_reduced}

for key in beta_keys_reduced:
    beta_values = beta_data_reduced[key]
    plot_parameter(
        years=reduced_window_labels,
        values=beta_values,
        parameter_name=f'Share Parameter ({key})',
        estimation_type='Reduced Window'
    )

# Function to export estimates to CSV
def export_estimates_to_csv(estimates_theta, estimates_upsilon, estimates_beta, estimation_type='Rolling', output_path='estimates.csv'):
    # Create DataFrame
    if estimation_type == 'Rolling':
        labels = sorted(estimates_theta.keys())
    else:
        labels = sorted(estimates_theta.keys(), key=lambda x: extract_end_year(x), reverse=True)
    
    estimates_df = pd.DataFrame({
        'Label': labels,
        'Theta': [estimates_theta[label] for label in labels],
        'Upsilon': [estimates_upsilon[label] for label in labels]
    })
    
    # Add beta parameters
    beta_keys = list(estimates_beta[labels[0]].keys()) if labels else []
    for key in beta_keys:
        estimates_df[key] = [estimates_beta[label][key] for label in labels]
    
    # Save to CSV
    estimates_df.to_csv(output_path, index=False)
    print(f"\n{estimation_type} estimates successfully exported to {output_path}")

# Export Rolling Estimation Results
output_csv_path_rolling = r"C:\Users\aditya\Dropbox\Adi-Simone-Ghassane\Natural Capital\Final Codes - Adi\ML Estimation\ces_estimates_rolling.csv"
export_estimates_to_csv(
    estimates_theta=theta_estimates_rolling,
    estimates_upsilon=upsilon_estimates_rolling,
    estimates_beta=beta_estimates_rolling,
    estimation_type='Rolling',
    output_path=output_csv_path_rolling
)

# Export Reduced Window Estimation Results
output_csv_path_reduced = r"C:\Users\aditya\Dropbox\Adi-Simone-Ghassane\Natural Capital\Final Codes - Adi\ML Estimation\ces_estimates_reduced_window.csv"
export_estimates_to_csv(
    estimates_theta=theta_estimates_reduced,
    estimates_upsilon=upsilon_estimates_reduced,
    estimates_beta=beta_estimates_reduced,
    estimation_type='Reduced Window',
    output_path=output_csv_path_reduced
)
