// allows us to package the app as a docker container
addSbtPlugin("com.github.sbt" % "sbt-native-packager" % "1.11.1")

// adds server start stop support via `reStart` / `reStop`
addSbtPlugin("io.spray" % "sbt-revolver" % "0.10.0")

// source code formatting
addSbtPlugin("org.scalameta" % "sbt-scalafmt" % "2.5.4")
