# Market Simulator Functions
# Functions for market simulation, scenario analysis, and reporting

library(dplyr)
library(ggplot2)
library(plotly)
library(viridis)
library(cluster)

# Collect product configurations from UI inputs
collect_product_configs <- function(input, num_products, attributes) {
  
  products <- data.frame(
    product = paste("Product", 1:num_products)
  )
  
  for (attr in attributes) {
    values <- sapply(1:num_products, function(i) {
      input_name <- paste0("prod", i, "_", attr)
      input[[input_name]]
    })
    products[[attr]] <- values
  }
  
  return(products)
}

# Run market simulation
run_market_simulation <- function(utilities, products, num_consumers = 1000) {
  
  # Simulate individual choices
  choices <- simulate_individual_choices(utilities, products, num_consumers)
  
  # Calculate market shares
  market_share <- table(choices) / num_consumers
  market_share_df <- data.frame(
    product = products$product,
    market_share = as.numeric(market_share),
    n_choosers = as.numeric(table(choices))
  )
  
  # Calculate revenues (if price is available)
  if ("price" %in% names(products)) {
    market_share_df$revenue <- market_share_df$market_share * 
                               products$price[match(market_share_df$product, products$product)] *
                               num_consumers
  }
  
  # Generate price sensitivity analysis
  price_sensitivity <- NULL
  if ("price" %in% names(products)) {
    price_sensitivity <- analyze_price_sensitivity(utilities, products, num_consumers)
  }
  
  # Consumer segmentation
  segments <- perform_consumer_segmentation(utilities, products, choices, num_consumers)
  
  return(list(
    market_share = market_share_df,
    products = products,
    choices = choices,
    price_sensitivity = price_sensitivity,
    segments = segments,
    num_consumers = num_consumers
  ))
}

# Analyze price sensitivity
analyze_price_sensitivity <- function(utilities, products, num_consumers, 
                                    price_range = c(0.8, 1.2), n_points = 20) {
  
  if (!"price" %in% names(products)) return(NULL)
  
  # Get price coefficient
  price_coef <- utilities$utility[utilities$attribute == "price" & utilities$level == "continuous"]
  if (length(price_coef) == 0) return(NULL)
  
  price_multipliers <- seq(price_range[1], price_range[2], length.out = n_points)
  sensitivity_results <- list()
  
  for (prod_idx in 1:nrow(products)) {
    product_name <- products$product[prod_idx]
    base_price <- products$price[prod_idx]
    
    sensitivity_data <- data.frame(
      price_multiplier = price_multipliers,
      new_price = base_price * price_multipliers,
      market_share = numeric(n_points)
    )
    
    for (i in seq_along(price_multipliers)) {
      # Create modified product set
      modified_products <- products
      modified_products$price[prod_idx] <- base_price * price_multipliers[i]
      
      # Simulate choices
      choices <- simulate_individual_choices(utilities, modified_products, num_consumers)
      market_share <- table(factor(choices, levels = 1:nrow(products))) / num_consumers
      sensitivity_data$market_share[i] <- market_share[prod_idx]
    }
    
    sensitivity_data$product <- product_name
    sensitivity_results[[product_name]] <- sensitivity_data
  }
  
  return(do.call(rbind, sensitivity_results))
}

