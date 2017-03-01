defmodule KillalyticsWeb.KillmailClientFormat do
  @moduledoc false

  alias KillalyticsWeb.KillSchemaV1.Alliance
  alias KillalyticsWeb.KillSchemaV1.Corporation
  alias KillalyticsWeb.KillSchemaV1.Faction
  alias KillalyticsWeb.KillSchemaV1.GameAgent
  alias KillalyticsWeb.KillSchemaV1.KillMail
  alias KillalyticsWeb.KillSchemaV1.Pilot
  alias KillalyticsWeb.KillSchemaV1.Ship
  alias KillalyticsWeb.KillSchemaV1.SolarSystem

  def format_killmail(mail) do
    %KillMail{
      id: mail["killmail"]["killID"],
      victim: format_agent(mail["killmail"]["victim"]),
      value: mail["zkb"]["totalValue"],
      attackers: format_attackers(mail["killmail"]["attackers"]),
      system: format_solar_system(mail["killmail"]["solarSystem"]),
      datetime: date_parse(mail["killmail"]["killTime"]),
    }
  end

  def format_agent(agent) do
    # Corp killmails have Character and Corp, Corp killmails don't
    ship = format_ship agent["shipType"]
    cond do
      Map.has_key?(agent, "character") && agent["character"] != nil ->
        %GameAgent{
          type: "pilot",
          agent: format_pilot(agent),
          ship: ship
        }
      Map.has_key?(agent, "corporation") && agent["corporation"] != nil ->
        %GameAgent{
          type: "corp",
          agent: format_corp(agent),
          ship: ship
        }
      Map.has_key?(agent, "faction") && agent["faction"] != nil ->
        %GameAgent{
          type: "faction",
          agent: format_faction(agent),
          ship: ship
        }
    end
  end

  def format_pilot(agent) do
    %Pilot{
      id: agent["character"]["id"],
      name: agent["character"]["name"],
      corporation: format_corp agent
    }
  end

  def format_corp(agent) do
    corp = %Corporation{
             id:     agent["corporation"]["id"],
             name:   agent["corporation"]["name"],
             ticker: "TODO"
           }

    case Map.has_key?(agent, "alliance") && agent["alliance"] != nil do
      true ->
        %Corporation{corp | alliance: format_alliance agent}
      false ->
        corp
    end
  end

  def format_alliance(agent) do
    %Alliance{
      id:     agent["alliance"]["id"],
      name:   agent["alliance"]["name"],
      ticker: "TODO"
    }
  end

  def format_faction(agent) do
    %Faction{
      id:     agent["faction"]["id"],
      name:   agent["faction"]["name"]
    }
  end

  def format_ship(ship) do
    %Ship{
      id: ship["id"],
      name: ship["name"]
    }
  end

  def format_attackers(attackers) do
    format_attackers attackers, []
  end

  defp format_attackers([], processed) do
    processed
  end

  defp format_attackers([next | unprocessed], processed) do
    format_attackers unprocessed, [(format_agent next) | processed]
  end

  def format_solar_system(system) do
    %SolarSystem{
      id: system["id"],
      name: system["name"],
      region: "TODO"
    }
  end

  defp date_parse(date) do
    do_date_parse String.split(date, " ")
  end

  defp do_date_parse([date_str, time_str]) do
    date = Date.from_iso8601! String.replace(date_str, ".", "-")
    time = Time.from_iso8601! time_str
    {:ok, dt} = NaiveDateTime.new date, time
    NaiveDateTime.to_iso8601 dt
  end
end