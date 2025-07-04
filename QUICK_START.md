# 🚀 Quick Start Guide - Market Simulator

This guide will get you up and running with the Market Simulator in just a few steps!

## 📁 What You Have

Your Market Simulator includes these key files:

- **`app.R`** - Main Shiny application
- **`conjoint_functions.R`** - Conjoint analysis functions
- **`market_simulator.R`** - Market simulation functions
- **`install_packages.R`** - R package installer
- **`setup_environment.sh`** - Complete environment setup
- **`sample_conjoint_data.csv`** - Sample data for testing
- **`README.md`** - Complete documentation

## ⚡ 30-Second Setup (If R is already installed)

```bash
# Install R packages
Rscript install_packages.R

# Run the application
R -e "shiny::runApp('app.R')"
```

## 🔧 Complete Setup (Fresh installation)

### Option 1: Automated Setup (Linux/Ubuntu)
```bash
# Run the automated setup script
./setup_environment.sh

# Start the application
R -e "shiny::runApp('app.R')"
```

### Option 2: Manual Setup

#### Step 1: Install R
**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install r-base r-base-dev
```

**macOS:**
```bash
# Install using Homebrew
brew install r

# Or download from: https://cran.r-project.org/bin/macosx/
```

**Windows:**
- Download R from: https://cran.r-project.org/bin/windows/base/
- Install following the setup wizard

#### Step 2: Install System Dependencies (Linux only)
```bash
sudo apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev
```

#### Step 3: Install R Packages
```bash
Rscript install_packages.R
```

#### Step 4: Run the Application
```bash
R -e "shiny::runApp('app.R')"
```

## 🎯 Using the Application

### 1. First Time Setup
1. Open your web browser to `http://localhost:8100` (or the URL shown in terminal)
2. Go to **Data Upload** tab
3. Click **"Generate Sample Conjoint Data"** to create test data
4. Explore the application with the sample data

### 2. With Your Own Data
1. Prepare your choice-based conjoint data in CSV format
2. Use `sample_conjoint_data.csv` as a template
3. Upload your file in the **Data Upload** tab
4. Configure your analysis and run the simulation

### 3. Key Workflow
```
Data Upload → Conjoint Analysis → Market Simulation → Scenario Planning → Reports
```

## 📊 Sample Analysis Workflow

1. **Generate/Upload Data**: Start with sample data or upload your own
2. **Run Conjoint Analysis**: Estimate consumer utilities
3. **Market Simulation**: Define 3-5 products and simulate market
4. **Price Sensitivity**: Analyze how price changes affect share
5. **Scenario Planning**: Test "what-if" scenarios
6. **Generate Reports**: Create executive summaries

## 🔍 Expected Data Format

Your CSV file should have these columns:
- `respondent_id`: Unique ID for each respondent
- `task_id`: Choice task number
- `alternative_id`: Alternative number (1, 2, 3...)
- `choice`: Binary (1 = chosen, 0 = not chosen)
- `brand`, `price`, `color`, `size`: Your product attributes

## 📱 Application Features

### 🎯 Core Analytics
- **Conjoint Analysis**: Multinomial logit modeling
- **Utility Estimation**: Part-worth utilities and importance weights
- **Market Simulation**: Monte Carlo choice simulation
- **Price Optimization**: Sensitivity analysis and pricing insights

### 📈 Visualizations
- Interactive market share charts
- Price sensitivity curves
- Consumer segmentation plots
- Scenario comparison charts

### 🎨 Business Intelligence
- Executive summaries
- Strategic recommendations
- ROI calculations
- Competitive analysis

## 🚨 Troubleshooting

### Common Issues

**"Package installation failed"**
- Ensure internet connection
- Try: `sudo apt-get install r-base-dev` (Linux)
- Install packages individually if needed

**"Cannot find data"**
- Check CSV format matches sample
- Ensure choice column has 0s and 1s
- Verify column names are correct

**"Model convergence failed"**
- Try with sample data first
- Check for sufficient data variation
- Reduce number of attributes

**"Application won't start"**
- Check R version: `R --version`
- Verify all packages installed: `Rscript install_packages.R`
- Try running in R console: `shiny::runApp('app.R')`

## 📞 Need Help?

1. **Check the sample data**: `sample_conjoint_data.csv`
2. **Read full documentation**: `README.md`
3. **Test with sample data first** before using your own
4. **Verify R and packages installed** correctly

## 🎉 Ready to Go!

Your Market Simulator is a powerful tool for:
- **Market Research**: Understanding consumer preferences
- **Product Management**: Optimizing product portfolios
- **Strategy**: Testing market scenarios and pricing
- **Analytics**: Advanced choice modeling and segmentation

**Start exploring consumer behavior and market dynamics today!**

---

💡 **Pro Tip**: Always start with the sample data to familiarize yourself with the application before using your own dataset.