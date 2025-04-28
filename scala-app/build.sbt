import scala.Console.{YELLOW, RESET}

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
    // Take name from the APP_NAME file so the container image matches the deploy script
    name := IO.read(file("APP_NAME")).trim,
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
      "org.scalatest" %% "scalatest" % "3.2.19" % Test
    ),

    // Docker configuration
    Docker / version := "latest",
    Docker / packageName := s"${name.value}-image",
    dockerBaseImage := "eclipse-temurin:21-jre",
    dockerBuildOptions ++= Seq(
      // build a cloud-run compatible image even on Apple silicone macs
      "--platform=linux/amd64"
    ),
    dockerExposedPorts ++= Seq(8080)
  )

/** NOTE: this project requires Java 21+, so this block adds a check to warn the
  * user if that is not the case.
  *
  * We require Java 21+ because the simple webserver we're using for this demo
  * relies on Java 21's new virtual threads feature.
  */
ThisBuild / onLoad := {
  val previous = (ThisBuild / onLoad).value
  val requiredJavaVersion = 21

  val currentVersionStr = sys.props.getOrElse("java.specification.version", "0")
  val currentVersion =
    if (currentVersionStr.startsWith("1."))
      currentVersionStr.substring(2).toInt
    else
      currentVersionStr.toInt

  if (currentVersion < requiredJavaVersion) {
    println(
      YELLOW + s"⚠️ Warning: Java $requiredJavaVersion+ is required for this project. Current version: $currentVersionStr" + RESET
    )
  }
  previous
}
