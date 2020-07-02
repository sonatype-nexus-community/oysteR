Releasing
=========

Prepare the release
-------------------

  The following steps prepare a release using [R Studio](https://rstudio.com/products/rstudio/download/#download).
  1. From the R Studio `Build` menu, select `Install and Restart`.
  2. From the R Studio `Build` menu, select `Check Package`.


  The following steps prepare a release via CLI on a Mac.

  1. Install R.

         brew install r

  2. Install tex tools. Note: Need to close and reopen terminal (and/or RStudio) to see `pdflatex` on the path.

         brew cask install mactex
       
  3. Install pandoc to check .md files.

         brew install pandoc
    
  4. Install [RStudio](https://rstudio.com/products/rstudio/download/#download).

  5. Open [oysteR.Rproj](../oysteR.Rproj) in RStudio.

  6. Setup devtools.
   In R Console tab, run: `install.packages("devtools")`

  7. Run R Command to build.

         R CMD build .
    
  8. Run R Command to check. (Substitute the correct versioned x.y.x filename.)

         R CMD check oysteR_x.y.z.tar.gz --as-cran

    
  After a successful build/check, submit the `oysteR_x.y.z.tar.gz` file to the [win-builder](https://win-builder.r-project.org/) project to verify it works on Windows. The [upload](https://win-builder.r-project.org/upload.aspx) page worked well for me. Submit the tar.gz to all three R versions: R-release, R-devel, R-oldrelease. (Give the Maintainer a heads up to watch for  results emails from these submissions.)

Perform the release submission to CRAN.
---------------------------------------
  steps?

Post release
------------  
  Create an annotated tag and push it to github.
  
    git tag -a vx.y.z -m "version x.y.z released to CRAN"
    git push --follow-tags

