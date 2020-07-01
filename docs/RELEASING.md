Releasing
=========

The following steps were required to release using R Studio.

1. From the R Studio `Build` menu, select `Install and Restart`.

2. From the R Studio `Build` menu, select `Check Package`.


The following steps were required to releash to CRAN using a Mac. (Currently using branch: `CRANTryTwo`)

1. Install R.

       brew install r

2. Install tex tools. Note: Need to close and reopen terminal (and/or RStudio) to see `pdflatex` on the path.

       brew cask install mactex
       
3. Install pandoc to check .md files.

       brew install pandoc
    
4. Install [RStudio](https://rstudio.com/products/rstudio/download/#download).

5. Open [oysteR.Rproj](../oysterR.Rproj) in RStudio.

6. Setup devtools.

   In R Console tab, run: `install.packages("devtools")`

7. Run R Command to build.

       R CMD build .
    
8. Run R Command to check.

       R CMD check *tar.gz --as-cran
    
