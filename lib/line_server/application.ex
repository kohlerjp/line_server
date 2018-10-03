defmodule LineServer.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec
    filename =  Application.get_env(:line_server, :line_path)
    IO.puts "Parsing #{filename}"
    line_data = LineServer.LineParser.parse_file(filename)

    # Define workers and child supervisors to be supervised
    children = [
      worker(LineServer.LineAgent, [{line_data, filename}]),
      supervisor(LineServerWeb.Endpoint, []),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LineServer.Supervisor]
    
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LineServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
