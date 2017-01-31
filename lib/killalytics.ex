defmodule Killalytics do
  use Application

  def start(_type, _args) do
    Killalytics.Supervisor.start_link()
  end
end