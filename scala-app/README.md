Example Scala application
=========================

> [!IMPORTANT]
> If you take this source code as a template, please change the application name in [APPLICATION_NAME](APPLICATION_NAME).

### Running locally

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

### Deploying to Google Cloud

> [!IMPORTANT]
> Please change the application name in the [APPLICATION_NAME](APPLICATION_NAME) file. The name must be unique.

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

### Choice of webserver library

We typically use the [Play framework](https://www.playframework.com/) for Scala applications, but this is complex to set up for a hackday and is not a great fit for Cloud Run's architecture. Instead, this demo app uses [Tapir](https://tapir.softwaremill.com/en/latest/) to create a simple webserver definition.

[The Scala demo app](./src/main/scala/example/Hello.scala) is a little more full-featured than the Node one, to demonstrate how to achieve a few common patterns using Tapir.

Using Tapir this way also gives us the ability to automatically generate [API documentation](https://swagger.io/tools/swagger-ui/) for the application, which you will see at `/docs` on your running service.