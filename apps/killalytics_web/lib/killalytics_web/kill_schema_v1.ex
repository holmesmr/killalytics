defmodule KillalyticsWeb.KillSchemaV1.Alliance do
  @moduledoc false

  @derive [Poison.Encoder]

  @enforce_keys [:id, :name, :ticker]
  defstruct [:id, :name, :ticker]
end

defmodule KillalyticsWeb.KillSchemaV1.Corporation do
  @moduledoc false

  @derive [Poison.Encoder]

  @enforce_keys [:id, :name, :alliance, :ticker]
  defstruct [:id, :name, :ticker]
end

defmodule KillalyticsWeb.KillSchemaV1.GameAgent do
  @moduledoc false

  @derive [Poison.Encoder]

  @enforce_keys [:id]
  defstruct [:id, :pilot, :corp]
end

defmodule KillalyticsWeb.KillSchemaV1.Pilot do
  @moduledoc false

  @derive [Poison.Encoder]

  @enforce_keys [:id, :name, :corporation]
  defstruct [:id, :name, :corporation]
end

defmodule KillalyticsWeb.KillSchemaV1.Ship do
  @moduledoc false

  @derive [Poison.Encoder]

  @enforce_keys [:id, :name]
  defstruct [:id, :name]
end

defmodule KillalyticsWeb.KillSchemaV1.SolarSystem do
  @moduledoc false

  @derive [Poison.Encoder]

  @enforce_keys [:id, :name, :region]
  defstruct [:id, :name, :region]
end

defmodule KillalyticsWeb.KillSchemaV1.KillMail do
  @moduledoc false

  @derive [Poison.Encoder]

  @enforce_keys [:victim, :value, :ship, :attackers, :system, :datetime]
  defstruct [:victim, :value, :ship, :attackers, :system, :datetime]
end