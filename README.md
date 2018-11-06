# autosmk

Auto-generate templates for Snakemake rules and R scripts 


`autosmk` auto generates templates given a list of input and output files for a Snakemake rule passing the inputs/outputs to an R script. For example, if we specify 

```r
inputs <- c(
  'important_csv' = 'data/input_{id}.csv',
  'compressed_R_object' = 'data/input_{id}.rds'
)

outputs <- c(
  'figure' = 'figs/fig_{id}.png'
)
```

as rules for some files and call

```r
dir <- tempdir()

autosmk('testrule',
        inputs,
        outputs,
        dir,
        open = FALSE)
```

then we can generate a template for a Snakemake rule like

```python
rule testrule:
 input:
   important_csv="data/input_{id}.csv",
   compressed_R_object="data/input_{id}.rds"
 output:
   figure="figs/fig_{id}.png"
 shell:
   """
   Rscript testrule.R \
   --important_csv {input.important_csv} \ 
   --compressed_R_object {input.compressed_R_object} \ 
   --figure {output.figure}
   """
```
with the R script to be called
 
```r
library(aargh)



testrule <- function(important_csv = "str",
       compressed_R_object = "str",
       figure = "str") {


}

aargh(testrule)
```


