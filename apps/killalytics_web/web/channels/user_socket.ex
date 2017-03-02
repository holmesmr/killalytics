defmodule KillalyticsWeb.UserSocket do
  @moduledoc false

  use Phoenix.Socket

  channel "killfeed", KillalyticsWeb.KillfeedChannel

  transport :websocket, Phoenix.Transports.WebSocket
  #transport :longpoll, Phoenix.Transports.LongPoll

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end