GCloud example apps
===================

Example applications for getting up and running in Google Cloud using our two main languages - [Node](https://nodejs.org/en) and [Scala](https://www.scala-lang.org/). These are templates you can use as a reference, you can fork the repository to work on your own version of the templates or take the Node/Scala example as a starting point for your own fresh repository.

> [!IMPORTANT]
> Your app will need to use a different service name to the example project, which means editing the APPLICATION_NAME file in your your choice of the scala/node example.

## Initial setup

Ideally you'll have done this ahead of the hack day, these steps are required to be able to deploy your app to Google Cloud.

You will need to:
- install the `gcloud` CLI tool
- authenticate `gcloud` with your work Guardian account
- configure `gcloud` to use the hackday's Google Cloud project
- configure Docker to use gcloud to authenticate Google's container registry

**Full instructions for these steps are in the hack day engineering guidance document**.

## Application name

In each example, the `APP_NAME` file is used to centralize the configuration of your application's name. This ensures consistency for local development, deployment and in Google Cloud, without having to change the name in multiple places.

This value is used as the Cloud Run service name, so **it must be unique** to your application. Change the default name i the file to the name you'd like to use.

    my-app-name

Please avoid spaces or special characters. If the name is not unique, deployment may fail or overwrite an existing service in Google Cloud.

## Node app

An example node application and documentation for running and deploying it can be found in the [node-app](./node-app/) directory.

## Scala app

An example Scala application and documentation for running and deploying it can be found in the [scala-app](./scala-app/) directory.
