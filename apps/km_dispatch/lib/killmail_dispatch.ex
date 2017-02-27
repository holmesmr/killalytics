defmodule KillmailDispatch do
  use Application

  def start(_type, _args) do
    KillmailDispatch.Supervisor.start_link()
  end
end