#' Run the woonuitbreidingsgebieden application
#' @return no return value
#' @importFrom shiny runApp
#' @export
run_wog <- function() {
    appDir <- system.file("shiny-examples", "wog",
                          package = "woonuitbreidingsgebieden")
    if (appDir == "") {
        stop("Could not find example directory.
             Try re-installing `mypackage`.", call. = FALSE)
    }

    runApp(appDir)
}
