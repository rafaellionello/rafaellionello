# Conjoint Analysis Functions
# Functions for choice-based conjoint analysis, utility estimation, and visualization

library(mlogit)
library(dfidx)
library(ggplot2)
library(plotly)
library(dplyr)
library(tidyr)

# Generate sample choice-based conjoint data
generate_sample_conjoint_data <- function(
  n_respondents = 200, 
  n_tasks = 8, 
  n_alternatives = 3
) {
  
  # Define attribute levels
  brands <- c("Brand_A", "Brand_B", "Brand_C", "Brand_D")
  colors <- c("Red", "Blue", "Green", "Black")
  sizes <- c("Small", "Medium", "Large")
  prices <- c(50, 75, 100, 125, 150)
  
  # True population utilities (for simulation)
  true_utilities <- list(
    brand = c("Brand_A" = 0.5, "Brand_B" = 0.3, "Brand_C" = -0.2, "Brand_D" = -0.6),
    color = c("Red" = 0.2, "Blue" = 0.1, "Green" = -0.1, "Black" = -0.2),
    size = c("Small" = -0.3, "Medium" = 0.1, "Large" = 0.2),
    price = -0.02  # Price coefficient (negative = price sensitivity)
  )
  
  # Generate design matrix
  design_list <- list()
  choice_data <- data.frame()
  
  set.seed(123)  # For reproducibility
  
  for (resp in 1:n_respondents) {
    for (task in 1:n_tasks) {
      
      # Generate alternatives for this choice task
      task_data <- data.frame(
        respondent_id = resp,
        task_id = task,
        alternative_id = 1:n_alternatives,
        brand = sample(brands, n_alternatives, replace = TRUE),
        color = sample(colors, n_alternatives, replace = TRUE),
        size = sample(sizes, n_alternatives, replace = TRUE),
        price = sample(prices, n_alternatives, replace = TRUE)
      )
      
      # Calculate utilities for each alternative
      utilities <- sapply(1:n_alternatives, function(alt) {
        brand_util <- true_utilities$brand[task_data$brand[alt]]
        color_util <- true_utilities$color[task_data$color[alt]]
        size_util <- true_utilities$size[task_data$size[alt]]
        price_util <- true_utilities$price * task_data$price[alt]
        
        # Add individual heterogeneity
        heterogeneity <- rnorm(1, 0, 0.5)
        
        return(brand_util + color_util + size_util + price_util + heterogeneity)
      })
      
      # Add error term and make choice
      error_terms <- rgumbel(n_alternatives, 0, 1)  # Gumbel errors for logit
      total_utilities <- utilities + error_terms
      chosen_alt <- which.max(total_utilities)
      
      # Mark choice
      task_data$choice <- ifelse(1:n_alternatives == chosen_alt, 1, 0)
      
      choice_data <- rbind(choice_data, task_data)
    }
  }
  
  return(choice_data)
}

# Gumbel distribution random generation
rgumbel <- function(n, location = 0, scale = 1) {
  location - scale * log(-log(runif(n)))
}

# Run choice-based conjoint analysis
run_conjoint_analysis <- function(data, choice_var, resp_var, alt_var, attributes) {
  
  # Prepare data for mlogit
  # Create individual index
  data$individual <- data[[resp_var]]
  data$choice_situation <- paste(data[[resp_var]], 
                                seq_along(data[[resp_var]]) %/% 
                                length(unique(data[[alt_var]])), sep = "_")
  
  # Convert to dfidx format
  mlogit_data <- dfidx(data, 
                       choice = choice_var, 
                       idx = list(c("choice_situation", "individual"), alt_var),
                       drop.unused.levels = TRUE,
                       levels = unique(data[[alt_var]]))
  
  # Create formula
  formula_parts <- c()
  
  for (attr in attributes) {
    if (is.numeric(data[[attr]])) {
      # Continuous variables (like price)
      formula_parts <- c(formula_parts, attr)
    } else {
      # Categorical variables - create dummy variables
      levels <- unique(data[[attr]])
      if (length(levels) > 1) {
        # Use all levels except the first (reference category)
        for (level in levels[-1]) {
          var_name <- paste0(attr, level)
          mlogit_data[[var_name]] <- ifelse(mlogit_data[[attr]] == level, 1, 0)
          formula_parts <- c(formula_parts, var_name)
        }
      }
    }
  }
  
  # Create formula
  formula_str <- paste("choice ~ 0 +", paste(formula_parts, collapse = " + "))
  formula_obj <- as.formula(formula_str)
  
  # Fit model
  model <- mlogit(formula_obj, data = mlogit_data)
  
  # Extract utilities
  utilities <- extract_utilities(model, attributes, data)
  
  return(list(
    model = model,
    utilities = utilities,
    data = mlogit_data
  ))
}

