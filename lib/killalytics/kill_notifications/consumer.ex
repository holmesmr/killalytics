defmodule Killalytics.KillNotifications.Consumer do
  @moduledoc false

  @workers 10
  @worker_shutdown_timeout 100

  use ConsumerSupervisor

  def init(identifier) do
    {:consumer, identifier}
  end

  def start_link(name) do
    children = [
      worker(Killalytics.KillNotifications.Printer, [], restart: :temporary, shutdown: @worker_shutdown_timeout)
    ]

    ConsumerSupervisor.start_link(children, strategy: :one_for_one,
                                            subscribe_to: [{Killalytics.KillNotifications.Listener, max_demand: @workers}],
                                            name: name)
  end
end