use Mix.Config

config :camunda,
       :camunda,
       hostname: "http://localhost:8080/engine-rest",
       username: "demo",
       password: "demo"

import_config "#{Mix.env()}.exs"