# Extract and format utility estimates
extract_utilities <- function(model, attributes, original_data) {
  
  coefficients <- coef(model)
  
  utilities_list <- list()
  
  for (attr in attributes) {
    if (is.numeric(original_data[[attr]])) {
      # For continuous variables
      utilities_list[[attr]] <- data.frame(
        attribute = attr,
        level = "continuous",
        utility = coefficients[attr],
        std_error = sqrt(diag(vcov(model)))[attr]
      )
    } else {
      # For categorical variables
      levels <- unique(original_data[[attr]])
      attr_utilities <- data.frame(
        attribute = attr,
        level = levels[1],  # Reference category
        utility = 0,  # Reference level utility = 0
        std_error = 0
      )
      
      # Add other levels
      for (level in levels[-1]) {
        var_name <- paste0(attr, level)
        if (var_name %in% names(coefficients)) {
          attr_utilities <- rbind(attr_utilities, data.frame(
            attribute = attr,
            level = level,
            utility = coefficients[var_name],
            std_error = sqrt(diag(vcov(model)))[var_name]
          ))
        }
      }
      
      utilities_list[[attr]] <- attr_utilities
    }
  }
  
  # Combine all utilities
  all_utilities <- do.call(rbind, utilities_list)
  rownames(all_utilities) <- NULL
  
  return(all_utilities)
}

# Create part-worth utilities plot
create_part_worth_plot <- function(utilities) {
  
  # Filter out continuous variables for this plot
  plot_data <- utilities %>%
    filter(level != "continuous") %>%
    mutate(
      lower_ci = utility - 1.96 * std_error,
      upper_ci = utility + 1.96 * std_error
    )
  
  p <- ggplot(plot_data, aes(x = level, y = utility, fill = attribute)) +
    geom_col(position = "dodge", alpha = 0.8) +
    geom_errorbar(aes(ymin = lower_ci, ymax = upper_ci), 
                  width = 0.2, position = position_dodge(0.9)) +
    facet_wrap(~attribute, scales = "free_x") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(
      title = "Part-Worth Utilities by Attribute",
      x = "Attribute Level",
      y = "Utility",
      fill = "Attribute"
    ) +
    scale_fill_viridis_d()
  
  ggplotly(p, tooltip = c("x", "y"))
}

# Create importance weights plot
create_importance_plot <- function(utilities) {
  
  # Calculate importance weights
  importance <- utilities %>%
    filter(level != "continuous") %>%
    group_by(attribute) %>%
    summarise(
      range = max(utility) - min(utility),
      .groups = 'drop'
    ) %>%
    mutate(
      importance = range / sum(range) * 100
    ) %>%
    arrange(desc(importance))
  
  p <- ggplot(importance, aes(x = reorder(attribute, importance), y = importance)) +
    geom_col(fill = "steelblue", alpha = 0.8) +
    coord_flip() +
    theme_minimal() +
    labs(
      title = "Attribute Importance Weights",
      x = "Attribute",
      y = "Importance (%)",
      caption = "Based on utility range within each attribute"
    )
  
  ggplotly(p, tooltip = c("x", "y"))
}

# Calculate choice probabilities for a set of alternatives
calculate_choice_probabilities <- function(utilities, alternatives) {
  
  # Calculate utility for each alternative
  alt_utilities <- sapply(1:nrow(alternatives), function(i) {
    total_utility <- 0
    
    for (attr in names(alternatives)) {
      if (attr %in% utilities$attribute) {
        if (is.numeric(alternatives[[attr]][i])) {
          # Continuous variable
          coef <- utilities$utility[utilities$attribute == attr & utilities$level == "continuous"]
          if (length(coef) > 0) {
            total_utility <- total_utility + coef * alternatives[[attr]][i]
          }
        } else {
          # Categorical variable
          level_utility <- utilities$utility[
            utilities$attribute == attr & utilities$level == alternatives[[attr]][i]
          ]
          if (length(level_utility) > 0) {
            total_utility <- total_utility + level_utility
          }
        }
      }
    }
    
    return(total_utility)
  })
  
  # Convert to probabilities using logit formula
  exp_utilities <- exp(alt_utilities)
  probabilities <- exp_utilities / sum(exp_utilities)
  
  return(probabilities)
}

# Simulate individual choices with heterogeneity
simulate_individual_choices <- function(utilities, alternatives, n_individuals = 1000) {
  
  choices <- replicate(n_individuals, {
    # Add individual heterogeneity to utilities
    hetero_utilities <- utilities
    hetero_utilities$utility <- hetero_utilities$utility + rnorm(nrow(utilities), 0, 0.3)
    
    # Calculate probabilities
    probs <- calculate_choice_probabilities(hetero_utilities, alternatives)
    
    # Make choice
    sample(1:nrow(alternatives), 1, prob = probs)
  })
  
  return(choices)
}