defmodule Killalytics.Supervisor do
  @moduledoc false

  @killfeed_timeout 1000
  @broadcaster_timeout 1000

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      # Core Killmail dispatchers
      worker(Killalytics.KillmailFeed, [Killalytics.KillmailFeed], shutdown: @killfeed_timeout, restart: :transient),
      worker(Killalytics.KillmailBroadcaster, [Killalytics.KillmailBroadcaster], shutdown: @broadcaster_timeout, restart: :transient),

      # Killmail processors
      supervisor(Killalytics.KillNotifications.Supervisor, [Killalytics.KillNotifications.Supervisor], shutdown: :infinity, restart: :transient)
    ]

    supervise(children, strategy: :one_for_one)
  end
end