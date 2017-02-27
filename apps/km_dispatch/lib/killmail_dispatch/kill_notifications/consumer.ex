defmodule KillmailDispatch.KillNotifications.Consumer do
  @moduledoc false

  @workers 10
  @worker_shutdown_timeout 100

  use ConsumerSupervisor

  alias KillmailDispatch.KillNotifications.Printer
  alias KillmailDispatch.KillNotifications.Listener

  def init(identifier) do
    {:consumer, identifier}
  end

  def start_link(name) do
    children = [
      worker(Printer, [], restart: :temporary, shutdown: @worker_shutdown_timeout)
    ]

    ConsumerSupervisor.start_link(children, strategy: :one_for_one,
                                            subscribe_to: [{Listener, max_demand: @workers}],
                                            name: name)
  end
end