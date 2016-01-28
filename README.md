# Multi-node Multi-core R / Shiny

This demo illustrates how to setup a Multi-node Multi-core R / Shiny server. It uses the ``parallel`` package in R to communicate with workers on other instances. A Shiny app is used to show how to integrate a parallel backend into Shiny.

## Remarks

Shiny server needs a good network connection. A clogged WiFi (high lag, many dropped packages) will make Shiny unresponsive.

## AWS AMI

For the Dallas RUG talk, I created two public AWS AMI’s: 
- ami-c693afae / R-RStudio-Shiny
- ami-042e106c / R-RStudio-Shiny-DallasRUG_2015-04-11

If you intend to use them, please consider editing the ``authorized_keys`` files to remove the public keys which might allow unauthorized access.

I plan to update them soon after R 3.2.0 is being released.

## Folder / File list

- explore_makeCluster/ : step by step code examples to create connections with makeCluster
- mandelbrot_app/ : Shiny app that calculates the area of the Mandelbrot set, uses ``foreach`` package
- presentation/ : slides for the Dallas R Users Group presentation on April 11, 2015
- Local Setup - Windows host.md : Windows Host / Virtual Box Ubuntu detailed setup


## Instructions to set up Multi-node Multi-core R / Shiny
#### Local setup

For the local setup on Windows please see the file
[Local Setup - Windows host.md](/Local%20Setup%20-%20Windows%20host.md#multi-node-multi-core-r--shiny)

Setups for OSX and Linux are not provided here (contributions welcome).


#### Amazon EC2 setup

See slides, detailed instructions to follow.


## Change log
- 2015-04-12 : updated slides, this readme
- 2015-04-11 : slides and code, AWS AMIs (see slides)
- 2015-04-08 : initial commit for the local setup
