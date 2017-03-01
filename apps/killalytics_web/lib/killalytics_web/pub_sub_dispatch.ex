defmodule KillalyticsWeb.PubSubDispatch do
  @moduledoc false

  alias KillalyticsWeb.KillmailClientFormat

  def start_link(mail) do
    Task.start_link(fn ->
      dispatch_killmail mail
    end)
  end

  defp dispatch_killmail(mail) do
    KillalyticsWeb.Endpoint.broadcast! "killfeed", "new_kill", KillmailClientFormat.format_killmail(mail)
  end
end