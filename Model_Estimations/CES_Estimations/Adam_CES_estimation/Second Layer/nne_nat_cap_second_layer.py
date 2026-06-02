import os
os.environ['TF_DETERMINISTIC_OPS'] = '1'
os.environ['TF_CUDNN_DETERMINISTIC'] = '1'
import numpy as np
import pandas as pd
from scipy.stats import beta as beta_distribution
from scipy.stats import uniform
import tensorflow as tf  # added for custom loss function
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Dense, Concatenate
from tensorflow.keras.optimizers import Adam
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
import matplotlib.pyplot as plt  
import random
from pathlib import Path

# ===============================
# Seed Configuration for Reproducibility
# ===============================

# Set a global seed value
seed_value = 21
# Different libraries have different separate random number generators
random.seed(seed_value)                # if you need Python's built-in random
np.random.seed(seed_value)             # global NumPy
tf.random.set_seed(seed_value)         # TensorFlow
rng = np.random.default_rng(seed_value)  # separate generator for SciPy stats

# ===============================
# Function Definitions
# ===============================

def calculate_moments(F, R, y):
    """
    Calculate statistical moments from the data.

    Returns:
        np.array: Array of calculated moments (means, variances, covariances).
    """
    moments = []
    # Means
    moments.append(np.mean(F))
    moments.append(np.mean(R))
    moments.append(np.mean(y))
    # Variances
    moments.append(np.var(F))
    moments.append(np.var(R))
    moments.append(np.var(y))
    # Covariances
    moments.append(np.cov(F, y)[0, 1])
    moments.append(np.cov(R, y)[0, 1])
    moments.append(np.cov(F, R)[0, 1])
    return np.array(moments)

def simulate_y(beta_foss, sigma, gamma, F, R):
    """
    Simulate output y using the CES production function.

    Returns:
        np.array: Simulated output data y_sim.
    """
    rho = (sigma - 1) / sigma
    if rho != 0:
        y_sim = np.log(gamma) + (0.8126/ rho) * np.log(beta_foss * F ** rho + (1 - beta_foss) * R ** rho)
    else:
        y_sim = np.log(gamma) + beta_foss * np.log(F) + (1 - beta_foss) * np.log(R)
    return y_sim

def generate_training_data_NNE(L, alpha_param, beta_param, gamma_lb, gamma_ub, sigma_lb, sigma_ub, F_real, R_real):
    """
    Generate training data for Neural Network Estimation (NNE).

    Returns:
        tuple: Arrays of input data (moments) and labels (parameters).
    """
    input_data = []
    labels = []

    print("Generating training data for NNE...")
    for i in range(L):
        if (i+1) % 500 == 0 or i == 0:
            print(f"Simulating draw {i+1}/{L}...")
        # Sample parameters
        beta_foss = beta_distribution.rvs(alpha_param, beta_param, random_state=rng)
        sigma = uniform.rvs(loc=sigma_lb, scale=sigma_ub - sigma_lb, random_state=rng)
        gamma = uniform.rvs(loc=gamma_lb, scale=gamma_ub - gamma_lb, random_state=rng)

        # Simulate output y
        y_sim = simulate_y(beta_foss, sigma, gamma, F_real, R_real)

        # Calculate moments
        moments = calculate_moments(F_real, R_real, y_sim)

        # Store data
        input_data.append(moments)
        labels.append([beta_foss, sigma, gamma])

    return np.array(input_data), np.array(labels)

def build_model(input_shape):
    input_layer = Input(shape=(input_shape,))
    x = Dense(2400, activation='relu')(input_layer)
    x = Dense(2400, activation='relu')(x)

    # Output for means
    means = Dense(3)(x)

    # Output for variances (before softplus)
    variances_pred = Dense(3)(x)

    # Concatenate means and variances_pred
    output = Concatenate()([means, variances_pred])

    # Define the model
    model = Model(inputs=input_layer, outputs=output)
    return model

