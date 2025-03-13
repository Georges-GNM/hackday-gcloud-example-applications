GCloud example apps
===================

Example application for getting up and running in Google Cloud.

There are two example apps, showing a hello world application in our two main language toolchains - Node and Scala.

These are templates you can use as a reference for getting started, we recommend taking these as a starting point.

**NOTE:** your app will need to use a different service name, which means editing the deploy script.

## Initial setup

Ideally you'll have done this ahead of the hack day, but these steps are required to be able to deploy these apps to Google Cloud.

You will need to:
- install the `gcloud` CLI tool
- authenticate `gcloud` with your work Guardian account
- configure `gcloud` to use the hackday's Google Cloud project
- configure Docker to authenticate with Google Cloud's container

Instructions for these steps should be in the hack day engineering guidance.

## Node app

An example node application can be found in the [node-app](./node-app/) directory.

If you take this source code as a template, please change the app-specific configuration in [deploy.sh](./node-app/scripts/deploy.sh).

This app uses [Google's "functions framework" node package](https://github.com/GoogleCloudPlatform/functions-framework-nodejs). This provides an Express-based framework for writing HTTP handlers that can be run locally or in Google Cloud.

### Setup

```shell
$ npm install
```

### Running locally

```shell
$ npm run start
```

Your service will be running at [http://localhost:8080](http://localhost:8080).

### Deploying to Google Cloud

Note: please change the `IMAGE_NAME` and `SERVICE_NAME` in the deploy script to match your own application before deploying. These must be unique.

The example includes a deploy script, which will:

- package your application as a container using the included Dockerfile
- push the built image to Google's Artifact Registry
- deploy this container to [GCloud's Cloud Run](https://cloud.google.com/run)

You can execute the script using npm.

```shell
$ npm run deploy
```

After this finishes:
- your service should be publicly available on the internet (the URL will be printed to the console)
- your application image will be in [Google's Artifact Registry](https://console.cloud.google.com/artifacts/docker/hackday-2025-support/europe/eu.gcr.io?project=hackday-2025-support)
- you should see your service in the [Cloud Run console](https://console.cloud.google.com/run?project=hackday-2025-support)
- you can explore the service's logs and settings from its entry in the Cloud Run console, above

## Scala app

An example Scala application can be found in the [scala-app](./scala-app/) directory.

If you take this source code as a template, please change the app-specific configuration in [deploy.sh](./scala-app/scripts/deploy.sh).

### Running locally

You can simply run `sbt run` to start the app, but for a better developer experience you can use the following workflow.

```shell
# Open an sbt shell
$ sbt
# start the server and watch for changes
> ~reStart
# stop the server
> reStop
```

Your service will be running at [http://localhost:8080](http://localhost:8080).

### Deploying to Google Cloud

Note: please change the `IMAGE_NAME` and `SERVICE_NAME` in the deploy script to match your own application before deploying. These must be unique.

The example includes a deploy script, which will:
- package your application as a container using sbt
- push the built image to Google's Artifact Registry
- deploy this container to [GCloud's Cloud Run](https://cloud.google.com/run)

Run the script from the root of the scala-app project.

```shell
$ ./scripts/deploy.sh
```

After this finishes:
- your service should be publicly available on the internet (the URL will be printed to the console)
- your application image will be in [Google's Artifact Registry](https://console.cloud.google.com/artifacts/docker/hackday-2025-support/europe/eu.gcr.io?project=hackday-2025-support)
- you should see your service in the [Cloud Run console](https://console.cloud.google.com/run?project=hackday-2025-support)
- you can explore the service's logs and settings from its entry in the Cloud Run console, above

### Choice of webserver library

We typically use the Play framework for Scala applications, but this is complex to set up for a hackday and not a great fit for Cloud Run's architecture. Instead, this demo app uses [Tapir](https://tapir.softwaremill.com/en/latest/) to create a simple webserver definition.

Using Tapir this way also gives us the ability to automatically generate API documentation for the application, which you will see at `/docs` on your running service.
