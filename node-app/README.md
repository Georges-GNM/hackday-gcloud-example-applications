Example Node application
========================

> [!IMPORTANT]
> If you take this source code as a template, please change the application name in [APPLICATION_NAME](APPLICATION_NAME).

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

> [!IMPORTANT]
> Please change the application's name in the APPLICATION_NAME file. The name must be unique.

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