def custom_loss(y_true, y_pred):
    """
    Custom loss function for NNE that computes the negative log-likelihood.

    Returns:
        tensor: Computed loss.
    """
    # Extract predicted means and variances
    mu = y_pred[:, :3]  # Predicted means
    variances_pred = y_pred[:, 3:]  # Predicted variances (before activation)

    # Ensure variances are positive using softplus
    epsilon = 1e-6  # Small constant to prevent numerical issues
    variances = tf.nn.softplus(variances_pred) + epsilon

    # Compute log determinant of V (since V is diagonal)
    log_det_V = tf.reduce_sum(tf.math.log(variances), axis=1)

    # Compute the quadratic form
    diff = y_true - mu
    quadratic_form = tf.reduce_sum(tf.square(diff) / variances, axis=1)

    # Compute the total loss per sample
    loss_per_sample = log_det_V + quadratic_form

    # Compute the mean loss over the batch
    loss = tf.reduce_mean(loss_per_sample)

    # Check for numerical issues
    tf.debugging.check_numerics(loss, 'Loss contains NaNs or Infs')
    return loss

def train_NNE_model(X_train, y_train, X_val, y_val, epochs=100, batch_size=64):
    """
    Define, compile, and train the neural network model for NNE.

    Returns:
        tuple: Trained Keras model and training history.
    """
    # Build the model
    model = build_model(X_train.shape[1])

    # Compile the model
    model.compile(optimizer=Adam(learning_rate=0.01), loss=custom_loss)

    # Train the model
    print("Training the neural network...")
    history = model.fit(
        X_train, y_train,
        epochs=epochs,
        batch_size=batch_size,
        validation_data=(X_val, y_val),
        verbose=1
    )

    return model, history

def estimate_parameters_NNE(model, observed_moments):
    """
    Estimate parameters using the trained NNE model.

    Returns:
        tuple: Estimated means and standard deviations for parameters.
    """
    estimated_output = model.predict(observed_moments.reshape(1, -1))
    estimated_means = estimated_output[0, :3]
    variances_predicted = estimated_output[0, 3:]
    variances = tf.nn.softplus(variances_predicted).numpy() + 1e-6
    standard_deviations = np.sqrt(variances)
    return estimated_means, standard_deviations

# ===============================
# Main Execution
# ===============================

