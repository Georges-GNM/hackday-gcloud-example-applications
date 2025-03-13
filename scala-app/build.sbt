ThisBuild / scalaVersion     := "3.3.5"
ThisBuild / version          := "1.0.0-SNAPSHOT"
ThisBuild / organization     := "com.example"
ThisBuild / organizationName := "example"

lazy val root = (project in file("."))
  .enablePlugins(JavaAppPackaging)
  .enablePlugins(DockerPlugin)
  .settings(
    name := "scala-hello-world",
    libraryDependencies ++= Seq(
      "com.softwaremill.sttp.tapir" %% "tapir-core" % "1.11.17",
      "com.softwaremill.sttp.tapir" %% "tapir-netty-server-sync" % "1.11.17",
      "com.softwaremill.sttp.tapir" %% "tapir-swagger-ui-bundle" % "1.11.17",
      "com.softwaremill.sttp.tapir" %% "tapir-json-circe" % "1.11.17",
      "ch.qos.logback" % "logback-classic" % "1.4.11",
      "org.scalameta" %% "munit" % "0.7.29" % Test,
    ),

    // Docker configuration
    Docker / version := "latest",
    Docker / packageName := "scala-hello-world-app", // This should match the `IMAGE_NAME` in the deploy script

    dockerBaseImage := "eclipse-temurin:21-jre",
    dockerBuildOptions ++= Seq("--platform=linux/amd64"),
    dockerExposedPorts ++= Seq(8080),
  )
