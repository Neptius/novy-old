import Config

config :novy_web, :pow_assent,
  providers: [
    discord: [
      client_id: "REPLACE_WITH_CLIENT_ID",
      client_secret: "REPLACE_WITH_CLIENT_SECRET",
      strategy: Assent.Strategy.Discord
    ]
  ]

config :novy_admin, :pow_assent,
  providers: [
    discord: [
      client_id: "REPLACE_WITH_CLIENT_ID",
      client_secret: "REPLACE_WITH_CLIENT_SECRET",
      strategy: Assent.Strategy.Discord
    ]
  ]
