Releasing
=========

The following steps were required to releash to CRAN using a Mac. (Currently using branch: `CRANTryTwo`)

1. Install R.

       brew install r

2. Install tex tools. Note: Need to close and reopen terminal (and/or RStudio) to see `pdflatex` on the path.

       brew cask install mactex
       
2. Install pandoc to check .md files.

       brew install pandoc
    
2. Install [RStudio](https://rstudio.com/products/rstudio/download/#download).

3. Open [oysteR.Rproj](../oysterR.Rproj) in RStudio.

4. Setup devtools.

   In R Console tab, run: `install.packages("devtools")`

5. Run R Command to build.

       R CMD build .
    
6. Run R Command to check.

       R CMD check *tar.gz --as-cran
    
