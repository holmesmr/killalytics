defmodule Killalytics.KillmailFeed do
  @moduledoc """
  Listens for killmails fed from a live WebSocket pipe such as the one found in
  """

  @km_config Application.get_env(:killalytics, :redisq_ws)

  @km_endpoint @km_config.endpoint
  @km_keepalive_time @km_config.keepalive
  @km_keepalive_ping @km_config.ping_payload
  @km_agent_string @km_config.user_agent

  @doc "Start listening to the WebSocket killfeed"
  def start_link(name) do
    {:ok, socket} = connect()

    IO.puts "Connected to killmail websocket service."

    Task.start_link(fn -> process_mails(socket) end)
  end

  defp connect do
    uri = URI.parse @km_endpoint
    host = uri.authority
    path = uri.path

    {secure, port} = case uri.scheme do
      "ws" ->
        {false, uri.port || URI.default_port "http"}
      "wss" ->
        {true, uri.port || URI.default_port "https"}
    end

    Socket.Web.connect {host, port}, secure: secure, path: path,
          headers: [{"User-Agent", @km_agent_string}]
  end

  defp process_mails(socket) do
    # Repeatedly fetch killmails

     Task.start(__MODULE__, fn ->
              Process.sleep(:infinity)
            end, [name: Killalytics.KillmailBroadcaster.JSONParser])
    case socket |> Socket.Web.recv(timeout: @km_keepalive_time) do
      { :ok, {:text, mail}} ->
        # We don't want to crash the socket listener if there's a JSON parser failure
        Task.start(fn ->
          Killalytics.KillmailBroadcaster.sync_notify (Poison.Parser.parse! mail, keys: :atoms)
        end)
      { :error, :timeout } ->
        # Send a ping to show we're still here
        socket |> Socket.Web.send!({:text, @km_keepalive_ping})
        {:text, @km_keepalive_ping} = socket |> Socket.Web.recv!()
    end

    process_mails(socket)
  end
end
