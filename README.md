# Market Simulator - Choice-Based Conjoint Analysis

A comprehensive Shiny application for market simulation using choice-based conjoint analysis. This tool enables market researchers, product managers, and business analysts to understand consumer preferences, predict market share, and conduct scenario planning.

## � Features

### Core Capabilities
- **Choice-Based Conjoint Analysis**: Analyze consumer choice data to estimate utility functions
- **Market Simulation**: Predict market share and consumer behavior under different scenarios
- **Price Sensitivity Analysis**: Understand how price changes affect market dynamics
- **Consumer Segmentation**: Identify distinct consumer segments with different preferences
- **Scenario Planning**: Test "what-if" scenarios including price changes and new product launches
- **Executive Reporting**: Generate comprehensive reports with insights and recommendations

### Technical Features
- Interactive web-based interface using Shiny
- Sample data generation for testing and demonstration
- Support for custom conjoint data upload
- Advanced visualizations with Plotly
- Statistical modeling using multinomial logit
- Real-time market simulation

## � Requirements

### R Version
- R 4.0.0 or higher

### Required Packages
The application requires several R packages. Run the installation script to install all dependencies:

```r
source("install_packages.R")
```

Or install manually:
```r
install.packages(c(
  "shiny", "shinydashboard", "shinyWidgets",
  "dplyr", "tidyr", "purrr", "readr",
  "mlogit", "dfidx", "ggplot2", "plotly", 
  "DT", "viridis", "scales", "cluster"
))
```

## 🔧 Installation

1. **Clone or download** this repository
2. **Install dependencies** by running:
   ```r
   source("install_packages.R")
   ```
3. **Launch the application**:
   ```r
   shiny::runApp("app.R")
   ```

## 📖 Usage Guide

### Getting Started

1. **Data Upload**: 
   - Upload your choice-based conjoint data (CSV format) OR
   - Generate sample data to explore the application

2. **Conjoint Analysis**:
   - Configure your model by selecting variables
   - Run the conjoint analysis to estimate utilities
   - Review part-worth utilities and importance weights

3. **Market Simulation**:
   - Define products with different attribute combinations
   - Set market parameters (number of consumers, price ranges)
   - Run simulation to get market share predictions

4. **Scenario Analysis**:
   - Test price changes and their market impact
   - Analyze new product introduction scenarios
   - Compare before/after market dynamics

5. **Reports**:
   - Generate executive summaries
   - Review key insights and strategic recommendations
   - Download comprehensive reports

### Data Format

Your conjoint data should be in CSV format with the following structure:

| respondent_id | task_id | alternative_id | choice | brand | price | color | size |
|---------------|---------|----------------|--------|-------|-------|-------|------|
| 1             | 1       | 1              | 0      | Brand_A | 100  | Red   | Large |
| 1             | 1       | 2              | 1      | Brand_B | 75   | Blue  | Medium |
| 1             | 1       | 3              | 0      | Brand_C | 125  | Green | Small |

**Key columns:**
- `respondent_id`: Unique identifier for each respondent
- `task_id`: Choice task number within respondent
- `alternative_id`: Alternative number within choice task
- `choice`: Binary indicator (1 = chosen, 0 = not chosen)
- Attribute columns: Product attributes (can be categorical or continuous)

## 🎯 Application Sections

### 1. Data Upload
- Upload CSV files with conjoint choice data
- Generate sample data for demonstration
- Preview and validate your data
- View data summaries and attribute levels

### 2. Conjoint Analysis
- Configure model variables
- Run multinomial logit estimation
- View part-worth utilities by attribute level
- Analyze attribute importance weights
- Check model fit statistics

### 3. Market Simulation
- Define competing products
- Set simulation parameters
- View market share predictions
- Analyze price sensitivity curves
- Explore consumer segments

### 4. Scenario Planning
- Price change scenarios
- New product launch analysis
- Competitive response modeling
- ROI calculations
- Impact assessments

