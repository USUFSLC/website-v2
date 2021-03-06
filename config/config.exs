# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :fslc,
  ecto_repos: [Fslc.Repo]

config :fslc, Fslc.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY")

# Configures the endpoint
config :fslc, FslcWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gwd3jdSqFGcFuLMm5O7IZPOOoLXRCX6lbvKzhjzt0eO51kCCqxper3PdoNlDRUOS",
  render_errors: [view: FslcWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Fslc.PubSub,
  live_view: [signing_salt: "O6LzLegQ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
