defmodule KillalyticsWeb.KillmailClientFormat do
  @moduledoc false

  alias KillalyticsWeb.KillSchemaV1.Alliance
  alias KillalyticsWeb.KillSchemaV1.Corporation
  alias KillalyticsWeb.KillSchemaV1.GameAgent
  alias KillalyticsWeb.KillSchemaV1.KillMail
  alias KillalyticsWeb.KillSchemaV1.Pilot
  alias KillalyticsWeb.KillSchemaV1.Ship
  alias KillalyticsWeb.KillSchemaV1.SolarSystem

  def format_killmail(mail) do
    %KillMail{
      victim: format_victim(mail["killmail"]["victim"]),
      value: mail["zkb"]["totalValue"],
      ship: format_ship(mail["killmail"]["victim"]["shipType"]),
      attackers: format_attackers(mail["killmail"]["attackers"]),
      system: format_solar_system(mail["killmail"]["solarSystem"]),
      datetime: date_parse(mail["killmail"]["killTime"]),
    }
  end

  def format_victim(victim) do
    # Corp killmails have Character and Corp, Corp killmails don't
    case Map.has_key? victim, "character" do
      true ->
        %GameAgent{
          type:  "pilot",
          pilot: format_pilot victim
        }
      false ->
        %GameAgent{
          type: "corp",
          corp: format_corp victim
        }
    end
  end

  def format_pilot(victim) do
    %Pilot{
      id: victim["character"]["id"],
      name: victim["character"]["name"],
      corporation: format_corp victim
    }
  end

  def format_corp(victim) do
    corp = %Corporation{
             id:     victim["corporation"]["id"],
             name:   victim["corporation"]["name"],
             ticker: "TODO"
           }

    case Map.has_key? victim, "alliance" do
      true ->
        %Corporation{corp | alliance: format_victim_alliance victim}
      false ->
        corp
    end
  end

  def format_alliance(victim) do
    %Alliance{
      id:     victim["alliance"]["id"],
      name:   victim["alliance"]["name"],
      ticker: "TODO"
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
    format_attackers unprocessed, [format_pilot next | processed]
  end

  def format_solar_system(system) do
    # TODO: IMPLEMENT
  end

  defp date_parse(date) do
    # TODO: IMPLEMENT
  end
end