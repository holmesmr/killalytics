defmodule KillmailDispatch.KillmailBroadcaster do
  @moduledoc false

  @broadcast_timeout 5000

  use GenStage

  @doc "Starts the killmail broadcaster."
  def start_link(name) do
    GenStage.start_link(__MODULE__, :ok, name: name)
  end

  @doc "Sends a killmail and returns only after the killmail is dispatched."
  def sync_notify(mail, timeout \\ @broadcast_timeout) do
    GenStage.call(__MODULE__, {:notify, mail}, timeout)
  end

  ## Callbacks

  def init(:ok) do
    {:producer, {:queue.new, 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_call({:notify, mail}, from, {queue, pending_demand}) do
    queue = :queue.in({from, mail}, queue)
    dispatch_mails(queue, pending_demand, [])
  end

  def handle_demand(incoming_demand, {queue, pending_demand}) do
    dispatch_mails(queue, incoming_demand + pending_demand, [])
  end

  # Dispatch killmails for broadcast to listeners
  defp dispatch_mails(queue, 0, mails) do
    {:noreply, Enum.reverse(mails), {queue, 0}}
  end
  defp dispatch_mails(queue, demand, mails) do
    case :queue.out(queue) do
      {{:value, {from, mail}}, queue} ->
        GenStage.reply(from, :ok)
        dispatch_mails(queue, demand - 1, [mail | mails])
      {:empty, queue} ->
        {:noreply, Enum.reverse(mails), {queue, demand}}
    end
  end
end