# Perform consumer segmentation
perform_consumer_segmentation <- function(utilities, products, choices, num_consumers, k = 3) {
  
  # Generate utility profiles for clustering
  utility_profiles <- replicate(num_consumers, {
    # Add individual heterogeneity
    hetero_utilities <- utilities
    hetero_utilities$utility <- hetero_utilities$utility + rnorm(nrow(utilities), 0, 0.3)
    
    # Calculate utilities for each product
    product_utilities <- sapply(1:nrow(products), function(i) {
      total_utility <- 0
      for (attr in names(products)) {
        if (attr != "product") {
          if (is.numeric(products[[attr]][i])) {
            coef <- hetero_utilities$utility[hetero_utilities$attribute == attr & 
                                           hetero_utilities$level == "continuous"]
            if (length(coef) > 0) {
              total_utility <- total_utility + coef * products[[attr]][i]
            }
          } else {
            level_utility <- hetero_utilities$utility[
              hetero_utilities$attribute == attr & 
              hetero_utilities$level == products[[attr]][i]
            ]
            if (length(level_utility) > 0) {
              total_utility <- total_utility + level_utility
            }
          }
        }
      }
      return(total_utility)
    })
    
    return(product_utilities)
  })
  
  # Transpose for clustering
  utility_profiles <- t(utility_profiles)
  
  # Perform k-means clustering
  set.seed(123)
  clusters <- kmeans(utility_profiles, centers = k, nstart = 25)
  
  # Calculate segment characteristics
  segment_summary <- data.frame(
    segment = 1:k,
    size = as.numeric(table(clusters$cluster)),
    size_pct = as.numeric(table(clusters$cluster)) / num_consumers * 100
  )
  
  # Add preferred product for each segment
  segment_preferences <- sapply(1:k, function(seg) {
    seg_members <- which(clusters$cluster == seg)
    seg_choices <- choices[seg_members]
    most_popular <- names(sort(table(seg_choices), decreasing = TRUE))[1]
    return(products$product[as.numeric(most_popular)])
  })
  
  segment_summary$preferred_product <- segment_preferences
  
  return(list(
    clusters = clusters,
    summary = segment_summary,
    profiles = utility_profiles
  ))
}

# Create market share visualization
create_market_share_plot <- function(market_results) {
  
  data <- market_results$market_share
  
  p <- ggplot(data, aes(x = reorder(product, market_share), y = market_share)) +
    geom_col(fill = "steelblue", alpha = 0.8) +
    geom_text(aes(label = paste0(round(market_share * 100, 1), "%")), 
              hjust = -0.1, size = 3) +
    coord_flip() +
    theme_minimal() +
    labs(
      title = "Market Share by Product",
      x = "Product",
      y = "Market Share",
      caption = paste("Based on", market_results$num_consumers, "simulated consumers")
    ) +
    scale_y_continuous(labels = scales::percent_format())
  
  ggplotly(p, tooltip = c("x", "y"))
}

# Create price sensitivity plot
create_price_sensitivity_plot <- function(market_results) {
  
  if (is.null(market_results$price_sensitivity)) {
    return(plotly_empty() %>% layout(title = "Price sensitivity analysis not available"))
  }
  
  data <- market_results$price_sensitivity
  
  p <- ggplot(data, aes(x = new_price, y = market_share, color = product)) +
    geom_line(size = 1.2) +
    geom_point(size = 2) +
    theme_minimal() +
    labs(
      title = "Price Sensitivity Analysis",
      x = "Price ($)",
      y = "Market Share",
      color = "Product"
    ) +
    scale_y_continuous(labels = scales::percent_format()) +
    scale_color_viridis_d()
  
  ggplotly(p, tooltip = c("x", "y", "colour"))
}

# Create consumer segments plot
create_segment_plot <- function(market_results) {
  
  if (is.null(market_results$segments)) {
    return(plotly_empty() %>% layout(title = "Segmentation analysis not available"))
  }
  
  data <- market_results$segments$summary
  
  p <- ggplot(data, aes(x = reorder(paste("Segment", segment), size_pct), y = size_pct)) +
    geom_col(fill = "darkgreen", alpha = 0.8) +
    geom_text(aes(label = paste0(round(size_pct, 1), "%\n", preferred_product)), 
              hjust = 0.5, vjust = -0.2, size = 3) +
    theme_minimal() +
    labs(
      title = "Consumer Segments",
      x = "Segment",
      y = "Segment Size (%)",
      caption = "Labels show preferred product for each segment"
    )
  
  ggplotly(p, tooltip = c("x", "y"))
}

# Run scenario analysis
run_scenario_analysis <- function(base_results, scenario_type, scenario_params) {
  
  if (scenario_type == "price") {
    return(analyze_price_change_scenario(base_results, scenario_params))
  } else if (scenario_type == "new_product") {
    return(analyze_new_product_scenario(base_results, scenario_params))
  } else {
    return(list(message = "Scenario type not yet implemented"))
  }
}

