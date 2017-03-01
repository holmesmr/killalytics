defmodule KillalyticsWeb.KillfeedChannel do
  @moduledoc false

  use Phoenix.Channel

  @new_kill_event "new_kill"

  def join("killfeed", _auth_msg, socket) do
    {:ok, socket}
  end

  def handle_out(@new_kill_event, payload, socket) do
    push socket, @new_kill_event, payload
    {:noreply, socket}
  end
end