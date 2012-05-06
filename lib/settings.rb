require 'settingslogic'

class Settings < Settingslogic
  source "config/jockey.yml"
  namespace "development"
end