def main():
    """
    Main function to execute NNE and generate plots.
    """
    # Define file paths and parameters
    data_file_path = r"C:\Users\adity\Dropbox\Adi-Simone-Ghassane\Natural Capital\Cleaned Files\matlab_data_fossil_renew.xlsx"
    L = 5000  # Number of simulated examples

    # Data Preparation and Moment Calculation
    print("Loading real-world data...")
    if not os.path.exists(data_file_path):
        print(f"Data file not found at {data_file_path}. Please check the path.")
        return

    data = pd.read_excel(data_file_path)

    # Extract F, R, and y (observed output data)
    try:
        F_real = data['fossil_energy'].values  # Ensure this is in levels
        R_real = data['renew_energy'].values   # Ensure this is in levels
        y_real = data['ln_energy_prod'].values # Observed output data
    except KeyError as e:
        print(f"Missing column in data: {e}.")
        return

    # Calculate moments for the observed data
    observed_moments = calculate_moments(F_real, R_real, y_real)

    # Training Data Generation and Neural Network Training
    alpha_param = 38
    beta_param = 33
    gamma_lb = 0.99
    gamma_ub = 1.1
    sigma_lb = 4.8
    sigma_ub = 5.5

    # Generate training data
    input_data, labels = generate_training_data_NNE(
        L=L,
        alpha_param=alpha_param,
        beta_param=beta_param,
        gamma_lb=gamma_lb,
        gamma_ub=gamma_ub,
        sigma_lb=sigma_lb,
        sigma_ub=sigma_ub,
        F_real=F_real,
        R_real=R_real
    )

    # Split into training and validation sets
    X_train, X_val, y_train, y_val = train_test_split(
        input_data, labels, test_size=0.2, random_state=42
    )

    # Train the neural network
    model, history = train_NNE_model(
        X_train, y_train, X_val, y_val,
        epochs=100,
        batch_size=64
    )

    # Parameter Estimation and Performance Evaluation
    print("\nEstimating parameters from observed data...")
    observed_moments_reshaped = observed_moments.reshape(1, -1)
    estimated_means, standard_deviations = estimate_parameters_NNE(model, observed_moments_reshaped)

    # Display the estimated parameters
    param_names = ['beta_foss', 'sigma', 'gamma']
    print("\nEstimated Parameters:")
    for i, param in enumerate(param_names):
        print(f"{param}: Mean = {estimated_means[i]:.4f}, Std Dev = {standard_deviations[i]:.4f}")

    # -------------------------------------------------
    # Calculate lambda after estimating sigma
    # -------------------------------------------------
    # Given:
    # sigma = 1 / (1 + rho)
    # rho = exp(lambda) - 1

    # Therefore:
    # sigma = exp(-lambda)
    # lambda = -log(sigma)

    sigma_hat = estimated_means[1]
    sigma_se = standard_deviations[1]

    # Consistent rho calculation
    rho_hat = (sigma_hat - 1) / sigma_hat

    # Delta method for rho:
    # rho = 1 - 1/sigma
    # d rho / d sigma = 1 / sigma^2
    rho_se = sigma_se / (sigma_hat ** 2)

    # Consistent lambda calculation
    lambda_hat = np.log(1 + rho_hat)
    # equivalently:
    # lambda_hat = np.log(2 - 1 / sigma_hat)

    # Delta method for lambda:
    # lambda = log(1 + rho)
    # d lambda / d rho = 1 / (1 + rho)
    # d rho / d sigma = 1 / sigma^2
    #
    # Therefore:
    # d lambda / d sigma = 1 / [(1 + rho) * sigma^2]
    lambda_se = sigma_se / ((1 + rho_hat) * sigma_hat ** 2)
    
    print("\nImplied Rho and Lambda:")
    print(f"rho:    Mean = {rho_hat:.4f}, Std Error = {rho_se:.4f}")
    print(f"lambda: Mean = {lambda_hat:.4f}, Std Error = {lambda_se:.4f}")

    # Evaluate performance on validation set
    print("\nEvaluating model performance on validation data...")
    y_pred_val = model.predict(X_val)
    predicted_means_val = y_pred_val[:, :3]
    mse = mean_squared_error(y_val, predicted_means_val)
    print(f"Validation Mean Squared Error (MSE): {mse:.6f}")

    # Compute average standard deviations over validation set
    variances_predicted_val = y_pred_val[:, 3:]
    variances_val = tf.nn.softplus(variances_predicted_val).numpy() + 1e-6
    standard_deviations_val = np.sqrt(variances_val)
    avg_std_dev = np.mean(standard_deviations_val, axis=0)
    print("\nAverage Standard Deviations over Validation Set:")
    for i, param in enumerate(param_names):
        print(f"{param}: Avg Std Dev = {avg_std_dev[i]:.4f}")

    # Plotting Sections (Optional)
    # Uncomment the following code if you wish to generate plots

    # plt.figure(figsize=(10, 6))
    # plt.plot(history.history['loss'], label='Training Loss')
    # plt.plot(history.history['val_loss'], label='Validation Loss')
    # plt.title('Neural Network Training Progress')
    # plt.ylabel('Loss')
    # plt.xlabel('Epoch')
    # plt.legend()
    # plt.tight_layout()
    # plt.show()
    
    results_df = pd.DataFrame([
    {
        "parameter": "beta_foss",
        "mean": estimated_means[0],
        "std_error": standard_deviations[0],
        "validation_avg_std_dev": avg_std_dev[0],
        "validation_mse": mse
    },
    {
        "parameter": "sigma",
        "mean": estimated_means[1],
        "std_error": standard_deviations[1],
        "validation_avg_std_dev": avg_std_dev[1],
        "validation_mse": mse
    },
    {
        "parameter": "gamma",
        "mean": estimated_means[2],
        "std_error": standard_deviations[2],
        "validation_avg_std_dev": avg_std_dev[2],
        "validation_mse": mse
    },
    {
        "parameter": "rho",
        "mean": rho_hat,
        "std_error": rho_se,
        "validation_avg_std_dev": None,
        "validation_mse": mse
    },
    {
        "parameter": "lambda",
        "mean": lambda_hat,
        "std_error": lambda_se,
        "validation_avg_std_dev": None,
        "validation_mse": mse
    },
    ])

    output_path = Path.cwd() / "second_layer_results.xlsx"
    results_df.to_excel(output_path, index=False)

    print(f"\nSaved results to: {output_path}")

if __name__ == "__main__":
    main()
