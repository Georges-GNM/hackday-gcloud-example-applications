Example Scala application
=========================

> [!IMPORTANT]
> If you take this source code as a template, please change the application's name in [APP_NAME](APP_NAME).

> [!WARNING]
> This project requires Java 21. If you are using [mise](https://mise.jdx.dev/) to manage dev tools this will be handled for you, otherwise please ensure Java 21 is installed and active.

## Running locally

You can run `sbt run` to start the app, but for a better developer experience you can use the following workflow.

```shell
# Open an sbt shell
$ sbt
# start the server and watch for changes - it will automatically reload
> ~reStart
# stop the server
> reStop
```

Your service will be running at [http://localhost:8080](http://localhost:8080).

## Deploying to Google Cloud

> [!IMPORTANT]
> Please change the application name in the [APP_NAME](APP_NAME) file. The name must be unique.

The example includes a deploy script, which will:
- package your application as a container using sbt
- push the built image to Google's Artifact Registry
- deploy this container to [GCloud's Cloud Run](https://cloud.google.com/run)

First make sure docker is running (e.g. by starting Docker Desktop).

Run the deploy script from the root of the scala-app project.

```shell
$ ./scripts/deploy.sh
```

After this finishes:
- your application image will be in [Google's Artifact Registry](https://console.cloud.google.com/artifacts/docker/hackday-2025-support/europe/eu.gcr.io?project=hackday-2025-support)
- you should see your service in the [Cloud Run console](https://console.cloud.google.com/run?project=hackday-2025-support)
- your service should be publicly available on the internet (the URL will have been printed to the console)
- you can explore the service's logs and settings from its entry in the Cloud Run console, above

## Choice of webserver library

We typically use the [Play framework](https://www.playframework.com/) for Scala applications, but this is complex to set up for a hackday and is not a great fit for Cloud Run's architecture. Instead, this demo app uses [Tapir](https://tapir.softwaremill.com/en/latest/) to create a simple webserver definition. We avoid the use of `Future` by choosing a webserver that takes advantage of Java 21's virtual threads.

[The Scala demo app](./src/main/scala/example/Hello.scala) is a little more full-featured than the Node one, to demonstrate how to achieve a few common patterns using Tapir.

Using Tapir this way also gives us the ability to automatically generate [API documentation](https://swagger.io/tools/swagger-ui/) for the application, which you will see at `/docs` on your running service.

## Secrets

The Content API KEY for this hackday has been made available to the application as a secret in Google Cloud. You can read it from your application's environment as `CAPI_API_KEY`.

When running the application locally, you can add `CAPI_API_KEY` to the environment so it matches production, either by exporting it from your shell or adding it to the start command.

```shell
$ export CAPI_API_KEY="???"
$ sbt
...
```

```shell
$ CAPI_API_KEY="???" sbt
...
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
+ --update-secrets "MY_APP_SECRET=MY_APP_SECRET:latest" \
  --update-secrets "CAPI_API_KEY=CAPI_API_KEY:latest"
```

Finally, we re-deploy the application by running the deploy script.

```shell
$ ./scripts/deploy.sh
```

**Please ensure your secrets are uniquely named**, since we're all using a shared hack day project.
