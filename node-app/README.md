Example Node application
========================

> [!IMPORTANT]
> If you take this source code as a template, please change the application name in [APP_NAME](APP_NAME).

This app uses [Google's "functions framework" node package](https://github.com/GoogleCloudPlatform/functions-framework-nodejs). This provides an Express-based framework for writing HTTP handlers that can be run locally or in Google Cloud.

## Setup

```shell
$ npm install
```

## Running locally

```shell
$ npm run start
```

Your service will be running at [http://localhost:8080](http://localhost:8080).

## Deploying to Google Cloud

> [!IMPORTANT]
> Please change the application's name in the APP_NAME file. The name must be unique.

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

## Secrets

The Content API KEY for this hackday has been made available to the application as a secret in Google Cloud. You can read it from your application's environment as `CAPI_API_KEY`.

When running the application locally, you can add `CAPI_API_KEY` to the environment so it matches production, either by exporting it from your shell or adding it to the start command.

```shell
$ export CAPI_API_KEY="???"
$ npm run start
```

```shell
$ CAPI_API_KEY="???" npm run start
```

### Adding your own secret

To add other secrets to your application, follow these steps:

1. Create a new secret in Secrets Manager.
2. Add it to your application's environment by editing your deploy script.
3. Re-deploy your application by running the deploy script.

Step by step, we create a secret in Google's Secret Manager and then populate the secret with the correct value.

```shell
$ gcloud secrets create MY_APP_SECRET --replication-policy="automatic"
$ echo -n "???" | gcloud secrets versions add MY_APP_SECRET --data-file=-
```

Then we add an environment variable called `MY_APP_SECRET` to your application's deploy script. The environment variable is populated from the latest value of a secret called `MY_APP_SECRET` in Google's Secret Manager (which we created above).

```diff
   --allow-unauthenticated \
+  --update-secrets "MY_APP_SECRET=MY_APP_SECRET:latest" \
   --update-secrets "CAPI_API_KEY=CAPI_API_KEY:latest"
```

Finally, we re-deploy the application by running the deploy script.

```shell
$ npm run deploy
```

**Please ensure your secrets are uniquely named**, since we're all using a shared hack day project.
