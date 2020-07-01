## New Submission
  * Previous submission v0.0.3 was rejected with comments (addressed below)

## Test environments
* local Ubuntu install, R version 4.0.0
* CircleCI, linux, R version 3.6.1 (rocker/verse:3.6.1 image)
* Travis, R old, release, dev
* win-builder

## R CMD check results
There were no ERRORs or WARNINGs. 

There was 1 NOTE on checking CRAN incoming feasibility

## Comments from previous submission

> Thanks, please replace \dontrun{} by \donttest{} in your Rd-files.

Done

> You are using installed.packages():
> "This needs to read several files per installed package, which will be
> slow on Windows and on some network-mounted file systems.
> It will be slow when thousands of packages are installed, so do not use
> it to find out if a named package is installed (use find.package or
> system.file) nor to find out if a package is usable (call
> requireNamespace or require and check the return value) nor to find
> details of a small number of packages (use packageDescription)."
> [installed.packages() help page]

> Please fix and resubmit.

`installed.packages()` is core to this package's functionality - check the users 
installed packages for vulnerabilities. We do __not__ use this to
 * find out if a named package is installed, or
 * find out if a package is usable, or
 * find details of a small number of packages

We use this function to obtain a list of all packages currently installed in order to check
them for known vulnerabilities. When the function is called, we provide a message to the user
stating this may take a while
