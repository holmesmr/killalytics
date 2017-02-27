defmodule KillmailDispatch.Supervisor do
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
      worker(KillmailDispatch.KillmailFeed, [KillmailDispatch.KillmailFeed], shutdown: @killfeed_timeout, restart: :transient),
      worker(KillmailDispatch.KillmailBroadcaster, [KillmailDispatch.KillmailBroadcaster], shutdown: @broadcaster_timeout, restart: :transient),

      # Killmail processors
      supervisor(KillmailDispatch.KillNotifications.Supervisor, [KillmailDispatch.KillNotifications.Supervisor], shutdown: :infinity, restart: :transient)
    ]

    supervise(children, strategy: :one_for_one)
  end
end