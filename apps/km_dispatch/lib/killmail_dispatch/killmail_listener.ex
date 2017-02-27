defmodule KillmailDispatch.KillmailListener do
  @moduledoc false

  use GenStage

  def start_link(name) do
    GenStage.start_link(__MODULE__, :ok, name: name)
  end

  def init(identifier) do
    {:producer_consumer, identifier, subscribe_to: [KillmailDispatch.KillmailBroadcaster]}
  end

  def handle_events(mails, _from, identifier) do
    {:noreply, mails, identifier}
  end
end