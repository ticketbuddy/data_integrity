use Mix.Config

config :data_integrity,
  salts: String.split(System.get_env("DATA_INTEGRITY_SALTS"), ",")
