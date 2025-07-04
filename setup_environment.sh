#!/bin/bash

# Market Simulator Environment Setup Script
# This script installs R and all required packages for the Shiny application

echo "=== MARKET SIMULATOR SETUP ==="
echo "Setting up R and dependencies for the Market Simulator application..."

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install R and required system dependencies
echo "Installing R and system dependencies..."
sudo apt-get install -y \
    r-base \
    r-base-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev

# Check if R is installed successfully
if command -v R &> /dev/null; then
    echo "✓ R installed successfully"
    R --version | head -1
else
    echo "✗ R installation failed"
    exit 1
fi

# Install R packages
echo "Installing R packages..."
Rscript -e "
# Set CRAN mirror
options(repos = c(CRAN = 'https://cran.rstudio.com/'))

# Function to install packages if not already installed
install_if_missing <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat('Installing package:', pkg, '\n')
      install.packages(pkg, dependencies = TRUE)
    } else {
      cat('Package', pkg, 'is already installed\n')
    }
  }
}

# Required packages
required_packages <- c(
  'shiny', 'shinydashboard', 'shinyWidgets',
  'dplyr', 'tidyr', 'purrr', 'readr',
  'mlogit', 'dfidx', 'ggplot2', 'plotly', 
  'DT', 'viridis', 'scales', 'cluster'
)

# Install packages
install_if_missing(required_packages)

# Test loading all packages
cat('\nTesting package loading...\n')
success <- TRUE
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat('ERROR: Failed to load package:', pkg, '\n')
    success <- FALSE
  }
}

if (success) {
  cat('✓ All packages loaded successfully!\n')
  cat('The Market Simulator is ready to run.\n')
} else {
  cat('✗ Some packages failed to load.\n')
  quit(status = 1)
}
"

if [ $? -eq 0 ]; then
    echo "✓ R packages installed successfully"
else
    echo "✗ R package installation failed"
    exit 1
fi

echo ""
echo "=== SETUP COMPLETE ==="
echo "Market Simulator is ready to run!"
echo ""
echo "To start the application, run:"
echo "  R -e \"shiny::runApp('app.R')\""
echo ""
echo "Or start R and run:"
echo "  shiny::runApp('app.R')"
echo ""
echo "The application will open in your default web browser."
echo "If running on a server, access it at: http://localhost:8100"