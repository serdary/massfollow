configatron.configure_from_yaml("config/config.yml", :hash => Rails.env)
APP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]