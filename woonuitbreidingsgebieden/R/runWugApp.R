#' Run the woonuitbreidingsgebieden application
#' @return no return value
#' @importFrom shiny runApp
#' @export
run_wug <- function() {
    appDir <- system.file("shiny-examples", "wug",
                          package = "woonuitbreidingsgebieden")
    if (appDir == "") {
        stop("Could not find example directory.
             Try re-installing `mypackage`.", call. = FALSE)
    }

    runApp(appDir)
}