### 5. Reports
- Executive summary generation
- Key insights identification
- Strategic recommendations
- Downloadable reports

## � Key Outputs

### Market Share Analysis
- Predicted market share for each product
- Revenue estimates
- Consumer choice probabilities
- Competitive positioning

### Price Sensitivity
- Price elasticity curves
- Optimal pricing insights
- Revenue maximization analysis
- Competitive price response

### Consumer Segmentation
- Segment identification using clustering
- Segment-specific preferences
- Targeted marketing opportunities
- Size and characteristics of each segment

### Scenario Impact
- Before/after comparisons
- Market share cannibalization analysis
- Revenue impact projections
- ROI calculations

## 🔬 Methodology

### Conjoint Analysis
- Uses multinomial logit models (via `mlogit` package)
- Estimates part-worth utilities for each attribute level
- Calculates attribute importance weights
- Supports both categorical and continuous attributes

### Market Simulation
- Monte Carlo simulation of consumer choices
- Individual-level heterogeneity modeling
- Choice probability estimation using logit formula
- Aggregation to market-level predictions

### Consumer Segmentation
- K-means clustering on utility profiles
- Identification of homogeneous preference groups
- Segment-specific choice modeling
- Targeted product positioning

## 🎨 Customization

### Adding New Attributes
1. Ensure your data includes the new attribute columns
2. The application automatically detects categorical vs. continuous variables
3. Utility estimation and visualization will include new attributes

### Modifying Scenarios
Edit `market_simulator.R` to add new scenario types:
- Competitor actions
- Market expansion
- Product feature changes
- Distribution channel impacts

### Custom Visualizations
Modify plotting functions in both helper files to:
- Change color schemes
- Add new chart types
- Customize layouts
- Include additional metrics

## 🚨 Troubleshooting

### Common Issues

1. **Package Installation Errors**:
   - Ensure R is up to date
   - Try installing packages individually
   - Check for system dependencies

2. **Data Upload Problems**:
   - Verify CSV format and column names
   - Check for missing values
   - Ensure choice variable is binary (0/1)

3. **Model Convergence Issues**:
   - Check for sufficient data variation
   - Verify attribute levels have enough observations
   - Consider simplifying the model

4. **Performance Issues**:
   - Reduce number of simulation consumers
   - Limit number of products in simulation
   - Use smaller datasets for testing

### Error Messages

- **"No convergence"**: Model fitting failed, check data quality
- **"Product not found"**: Verify product names in scenario analysis
- **"Insufficient data"**: Need more choice observations for reliable estimates

## 📈 Use Cases

### Market Research
- New product concept testing
- Feature importance analysis
- Price optimization studies
- Competitive analysis

### Product Management
- Portfolio optimization
- Feature prioritization
- Launch strategy planning
- Positioning analysis

### Strategy Consulting
- Market sizing
- Competitive response modeling
- Investment prioritization
- Growth opportunity assessment

### Academic Research
- Consumer behavior studies
- Marketing mix modeling
- Experimental design analysis
- Methodology development

## 🤝 Contributing

Contributions are welcome! Areas for enhancement:
- Additional scenario types
- Advanced segmentation methods
- Machine learning integration
- Real-time data connections
- Mobile-responsive design

## 📄 License

This project is provided as-is for educational and commercial use. Please ensure compliance with your organization's policies regarding open-source software.

## 📞 Support

For questions, suggestions, or issues:
1. Check the troubleshooting section above
2. Review the methodology documentation
3. Examine the sample data format
4. Test with generated sample data first

## 🔄 Version History

### Version 1.0 (Current)
- Initial release with full conjoint analysis capability
- Market simulation and scenario planning
- Executive reporting and insights generation
- Sample data generation for testing

---

**Ready to start analyzing consumer preferences and predicting market dynamics? Run the application and explore the power of choice-based conjoint analysis!**
