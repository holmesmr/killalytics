defmodule Killalytics.KillNotifications.Supervisor do
  @moduledoc false

  @listener_shutdown_timeout 1000

  use Supervisor

  def start_link(name) do
    Supervisor.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    children = [
      worker(Killalytics.KillmailListener, [Killalytics.KillNotifications.Listener], shutdown: @listener_shutdown_timeout, restart: :transient),
      supervisor(Killalytics.KillNotifications.Consumer, [Killalytics.KillNotifications.Consumer], shutdown: :infinity, restart: :transient)
    ]

    supervise(children, strategy: :one_for_one)
  end
end