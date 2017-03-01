defmodule KillalyticsWeb.KillmailInlet do
  @moduledoc false

  @workers 10
  @worker_shutdown_timeout 100

  use ConsumerSupervisor

  alias KillalyticsWeb.InletListener
  alias KillalyticsWeb.PubSubDispatch

  def init(identifier) do
    {:consumer, identifier}
  end

  def start_link(name) do
    children = [
      worker(PubSubDispatch, [], restart: :temporary, shutdown: @worker_shutdown_timeout)
    ]

    ConsumerSupervisor.start_link(children, strategy: :one_for_one,
                                          subscribe_to: [{InletListener, max_demand: @workers}],
                                            name: name)
  end
end