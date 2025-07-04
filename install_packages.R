# Install Required Packages for Market Simulator
# Run this script to install all dependencies for the Shiny application

# Function to install packages if not already installed
install_if_missing <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE)) {
      cat("Installing package:", pkg, "\n")
      install.packages(pkg, dependencies = TRUE)
    } else {
      cat("Package", pkg, "is already installed\n")
    }
  }
}

# Required packages
required_packages <- c(
  # Core Shiny packages
  "shiny",
  "shinydashboard",
  "shinyWidgets",
  
  # Data manipulation and analysis
  "dplyr",
  "tidyr",
  "purrr",
  "readr",
  
  # Conjoint analysis packages
  "mlogit",
  "dfidx",
  
  # Visualization packages
  "ggplot2",
  "plotly",
  "DT",
  "viridis",
  "scales",
  
  # Statistical packages
  "cluster",
  
  # Utility packages
  "htmltools"
)

cat("=== MARKET SIMULATOR PACKAGE INSTALLER ===\n")
cat("Installing required packages for the Market Simulator Shiny app...\n\n")

# Install packages
install_if_missing(required_packages)

cat("\n=== INSTALLATION COMPLETE ===\n")
cat("All packages have been installed successfully!\n")
cat("You can now run the Market Simulator by executing: shiny::runApp('app.R')\n")

# Optional: Load all packages to test
cat("\nTesting package loading...\n")
success <- TRUE
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("ERROR: Failed to load package:", pkg, "\n")
    success <- FALSE
  }
}

if (success) {
  cat("✓ All packages loaded successfully!\n")
  cat("The Market Simulator is ready to run.\n")
} else {
  cat("✗ Some packages failed to load. Please check the error messages above.\n")
}