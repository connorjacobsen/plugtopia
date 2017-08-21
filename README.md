# Plugtopia

## Getting Started

Install the latest version of Elixir (v1.5.1 at the time of this writing) with [homebrew](https://brew.sh/):

```bash
$ brew install elixir
```

This should also pull in Erlang for you.

Test out your installation:

```bash
$ elixir --version
Erlang/OTP 20 [erts-9.0] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Elixir 1.5.1
```

Now we can create our project directory with `Mix` and get started:

```bash
$ mix new plugtopia --sup
$ cd plugtopia
```

## Dependencies

For Elixir projects we specify our dependencies (and some other information we don't need to worry about for now) in a `mix.exs` file. Right now we only need a couple dependencies:

```elixir
defmodule Plugtopia.Mixfile do
  use Mix.Project

  def project do
    [
      app: :plugtopia,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Plugtopia.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.1.2"},
      {:plug, "~> 1.4.3"},
      {:ecto, "~> 2.1.6"},
      {:sqlite_ecto2, "~> 2.0"}
    ]
  end
end
```

Now we tell mix to fetch all of our dependencies:

```bash
mix deps.get
```

## What the Plug?

A Plug is basically the Elixir equivalent of a Ruby Rack app. It's simply a module that implements a small interface and responds to web requests. The Plug interface is made up of two functions, `init/1` and `call/2`.

Plugs come in two different varieties: functions and modules. A funcion plug take two arguments, a connection and some options, and returns the connection:

```elixir
def hello_plug(conn, _options) do
  conn
  |> put_resp_content_type("text/plain")
  |> send_resp(200, "Hello, world!")
end
```

And here's the module version, which implements `init/1` and `call/2`:

```elixir
defmodule Hello do
  def init(options) do
    options
  end

  def call(conn, _options) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello, world!")
  end
end
```

## Our First Plug

We'll define a very simple plug, which is exactly what we were using before:

```elixir
# lib/plugtopia/hello.ex
defmodule Plugtopia.Hello do
  alias Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    conn
    |> Conn.put_resp_content_type("text/plain")
    |> Conn.send_resp(200, "Hello, world")
  end
end
```

We also want to ensure that our supervisor is set up correctly. A supervisor is just a process that sits and watches some other process, and restarts it if it dies (which would happen if an exception gets raised). Don't worry about the special options for now, jut read the code and the comments and they should explain the only pieces we care about for now:

```elixir
# lib/plugtopia/application.ex
defmodule Plugtopia.Application do
  @moduledoc false

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  use Application

  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [
      # Cowboy is a web server, and it provides a specification that allows us
      # to set up a simple server process. This process uses the `http`
      # protocol, sends all requests to the `Plugtopia.Hello` plug module,
      # which calls `init/1` with `[]` as the argument, and will run on
      # port 4001
      Plug.Adapters.Cowboy.child_spec(:http, Plugtopia.Hello, [], [port: 4001])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Plugtopia.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

We can now test out our app in the `iex` console:

```bash
$ iex -S mix
```

Now if we visit `localhost:4001` we should get back a `Hello, world!` message! Once you're ready to move on, you can kill the `iex` shell with `^C` two times.

## Adding a Router

Plug ships with its own router, `Plug.Router`, so we don't have to implement our own.

First, let's change our `Plugtopia.Application` to use a `Plugtopia.Router` module instead of directly calling `Plugtopia.Hello`:

```elixir
defmodule Plugtopia.Application do
  @moduledoc false

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  use Application

  def start(_type, _args) do
    children = [
      # Define workers and child supervisors to be supervised
      Plug.Adapters.Cowboy.child_spec(:http, Plugtopia.Router, [], [port: 4001])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Plugtopia.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

And then we'll define our router like so:

```elixir
# lib/plugtopia/router.ex
defmodule Plugtopia.Router do
  use Plug.Router

  alias Plug.Conn

  plug :match
  plug Plug.Logger
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
```

Again, we start the server with `iex`:

```bash
$ iex -S mix
```

Now, if we visit `localhost:4001` we get a `Not Found`, and if we visit `localhost:4001/hello` we see our old `Hello, world!` message again!
