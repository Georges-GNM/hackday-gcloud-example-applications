ThisBuild / scalaVersion := "3.3.5"
ThisBuild / version := "1.0.0-SNAPSHOT"
ThisBuild / organization := "com.example"
ThisBuild / organizationName := "example"

val tapirVersion = "1.11.25"
val sttpVersion = "4.0.3"

lazy val root = (project in file("."))
  .enablePlugins(JavaAppPackaging)
  .enablePlugins(DockerPlugin)
  .settings(
    name := "scala-hello-world",
    libraryDependencies ++= Seq(
      // webserver
      "com.softwaremill.sttp.tapir" %% "tapir-core" % tapirVersion,
      "com.softwaremill.sttp.tapir" %% "tapir-netty-server-sync" % tapirVersion,
      "com.softwaremill.sttp.tapir" %% "tapir-swagger-ui-bundle" % tapirVersion,
      "com.softwaremill.sttp.tapir" %% "tapir-json-circe" % tapirVersion,
      // HTTP client
      "com.softwaremill.sttp.client4" %% "core" % sttpVersion,
      "com.softwaremill.sttp.client4" %% "circe" % sttpVersion,
      // tooling
      "ch.qos.logback" % "logback-classic" % "1.5.18",
      "org.scalameta" %% "munit" % "1.1.0" % Test
    ),

    // Docker configuration
    Docker / version := "latest",
    Docker / packageName := "scala-hello-world-app", // This should match the `IMAGE_NAME` in the deploy script

    dockerBaseImage := "eclipse-temurin:21-jre",
    dockerBuildOptions ++= Seq("--platform=linux/amd64"),
    dockerExposedPorts ++= Seq(8080)
  )
