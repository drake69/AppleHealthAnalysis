#' @title "ah_shiny" - Creates a Shiny dashboard for data analysis
#'
#' @description Creates a Shiny dashboard for data analysis
#'
#' @author Deepankar Datta <deepankardatta@nhs.net>
#'
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#'
#' @param health_data A data frame containing extracted health data, in a format generated by the ah_import_xml.r function
#'
#' @examples
#' # ah_shiny( health_data )
#'
#' @export

ah_shiny <- function(health_data) {

  # Makes a list of the type factors, aka the health data variables measured
  ah_type_list <- levels(health_data$type)

  shiny::shinyApp(
    ui = shiny::fluidPage(
      shiny::titlePanel("Apple Health Analysis Shiny Dashboard"),

      shiny::sidebarLayout(
        shiny::sidebarPanel(

          #dateRangeInput start

          # A decision was made not to make this a reactice element (yet!)
          # This is a design decision: it seems more useful to have the date
          # ranges set for global data, than re-do the date ranges for each
          # individual health variable when selected

          shiny::dateRangeInput( inputId = "dates_to_explore",
                          label = "Dates to explore: ",
                          start = NULL,
                          end = NULL,
                          min = NULL,
                          max = NULL,
                          format = "yyyy-mm-dd",
                          startview = "month",
                          weekstart = 1,
                          language = "en",
                          separator = " to "),

          # END

          #Health data variable selection drop box

          shiny::selectInput( inputId = "health_variable",
                       label = "Choose a health variable to display",
                       choices = ah_type_list, # End of choices
                       selected = "HeartRate",
                       multiple = FALSE,
                       selectize = TRUE)

          #END

          # Could also consider putting a file input and export box here

          ),

        shiny:: mainPanel( # Start of Shiny dashboard output
          shiny::textOutput("selected_var"),
          shiny::plotOutput("ah_plot")
          )
      )
    ),
    server = function(input, output) {

      # Test as per Shiny examples
      output$selected_var <- shiny::renderText({
        paste("You have viewing a plot of ", input$health_variable,
              " from ", input$dates_to_explore[1], " to ", input$dates_to_explore[2])
      })

      # Use the Shiny reactive function to filter to the variable the user wants
      data_to_plot <- shiny::reactive({

        health_data %>%
          dplyr::filter( .data$type == input$health_variable ) %>%
          dplyr::filter( .data$date >= input$dates_to_explore[1] & .data$date <= input$dates_to_explore[2] )

      })

      # The plot generation output
      output$ah_plot <- shiny::renderPlot({
        ah_plot <- ggplot2::ggplot(data_to_plot(), ggplot2::aes(x = .data$date, y = .data$value)) +
          ggplot2::geom_point() +
          ggplot2::theme_grey() +
          ggplot2::labs(x="Date", y=input$health_variable)
        ah_plot
      })
    }
  )
}
