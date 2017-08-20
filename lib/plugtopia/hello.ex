defmodule Plugtopia.Hello do
  alias Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    conn
    |> Conn.put_resp_content_type("text/plain")
    |> Conn.send_resp(200, "Hello, world!")
  end
end
