package example

import io.circe.generic.auto.*
import sttp.client4.*
import sttp.client4.circe.*
import sttp.tapir.*
import sttp.tapir.generic.auto.*
import sttp.tapir.json.circe.*
import sttp.tapir.server.ServerEndpoint
import sttp.tapir.server.netty.sync.NettySyncServer
import sttp.tapir.swagger.bundle.SwaggerInterpreter

@main def main(): Unit = {
  NettySyncServer()
    .port(8080)
    .host("0.0.0.0")
    // serve our app's HTTP endpoints
    .addEndpoints(Routes.appRoutes)
    // optionally add automatically generated API documentation
    .addEndpoints(Routes.swaggerRoutes)
    .startAndWait()
}

/** An example application that demonstrates a few different handlers
  */
object Routes {
  private val httpClient = DefaultSyncBackend()

  /** Index handler that returns HTML
    */
  private val index = endpoint.get
    .in("")
    .out(htmlBodyUtf8)
    .handleSuccess { _ =>
      """<h1>Scala container app</h1>
        |<a href="/docs">docs</a>
         """.stripMargin
    }

  /** HTTP endpoint that takes an optional GET parameter called `name`
    */
  private val hello = endpoint.get
    .in("hello" / "world")
    .in(query[Option[String]]("name"))
    .out(stringBody)
    .handleSuccess { maybeName =>
      s"Hello, ${maybeName.getOrElse("world")}!"
    }

  /** Endpoint that returns User objects as JSON
    */
  private val users = endpoint.get
    .in("users")
    .out(jsonBody[List[User]])
    .handleSuccess { _ =>
      List(
        User("1234", "User 1234"),
        User("5678", "Another user")
      )
    }

  /** An endpoint that:
    *   - makes an HTTP call
    *   - parses the response
    *   - returns JSON
    *
    * It addresses the contrived use case of looking up the server's IP
    * information and returning just the IP address.
    */
  private val ipInformation = endpoint.get
    .in("ip-info")
    .out(jsonBody[Ip])
    .errorOut(stringBody)
    .handleSuccess { _ =>
      val ipData = basicRequest
        .get(uri"https://api.myip.com/")
        .response(asJsonOrFail[IpInfo])
        .send(httpClient)
        .body
      // do some business logic here
      Ip(ipData.ip)
    }

  /** Our application's routes
    */
  val appRoutes = List(index, hello, users, ipInformation)

  /** Automatically generated API docs will be available at /docs
    */
  val swaggerRoutes = SwaggerInterpreter()
    .fromServerEndpoints(appRoutes, "Hello world", "1.0.0")
}

case class User(id: String, username: String)

case class IpInfo(ip: String, country: String, cc: String)
case class Ip(ipAddress: String)
