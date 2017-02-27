defmodule KillmailDispatch.KillNotifications.Supervisor do
  @moduledoc false

  @listener_shutdown_timeout 1000

  use Supervisor

  alias KillmailDispatch.KillmailListener
  alias KillmailDispatch.KillNotifications.Consumer
  alias KillmailDispatch.KillNotifications.Listener

  def start_link(name) do
    Supervisor.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    children = [
      worker(KillmailListener, [Listener], shutdown: @listener_shutdown_timeout, restart: :transient),
      supervisor(Consumer, [Consumer], shutdown: :infinity, restart: :transient)
    ]

    supervise(children, strategy: :one_for_one)
  end
end