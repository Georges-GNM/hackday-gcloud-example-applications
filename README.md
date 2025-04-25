GCloud example apps
===================

Example applications for getting up and running in Google Cloud using our two main languages - [Node](https://nodejs.org/en) and [Scala](https://www.scala-lang.org/). These are templates you can use as a reference for getting started, we recommend taking these as a starting point.

> [!IMPORTANT]
> Your app will need to use a different service name to the example project, which means editing the deploy script.

## Initial setup

Ideally you'll have done this ahead of the hack day, these steps are required to be able to deploy your app to Google Cloud.

You will need to:
- install the `gcloud` CLI tool
- authenticate `gcloud` with your work Guardian account
- configure `gcloud` to use the hackday's Google Cloud project
- configure Docker to use gcloud to authenticate Google's container registry

Full instructions for these steps are in the hack day engineering guidance document.

## Node app

An example node application and documentation for running and deploying it can be found in the [node-app](./node-app/) directory.

## Scala app

An example Scala application and documentation for running and deploying it can be found in the [scala-app](./scala-app/) directory.