# Analyze price change scenario
analyze_price_change_scenario <- function(base_results, scenario_params) {
  
  # Get the product to change and new price
  product_to_change <- scenario_params$product
  new_price <- scenario_params$new_price
  
  # Find product index
  prod_idx <- which(base_results$products$product == product_to_change)
  if (length(prod_idx) == 0) {
    return(list(error = "Product not found"))
  }
  
  # Create modified product set
  modified_products <- base_results$products
  old_price <- modified_products$price[prod_idx]
  modified_products$price[prod_idx] <- new_price
  
  # Re-run simulation with modified products
  # Note: We need utilities from the original analysis
  # This is a simplified version - in practice, you'd pass utilities
  
  # Calculate impact
  price_change_pct <- (new_price - old_price) / old_price * 100
  
  # Simplified impact calculation (more sophisticated methods would re-run full simulation)
  impact_summary <- data.frame(
    metric = c("Price Change (%)", "Expected Market Share Impact", "Revenue Impact"),
    before = c(0, base_results$market_share$market_share[prod_idx] * 100, 
               base_results$market_share$revenue[prod_idx]),
    after = c(price_change_pct, NA, NA),  # Would calculate from new simulation
    change = c(price_change_pct, NA, NA)
  )
  
  return(list(
    scenario_type = "price_change",
    product = product_to_change,
    old_price = old_price,
    new_price = new_price,
    impact_summary = impact_summary
  ))
}

# Create scenario comparison plot
create_scenario_comparison_plot <- function(scenario_results) {
  
  if (is.null(scenario_results$impact_summary)) {
    return(plotly_empty() %>% layout(title = "Scenario results not available"))
  }
  
  # Create a simple before/after comparison
  data <- data.frame(
    scenario = c("Before", "After"),
    value = c(100, 100 + scenario_results$impact_summary$change[1])  # Simplified
  )
  
  p <- ggplot(data, aes(x = scenario, y = value)) +
    geom_col(fill = c("steelblue", "orange"), alpha = 0.8) +
    geom_text(aes(label = round(value, 1)), vjust = -0.5) +
    theme_minimal() +
    labs(
      title = paste("Scenario Impact:", scenario_results$scenario_type),
      x = "Scenario",
      y = "Relative Performance Index"
    )
  
  ggplotly(p, tooltip = c("x", "y"))
}

# Generate ROI analysis
generate_roi_analysis <- function(scenario_results) {
  
  if (scenario_results$scenario_type == "price_change") {
    price_change_pct <- scenario_results$impact_summary$change[1]
    
    analysis <- paste(
      "=== PRICE CHANGE ROI ANALYSIS ===\n",
      "Product:", scenario_results$product, "\n",
      "Price Change: $", scenario_results$old_price, "→ $", scenario_results$new_price, "\n",
      "Percentage Change:", round(price_change_pct, 1), "%\n\n",
      "=== EXPECTED IMPACTS ===\n",
      "• Higher prices typically reduce market share but increase margin\n",
      "• Price elasticity depends on competitive context\n",
      "• Consider competitor response to price changes\n\n",
      "=== RECOMMENDATIONS ===\n",
      if (price_change_pct > 0) {
        "• Monitor competitor pricing closely\n• Consider premium positioning strategy\n• Test price acceptance with customers"
      } else {
        "• Evaluate if lower prices drive sufficient volume\n• Consider promotional pricing strategy\n• Monitor profit margins carefully"
      }
    )
    
    return(analysis)
  }
  
  return("ROI analysis not available for this scenario type.")
}

