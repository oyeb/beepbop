use Mix.Config

config :beepbop, BeepBop.TestRepo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "beepbop",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
