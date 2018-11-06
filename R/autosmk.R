
#' Generate template for Snakemake & R workflow
#'
#' @param name Name of the Snakemake rule and R function to be created
#' @param inputs A named list of inputs; see details below
#' @param outputs A named list of outputs; see details below
#' @param directory The directory to write the output files to
#' @param open Logical - should the generated files be opened for editing? Default \code{TRUE}
#'
#' @importFrom utils file.edit
#' @export
#'
#' @examples
#' inputs <- c('cool_csv' = 'data/input.csv')
#' outputs <- c('amazing_figure' = 'figs/figure.png')
#' autosmk('example_rule', inputs, outputs, tempdir(), open = FALSE)
#'
#'
autosmk <- function(name,
                    inputs = NULL,
                    outputs = NULL,
                    directory = ".",
                    open = TRUE) {

  sanitize_inputs(name, inputs, outputs, directory)

  snakefile <- write_snake(name, inputs, outputs, directory)
  Rfile <- write_R(name, inputs, outputs, directory)

  if(open) {
    file.edit(snakefile)
    file.edit(Rfile)
  }

}

#' Sanitize the inputs to the main functions
#' @keywords internal
sanitize_inputs <- function(name,
                            inputs = NULL,
                            outputs = NULL,
                            directory = ".") {
  # Check input and output have unique names
  input_names <- names(inputs)
  output_names <- names(outputs)

  if(is.null(input_names) || is.null(output_names)) {
    stop("inputs and outputs must both be (uniquely) named vectors")
  }

  if(length(intersect(input_names, output_names)) > 0) {
    stop("names if inputs and outputs must collectively be unique")
  }

  if(!dir.exists(directory)) {
    print(paste("Directory", directory, "does not exist, attempting to create"))
    dir.create(directory)
  }

}

#' Write the R file using inputs
#' @keywords internal
write_R <- function(name,
                    inputs = NULL,
                    outputs = NULL,
                    directory = ".") {

  input_names <- names(inputs)
  output_names <- names(outputs)

  names <- c(input_names, output_names)

  args <- paste0(names, " = \"str\"")
  args <- paste0(args, collapse = ",\n        ")

  r_str <- rfile_template()

  r_str <- gsub("FNAME", name, r_str)
  r_str <- sub("ARGS", args, r_str)

  output_file <- file.path(directory, paste0(name, ".R"))

  readr::write_file(r_str, output_file)

  output_file

}

write_snake <- function(
  name,
  inputs = NULL,
  outputs = NULL,
  directory = ".") {

  input_names <- names(inputs)
  output_names <- names(outputs)

  # Snakemake file
  input_str <- paste0("\"", inputs, "\"")
  output_str <- paste0("\"", outputs, "\"")

  input_str_rule <- paste0(input_names, "=", input_str)
  input_str_rule <- paste0(input_str_rule, collapse = ",\n    ")

  output_str_rule <- paste0(output_names, "=", output_str)
  output_str_rule <- paste0(output_str_rule, collapse = ",\n    ")

  cmd_in <- paste0("--", input_names, " {input.", input_names, "}")
  cmd_out <- paste0("--", output_names, " {output.", output_names, "}")

  cmd <- paste0(c(cmd_in, cmd_out), collapse = " \\\\ \n    ")

  snk_str <- snkmake_template()

  snk_str <- gsub("NAME", name, snk_str)
  snk_str <- sub("INPUTS", input_str_rule, snk_str)
  snk_str <- sub("OUTPUTS", output_str_rule, snk_str)
  snk_str <- sub("ARGS", cmd, snk_str)

  output_file <- file.path(directory, paste0(name, ".smk"))

  readr::write_file(snk_str, output_file)

  output_file
}


#' Template for the R file
#' @keywords internal
rfile_template <- function() {

  "library(aargh)



FNAME <- function(ARGS) {


}

aargh(FNAME)
  "

}

#' Template for the snakemake rule
#'
#' @keywords internal
snkmake_template <- function() {

  "rule NAME:
  input:
    INPUTS
  output:
    OUTPUTS
  shell:
    \"\"\"
    Rscript NAME.R \\
    ARGS
    \"\"\"
"
}

