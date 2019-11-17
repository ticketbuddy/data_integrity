use Mix.Config

# Created using `mix guardian.gen.secret`
# TODO: re-generate and move to secret config

config :data_integrity,
  salts: [
    "B92TbN3sxHmf6nUGCbRGD/+rnE17U0gleCAFdyLXUZ7oW4ouPQCh6l+QVe7NYY0x",
    "ATjzRG6NudAw3gckJaw0jWBSPyHVyP9UJXNWunj3rLzpVoHxb1neldZSywH40AWL",
    "J6EkQgbTOsp0qvs6N2QB5alR6JOJ4/oeF5BR46BU9lQoDGO57JlVZQuQ23Edil9s"
  ]

import_config "#{Mix.env()}.exs"
