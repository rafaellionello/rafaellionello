# Market Simulator with Choice-Based Conjoint Analysis
# Load required libraries
library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(dplyr)
library(ggplot2)
library(viridis)
library(shinyWidgets)
library(readr)
library(purrr)
library(tidyr)

# Source helper functions
source("conjoint_functions.R")
source("market_simulator.R")

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Market Simulator - Choice-Based Conjoint Analysis"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Data Upload", tabName = "data", icon = icon("upload")),
      menuItem("Conjoint Analysis", tabName = "conjoint", icon = icon("chart-line")),
      menuItem("Market Simulation", tabName = "simulation", icon = icon("cogs")),
      menuItem("Scenario Planning", tabName = "scenarios", icon = icon("project-diagram")),
      menuItem("Reports", tabName = "reports", icon = icon("file-alt"))
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .content-wrapper, .right-side {
          background-color: #f4f4f4;
        }
        .box {
          border-top-color: #3c8dbc;
        }
        .nav-tabs-custom > .nav-tabs > li.active {
          border-top-color: #3c8dbc;
        }
      "))
    ),
    
    tabItems(
      # Data Upload Tab
      tabItem(tabName = "data",
        fluidRow(
          box(
            title = "Data Management", status = "primary", solidHeader = TRUE,
            width = 12, collapsible = TRUE,
            
            tabsetPanel(
              tabPanel("Upload Data",
                h4("Upload Choice-Based Conjoint Data"),
                fileInput("file", "Choose CSV File",
                         accept = c(".csv")),
                checkboxInput("header", "Header", TRUE),
                checkboxInput("stringsAsFactors", "Strings as factors", FALSE),
                radioButtons("sep", "Separator",
                           choices = c(Comma = ",", Semicolon = ";", Tab = "\t"),
                           selected = ","),
                radioButtons("quote", "Quote",
                           choices = c(None = "", "Double Quote" = '"', "Single Quote" = "'"),
                           selected = '"'),
                
                br(),
                h4("Or Generate Sample Data"),
                actionButton("generateData", "Generate Sample Conjoint Data", 
                           class = "btn-success"),
                br(), br(),
                verbatimTextOutput("dataInfo")
              ),
              
              tabPanel("Data Preview",
                h4("Data Preview"),
                DT::dataTableOutput("dataPreview")
              ),
              
              tabPanel("Data Summary",
                h4("Data Summary"),
                verbatimTextOutput("dataSummary"),
                
                h4("Attribute Levels"),
                DT::dataTableOutput("attributeSummary")
              )
            )
          )
        )
      ),
      
      # Conjoint Analysis Tab
      tabItem(tabName = "conjoint",
        fluidRow(
          box(
            title = "Conjoint Analysis Setup", status = "primary", solidHeader = TRUE,
            width = 4,
            
            h4("Model Configuration"),
            selectInput("choiceVar", "Choice Variable:", choices = NULL),
            selectInput("respVar", "Respondent ID:", choices = NULL),
            selectInput("altVar", "Alternative ID:", choices = NULL),
            selectInput("attributes", "Attributes:", choices = NULL, multiple = TRUE),
            
            br(),
            actionButton("runConjoint", "Run Conjoint Analysis", 
                       class = "btn-primary"),
            
            br(), br(),
            h4("Model Performance"),
            verbatimTextOutput("modelFit")
          ),
          
          box(
            title = "Utility Estimates", status = "info", solidHeader = TRUE,
            width = 8,
            
            tabsetPanel(
              tabPanel("Part-Worth Utilities",
                plotlyOutput("partWorthPlot", height = "400px")
              ),
              
              tabPanel("Importance Weights",
                plotlyOutput("importancePlot", height = "400px")
              ),
              
              tabPanel("Utility Table",
                DT::dataTableOutput("utilityTable")
              )
            )
          )
        )
      ),
      
      # Market Simulation Tab
      tabItem(tabName = "simulation",
        fluidRow(
          box(
            title = "Market Simulation Controls", status = "primary", solidHeader = TRUE,
            width = 4,
            
            h4("Simulation Parameters"),
            numericInput("numProducts", "Number of Products:", value = 5, min = 2, max = 10),
            numericInput("numConsumers", "Number of Consumers:", value = 1000, min = 100, max = 10000),
            
            h4("Price Range"),
            sliderInput("priceRange", "Price Range ($):", 
                      min = 10, max = 200, value = c(50, 150), step = 5),
            
            h4("Product Configuration"),
            uiOutput("productConfig"),
            
            br(),
            actionButton("runSimulation", "Run Market Simulation", 
                       class = "btn-success")
          ),
          
          box(
            title = "Market Results", status = "info", solidHeader = TRUE,
            width = 8,
            
            tabsetPanel(
              tabPanel("Market Share",
                plotlyOutput("marketSharePlot", height = "400px"),
                br(),
                DT::dataTableOutput("marketShareTable")
              ),
              
              tabPanel("Price Sensitivity",
                plotlyOutput("priceSensitivityPlot", height = "400px")
              ),
              
              tabPanel("Consumer Segments",
                plotlyOutput("segmentPlot", height = "400px")
              )
            )
          )
        )
      ),
      
      # Scenario Planning Tab
      tabItem(tabName = "scenarios",
        fluidRow(
          box(
            title = "Scenario Planning", status = "primary", solidHeader = TRUE,
            width = 4,
            
            h4("What-If Analysis"),
            selectInput("scenarioType", "Scenario Type:",
                      choices = list(
                        "Price Change" = "price",
                        "New Product Launch" = "new_product",
                        "Competitor Action" = "competitor",
                        "Market Expansion" = "expansion"
                      )),
            
            conditionalPanel(
              condition = "input.scenarioType == 'price'",
              selectInput("priceProduct", "Product to Change:", choices = NULL),
              numericInput("newPrice", "New Price ($):", value = 100)
            ),
            
            conditionalPanel(
              condition = "input.scenarioType == 'new_product'",
              h5("New Product Attributes:"),
              uiOutput("newProductAttribs")
            ),
            
            br(),
            actionButton("runScenario", "Run Scenario Analysis", 
                       class = "btn-warning")
          ),
          
          box(
            title = "Scenario Results", status = "info", solidHeader = TRUE,
            width = 8,
            
            tabsetPanel(
              tabPanel("Before vs After",
                plotlyOutput("scenarioComparison", height = "400px")
              ),
              
              tabPanel("Impact Analysis",
                DT::dataTableOutput("impactTable")
              ),
              
              tabPanel("ROI Calculation",
                verbatimTextOutput("roiAnalysis")
              )
            )
          )
        )
      ),
      
      # Reports Tab
      tabItem(tabName = "reports",
        fluidRow(
          box(
            title = "Executive Summary", status = "primary", solidHeader = TRUE,
            width = 12,
            
            h3("Market Simulation Report"),
            verbatimTextOutput("executiveSummary"),
            
            br(),
            downloadButton("downloadReport", "Download Full Report", 
                         class = "btn-info")
          )
        ),
        
        fluidRow(
          box(
            title = "Key Insights", status = "info", solidHeader = TRUE,
            width = 6,
            
            h4("Top Insights"),
            verbatimTextOutput("keyInsights")
          ),
          
          box(
            title = "Recommendations", status = "success", solidHeader = TRUE,
            width = 6,
            
            h4("Strategic Recommendations"),
            verbatimTextOutput("recommendations")
          )
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive values
  values <- reactiveValues(
    data = NULL,
    conjoint_model = NULL,
    utilities = NULL,
    market_results = NULL,
    scenario_results = NULL
  )
  
  # Data upload and management
  observeEvent(input$file, {
    req(input$file)
    
    df <- read.csv(input$file$datapath,
                   header = input$header,
                   sep = input$sep,
                   quote = input$quote,
                   stringsAsFactors = input$stringsAsFactors)
    
    values$data <- df
    
    # Update choice variable options
    updateSelectInput(session, "choiceVar", 
                     choices = names(df),
                     selected = names(df)[1])
    updateSelectInput(session, "respVar", 
                     choices = names(df),
                     selected = names(df)[2])
    updateSelectInput(session, "altVar", 
                     choices = names(df),
                     selected = names(df)[3])
    updateSelectInput(session, "attributes", 
                     choices = names(df)[4:length(names(df))],
                     selected = names(df)[4:min(7, length(names(df)))])
  })
  
  # Generate sample data
  observeEvent(input$generateData, {
    sample_data <- generate_sample_conjoint_data()
    values$data <- sample_data
    
    # Update UI choices
    updateSelectInput(session, "choiceVar", 
                     choices = names(sample_data),
                     selected = "choice")
    updateSelectInput(session, "respVar", 
                     choices = names(sample_data),
                     selected = "respondent_id")
    updateSelectInput(session, "altVar", 
                     choices = names(sample_data),
                     selected = "alternative_id")
    updateSelectInput(session, "attributes", 
                     choices = c("brand", "price", "color", "size"),
                     selected = c("brand", "price", "color", "size"))
  })
  
  # Data outputs
  output$dataInfo <- renderText({
    if (is.null(values$data)) {
      "No data loaded. Please upload a CSV file or generate sample data."
    } else {
      paste("Data loaded successfully!", 
            "\nRows:", nrow(values$data),
            "\nColumns:", ncol(values$data))
    }
  })
  
  output$dataPreview <- DT::renderDataTable({
    req(values$data)
    DT::datatable(values$data, options = list(scrollX = TRUE))
  })
  
  output$dataSummary <- renderPrint({
    req(values$data)
    summary(values$data)
  })
  
  output$attributeSummary <- DT::renderDataTable({
    req(values$data, input$attributes)
    
    attr_summary <- values$data %>%
      select(all_of(input$attributes)) %>%
      summarise_all(~length(unique(.))) %>%
      pivot_longer(everything(), names_to = "Attribute", values_to = "Levels")
    
    DT::datatable(attr_summary, options = list(dom = 't'))
  })
  
  # Conjoint Analysis
  observeEvent(input$runConjoint, {
    req(values$data, input$choiceVar, input$respVar, input$altVar, input$attributes)
    
    withProgress(message = 'Running conjoint analysis...', value = 0, {
      incProgress(0.3, detail = "Fitting model...")
      
      conjoint_results <- run_conjoint_analysis(
        data = values$data,
        choice_var = input$choiceVar,
        resp_var = input$respVar,
        alt_var = input$altVar,
        attributes = input$attributes
      )
      
      incProgress(0.7, detail = "Computing utilities...")
      
      values$conjoint_model <- conjoint_results$model
      values$utilities <- conjoint_results$utilities
      
      incProgress(1, detail = "Complete!")
    })
  })
  
  output$modelFit <- renderPrint({
    if (is.null(values$conjoint_model)) {
      "No model fitted yet. Please run conjoint analysis."
    } else {
      paste("Model successfully fitted!",
            "\nLog-likelihood:", round(logLik(values$conjoint_model), 2),
            "\nAIC:", round(AIC(values$conjoint_model), 2))
    }
  })
  
  output$partWorthPlot <- renderPlotly({
    req(values$utilities)
    create_part_worth_plot(values$utilities)
  })
  
  output$importancePlot <- renderPlotly({
    req(values$utilities)
    create_importance_plot(values$utilities)
  })
  
  output$utilityTable <- DT::renderDataTable({
    req(values$utilities)
    DT::datatable(values$utilities, options = list(pageLength = 15))
  })
  
  # Product configuration UI
  output$productConfig <- renderUI({
    req(input$attributes)
    
    if (length(input$attributes) == 0) return(NULL)
    
    tagList(
      lapply(1:input$numProducts, function(i) {
        wellPanel(
          h5(paste("Product", i)),
          lapply(input$attributes, function(attr) {
            if (attr == "price") {
              numericInput(paste0("prod", i, "_", attr), 
                         paste(attr, ":"), 
                         value = sample(seq(input$priceRange[1], input$priceRange[2], 5), 1))
            } else {
              # For non-price attributes, create dropdown based on data
              if (!is.null(values$data)) {
                choices <- unique(values$data[[attr]])
                selectInput(paste0("prod", i, "_", attr), 
                           paste(attr, ":"), 
                           choices = choices,
                           selected = sample(choices, 1))
              }
            }
          })
        )
      })
    )
  })
  
  # Market Simulation
  observeEvent(input$runSimulation, {
    req(values$utilities, input$numProducts, input$numConsumers)
    
    withProgress(message = 'Running market simulation...', value = 0, {
      incProgress(0.5, detail = "Simulating choices...")
      
      # Collect product configurations
      products <- collect_product_configs(input, input$numProducts, input$attributes)
      
      # Run simulation
      sim_results <- run_market_simulation(
        utilities = values$utilities,
        products = products,
        num_consumers = input$numConsumers
      )
      
      values$market_results <- sim_results
      
      incProgress(1, detail = "Complete!")
    })
  })
  
  output$marketSharePlot <- renderPlotly({
    req(values$market_results)
    create_market_share_plot(values$market_results)
  })
  
  output$marketShareTable <- DT::renderDataTable({
    req(values$market_results)
    DT::datatable(values$market_results$market_share, 
                  options = list(dom = 't')) %>%
      formatPercentage('market_share', 1)
  })
  
  output$priceSensitivityPlot <- renderPlotly({
    req(values$market_results)
    create_price_sensitivity_plot(values$market_results)
  })
  
  output$segmentPlot <- renderPlotly({
    req(values$market_results)
    create_segment_plot(values$market_results)
  })
  
  # Update product choices for scenarios
  observe({
    if (!is.null(values$market_results)) {
      products <- values$market_results$market_share$product
      updateSelectInput(session, "priceProduct", choices = products)
    }
  })
  
  # Scenario planning
  output$newProductAttribs <- renderUI({
    req(input$attributes)
    
    lapply(input$attributes, function(attr) {
      if (attr == "price") {
        numericInput(paste0("new_", attr), 
                   paste(attr, ":"), 
                   value = 100)
      } else {
        if (!is.null(values$data)) {
          choices <- unique(values$data[[attr]])
          selectInput(paste0("new_", attr), 
                     paste(attr, ":"), 
                     choices = choices)
        }
      }
    })
  })
  
  observeEvent(input$runScenario, {
    req(values$market_results)
    
    withProgress(message = 'Running scenario analysis...', value = 0, {
      scenario_results <- run_scenario_analysis(
        base_results = values$market_results,
        scenario_type = input$scenarioType,
        scenario_params = list(
          product = input$priceProduct,
          new_price = input$newPrice
        )
      )
      
      values$scenario_results <- scenario_results
      incProgress(1, detail = "Complete!")
    })
  })
  
  output$scenarioComparison <- renderPlotly({
    req(values$scenario_results)
    create_scenario_comparison_plot(values$scenario_results)
  })
  
  output$impactTable <- DT::renderDataTable({
    req(values$scenario_results)
    DT::datatable(values$scenario_results$impact_summary)
  })
  
  output$roiAnalysis <- renderPrint({
    req(values$scenario_results)
    generate_roi_analysis(values$scenario_results)
  })
  
  # Reports
  output$executiveSummary <- renderPrint({
    if (is.null(values$market_results)) {
      "Please run market simulation to generate executive summary."
    } else {
      generate_executive_summary(values$market_results)
    }
  })
  
  output$keyInsights <- renderPrint({
    if (is.null(values$market_results)) {
      "Please run market simulation to generate insights."
    } else {
      generate_key_insights(values$market_results)
    }
  })
  
  output$recommendations <- renderPrint({
    if (is.null(values$market_results)) {
      "Please run market simulation to generate recommendations."
    } else {
      generate_recommendations(values$market_results)
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)