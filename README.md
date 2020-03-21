oysteR
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

[![CircleCI](https://circleci.com/gh/sonatype-nexus-community/oysteR.svg?style=shield)](https://circleci.com/gh/sonatype-nexus-community/oysteR)

Create purls from the filtered sands of your dependencies, powered by
OSS Index

## Usage

The package has two main functions. The first, function extracts your
installed R packages and uses the Sonatype OSS Index API to scan for
vulnerabilities

``` r
library("oysteR")
audit = audit_deps()
```

To extract the vulnerabilities into a nice data frame, use

``` r
get_vulnerabilities(audit)
```

### Authentication

Heavy use against OSS Index will likely run you into rate limiting
(yikes\!), but you can:

  - Register an account on OSS Index
  - Get your username and API Token after registering

Set the following environment variables in your `.Renviron` file:

  - `OSSINDEX_USER`
  - `OSSINDEX_TOKEN`

These will be used by `oysteR` to authenticate with OSS Index, bumping
up the amount of requests you can make.

### Tests

Our tests are in:

  - `tests/testthat`

You can run tests in R like so:

`devtools::test()`

### CircleCI

Any commit should be run in CircleCI, which will check that:

  - Project builds
  - CRAN Check (`R CMD check`) runs

Successful builds on CircleCI are generally good, make sure to check for
WARNINGS or NOTES from `R CMD check`, however\!

## Contributing

We care a lot about making the world a safer place, and that’s why we
continue to work on this and other plugins for Sonatype OSS Index. If
you as well want to speed up the pace of software development by working
on this project, jump on in\! Before you start work, create a new issue,
or comment on an existing issue, to let others know you are\!

## The Fine Print

It is worth noting that this is **NOT SUPPORTED** by Sonatype, and is a
contribution of ours to the open source community (read: you\!)

Remember:

  - Use this contribution at the risk tolerance that you have
  - Do NOT file Sonatype support tickets related to `oysteR`
  - DO file issues here on GitHub, so that the community can pitch in

Phew, that was easier than I thought. Last but not least of all:

Have fun creating and using this extension and the [Sonatype OSS
Index](https://ossindex.sonatype.org/), we are glad to have you here\!

## Getting help

Looking to contribute to our code but need some help? There’s a few ways
to get information:

  - Chat with us on the [oysteR
    Gitter](https://gitter.im/sonatype-nexus-community/oysteR)