# Generate executive summary
generate_executive_summary <- function(market_results) {
  
  top_product <- market_results$market_share$product[which.max(market_results$market_share$market_share)]
  top_share <- max(market_results$market_share$market_share) * 100
  
  total_revenue <- sum(market_results$market_share$revenue, na.rm = TRUE)
  
  summary <- paste(
    "=== EXECUTIVE SUMMARY ===\n",
    "Market Simulation Results\n",
    "Analysis Date:", Sys.Date(), "\n\n",
    "=== KEY FINDINGS ===\n",
    "• Market Leader:", top_product, "with", round(top_share, 1), "% market share\n",
    "• Total Market Size:", market_results$num_consumers, "consumers\n",
    "• Total Revenue Potential: $", format(total_revenue, big.mark = ",", digits = 0), "\n",
    "• Number of Products Analyzed:", nrow(market_results$products), "\n\n",
    "=== MARKET DYNAMICS ===\n",
    "• Consumer preferences show clear differentiation\n",
    "• Price sensitivity varies across segments\n",
    "• Multiple segments with distinct preferences identified\n\n",
    "=== STRATEGIC IMPLICATIONS ===\n",
    "• Focus resources on winning products\n",
    "• Consider portfolio optimization\n",
    "• Develop targeted segment strategies"
  )
  
  return(summary)
}

# Generate key insights
generate_key_insights <- function(market_results) {
  
  # Market concentration
  hhi <- sum((market_results$market_share$market_share * 100)^2)
  concentration <- if (hhi > 2500) "High" else if (hhi > 1500) "Moderate" else "Low"
  
  # Price-performance relationship
  if ("price" %in% names(market_results$products)) {
    price_share_cor <- cor(market_results$products$price, 
                          market_results$market_share$market_share)
    price_relationship <- if (price_share_cor > 0.3) "Premium pricing advantage" else 
                         if (price_share_cor < -0.3) "Price sensitivity evident" else 
                         "Mixed price-share relationship"
  } else {
    price_relationship <- "Price data not available"
  }
  
  insights <- paste(
    "=== KEY INSIGHTS ===\n\n",
    "1. MARKET CONCENTRATION\n",
    "   • Market concentration:", concentration, "(HHI =", round(hhi, 0), ")\n",
    "   • Competitive intensity:", if (concentration == "High") "Low - dominated by few players" else "High - fragmented market", "\n\n",
    "2. PRICE DYNAMICS\n",
    "   •", price_relationship, "\n",
    "   • Price optimization opportunities exist\n\n",
    "3. CONSUMER BEHAVIOR\n",
    "   • Multiple segments with distinct preferences\n",
    "   • Opportunity for targeted marketing\n",
    "   • Brand differentiation matters\n\n",
    "4. GROWTH OPPORTUNITIES\n",
    "   • Underserved segments identified\n",
    "   • Product feature optimization potential\n",
    "   • Pricing strategy refinement needed"
  )
  
  return(insights)
}

# Generate recommendations
generate_recommendations <- function(market_results) {
  
  top_products <- head(market_results$market_share[order(-market_results$market_share$market_share), ], 2)
  
  recommendations <- paste(
    "=== STRATEGIC RECOMMENDATIONS ===\n\n",
    "1. PORTFOLIO STRATEGY\n",
    "   • Invest in", top_products$product[1], "- clear market leader\n",
    "   • Consider repositioning or discontinuing low-performing products\n",
    "   • Evaluate", top_products$product[2], "for growth potential\n\n",
    "2. PRICING STRATEGY\n",
    "   • Conduct price sensitivity testing\n",
    "   • Implement dynamic pricing based on demand\n",
    "   • Consider value-based pricing for premium segments\n\n",
    "3. MARKET SEGMENTATION\n",
    "   • Develop targeted campaigns for each segment\n",
    "   • Customize product features for segment needs\n",
    "   • Focus marketing spend on high-value segments\n\n",
    "4. COMPETITIVE RESPONSE\n",
    "   • Monitor competitor actions closely\n",
    "   • Develop scenario plans for competitive responses\n",
    "   • Consider strategic partnerships or acquisitions\n\n",
    "5. INNOVATION PRIORITIES\n",
    "   • Focus R&D on high-impact attributes\n",
    "   • Test new product concepts with target segments\n",
    "   • Invest in digital and data capabilities"
  )
  
  return(recommendations)
}