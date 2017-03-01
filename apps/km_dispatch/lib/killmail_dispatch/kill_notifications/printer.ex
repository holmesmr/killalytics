defmodule KillmailDispatch.KillNotifications.Printer do
  @moduledoc false

  def start_link(mail) do
    Task.start_link(fn ->
      print_killmail mail
    end)
  end

  defp print_killmail(mail) do
    attackers = mail["killmail"]["attackerCount"]
    time = mail["killmail"]["killTime"]
    corp = mail["killmail"]["victim"]["corporation"]["name"]
    ship = mail["killmail"]["victim"]["shipType"]["name"]
    system = mail["killmail"]["solarSystem"]["name"]

    noun = case attackers do
      1 -> "foe"
      _ -> "foes"
    end

    # Some structures don't have characters (citadels, towers, etc)
    case mail["killmail"]["victim"]["character"] do
      nil
        ->
        IO.puts "#{ship} belonging to #{corp} destroyed in #{system} by #{attackers} foes at #{time}"
      character
        ->
        IO.puts "#{ship} belonging to #{character["name"]} (#{corp}) destroyed in #{system} by #{attackers} #{noun} at #{time}"
    end
  end
end