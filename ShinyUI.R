if (!require("remotes")) install.packages("remotes")
if (!require("shiny")) install.packages("shiny")
if (!require("bslib")) install.packages("bslib")
if (!require("rsconnect")) install.packages("rsconnect")

library(shiny)
library(bslib)
library(rsconnect)

# 2. Install the local folder as a package
# This tells Shinyapps.io to bundle the folder as the source
if (!require("aCePrep")) {
  pkg_url <- "https://github.com/jamesggow08/aCe/raw/main/aCePrep_2.0.1.tar.gz"
  install.packages(pkg_url, repos = NULL, type = "source")
}

library(aCePrep)


ui <- page_sidebar(
  title = "aCePrep Analysis Portal",
  theme = bs_theme(version = 5, bootswatch = "minty"),

  sidebar = sidebar(
    textInput("user_name", "Subject/User Name", placeholder = "e.g., MadhavRamesh"),
    hr(),
    h5("Upload PNG Files"),
    fileInput("file_preT",  "Pre-T Image",  accept = ".png"),
    fileInput("file_postT", "Post-T Image", accept = ".png"),
    fileInput("file_preC",  "Pre-C Image",  accept = ".png"),
    fileInput("file_postC", "Post-C Image", accept = ".png"),
    hr(),
    actionButton("run_proc", "Start Processing", class = "btn-primary"),
    downloadButton("download_results", "Download Results", class = "btn-success")
  ),

  card(
    card_header("Console Output"),
    verbatimTextOutput("status_log")
  ),

  card(
    card_header("Analysis Visualization"),
    layout_column_wrap(
      width = 1/2, # This puts the two graphs side-by-side
      imageOutput("plot_test"),
      imageOutput("plot_control")
    )
  )
)

server <- function(input, output, session) {

  # --- 1. Processing Logic ---
  observeEvent(input$run_proc, {
    # Ensure all files and the name are present before starting
    req(input$user_name, input$file_preT, input$file_postT,
        input$file_preC, input$file_postC)

    name <- input$user_name

    withProgress(message = 'Executing aCePrep Pipeline...', value = 0, {
      tryCatch({
        # Set working directory to temp and ensure we return to app root on exit
        old_dir <- setwd(tempdir())
        on.exit(setwd(old_dir))

        # Stage files: Copy and rename uploads to the working directory
        # Note: aCe_vector.png is bundled inside the aCePrep package (inst/extdata/)
        #       and is loaded automatically -- no upload required.
        file.copy(input$file_preT$datapath,   paste0(name, "_PreT.png"), overwrite = TRUE)
        file.copy(input$file_postT$datapath,  paste0(name, "_PostT.png"), overwrite = TRUE)
        file.copy(input$file_preC$datapath,   paste0(name, "_PreC.png"), overwrite = TRUE)
        file.copy(input$file_postC$datapath,  paste0(name, "_PostC.png"), overwrite = TRUE)

        # Step A: Run Image Processing
        incProgress(0.3, detail = "Processing Images...")
        aCePrep::Image_Process(paste0(name, "_PreT.png"),  paste0(name, "_Pre"),  "T")
        aCePrep::Image_Process(paste0(name, "_PostT.png"), paste0(name, "_Post"), "T")
        aCePrep::Image_Process(paste0(name, "_PreC.png"),  paste0(name, "_Pre"),  "C")
        aCePrep::Image_Process(paste0(name, "_PostC.png"), paste0(name, "_Post"), "C")

        # Step B: Run Analysis
        incProgress(0.4, detail = "Running aCe Analysis...")
        aCePrep::aCe_demo(paste0(name, "_PreT.csv"), paste0(name, "_PostT.csv"), paste0(name, "_test"))
        aCePrep::aCe_demo(paste0(name, "_PreC.csv"), paste0(name, "_PostC.csv"), paste0(name, "_control"))

        # Success Output
        output$status_log <- renderPrint({
          cat("Success! Process Complete for:", name, "\n")
          cat("4 images processed.\n")
          cat("Results are ready for download.")
        })

      }, error = function(e) {
        # Error Output
        output$status_log <- renderPrint({
          cat("Error encountered:\n", e$message, "\n\n")
          cat("Debug Info (Files in Temp):\n")
          print(list.files())
        })
      })

      setProgress(1)
    })
  })

  # --- Updated Download Logic ---
  output$download_results <- downloadHandler(
    filename = function() {
      paste0(input$user_name, "_aCePrep_Results.zip")
    },
    content = function(file) {
      # Switch to temp directory to grab the generated files
      old_dir <- setwd(tempdir())
      on.exit(setwd(old_dir))

      # FIX: Look for the name ANYWHERE in the filename,
      # this catches "ClientGraph_MadhavRamesh..." and "MadhavRamesh_test.csv"
      files_to_zip <- list.files(pattern = input$user_name)

      # Optional: include the vector file in the zip even if it doesn't have the name
      if(file.exists("aCe_vector.png")) {
        files_to_zip <- c(files_to_zip, "aCe_vector.png")
      }

      # Create the zip archive
      # Using extras = "-j" can help prevent folder nesting inside the zip
      zip(file, files = files_to_zip)
    }
  )

  # Output for the Test Graph
  output$plot_test <- renderImage({
    # We use a reactive dependency on the run button so it updates when finished
    req(input$run_proc)

    # Path to the file in the temp directory
    outfile <- file.path(tempdir(), paste0("ClientGraph_", input$user_name, "_test.png"))

    # Return a list containing the filename and alt text
    list(src = outfile,
         contentType = 'image/png',
         width = "100%",
         alt = "Test Group Graph")
  }, deleteFile = FALSE) # Set to FALSE so the file stays for the download handler

  # Output for the Control Graph
  output$plot_control <- renderImage({
    req(input$run_proc)
    outfile <- file.path(tempdir(), paste0("ClientGraph_", input$user_name, "_control.png"))

    list(src = outfile,
         contentType = 'image/png',
         width = "100%",
         alt = "Control Group Graph")
  }, deleteFile = FALSE)
}

shinyApp(ui, server)


