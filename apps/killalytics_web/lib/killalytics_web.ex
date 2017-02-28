defmodule KillalyticsWeb do
  use Application

  @listener_shutdown_timeout 1000

  alias KillalyticsWeb.InletListener
  alias KillalyticsWeb.KillmailInlet
  alias KillmailDispatch.KillmailListener

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(KillalyticsWeb.Repo, []),
      # Start the endpoint when the application starts
      supervisor(KillalyticsWeb.Endpoint, []),
      # Start your own worker by calling: KillalyticsWeb.Worker.start_link(arg1, arg2, arg3)
      # worker(KillalyticsWeb.Worker, [arg1, arg2, arg3]),
      worker(KillmailListener, [InletListener], shutdown: @listener_shutdown_timeout, restart: :transient),
      supervisor(KillmailInlet, [KillmailInlet], shutdown: :infinity, restart: :transient)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KillalyticsWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    KillalyticsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
