# Load application custom parametrs into APP_CONFIG

CFG = YAML.load_file("#{::Rails.root}/config/config.yml")[Rails.env]