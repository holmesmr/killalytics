# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :killalytics_web,
  ecto_repos: [KillalyticsWeb.Repo]

# Configures the endpoint
config :killalytics_web, KillalyticsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "huSL6XDTC6DuM8MG8FodBcW17QaK9gYGIf9RLWCoGkQ7pnvqR6HxV35ON/ufWgQd",
  render_errors: [view: KillalyticsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: KillalyticsWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
