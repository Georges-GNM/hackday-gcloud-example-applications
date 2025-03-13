package example

import sttp.shared.Identity
import sttp.tapir.*
import sttp.tapir.server.netty.sync.NettySyncServer
import sttp.tapir.swagger.bundle.SwaggerInterpreter
import sttp.tapir.json.circe.*
import sttp.tapir.generic.auto.*
import io.circe.generic.auto.*

@main def main(): Unit = {
  NettySyncServer()
    .port(8080)
    .host("0.0.0.0")
    .addEndpoints(Server.appEndpoints)
    .addEndpoints(Server.swaggerEndpoints)
    .startAndWait()
}


object Server {
  // HTTP endpoints
  val index = endpoint.get
    .in("")
    .out(htmlBodyUtf8)
    .handleSuccess { _ =>
      """<h1>Scala container app</h1>
        |<a href="/docs">docs</a>
         """.stripMargin
    }

  val hello = endpoint.get
    .in("hello" / "world")
    .in(query[Option[String]]("name"))
    .out(stringBody)
    .handleSuccess(nameOpt => s"Hello, ${nameOpt.getOrElse("world")}!")

  val users = endpoint.get
    .in("users")
    .out(jsonBody[List[User]])
    .handleSuccess { _ =>
      List(
        User("1234", "User 1234"),
        User("5678", "Another user")
      )
    }

  case class User(id: String, username: String)

  // all our application endpoints
  val appEndpoints = List(index, hello, users)

  // API docs available at /docs
  val swaggerEndpoints = SwaggerInterpreter()
    .fromServerEndpoints[Identity](appEndpoints, "Hello world", "1.0.0")
}
