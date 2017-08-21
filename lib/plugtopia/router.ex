defmodule Plugtopia.Router do
  use Plug.Router

  alias Plug.Conn

  plug :match
  plug :dispatch

  get "/hello" do
    Plugtopia.Hello.call(conn, [])
  end

  match _ do
    conn
    |> Conn.put_resp_content_type("text/plain")
    |> Conn.send_resp(404, "Not found")
  end
end
