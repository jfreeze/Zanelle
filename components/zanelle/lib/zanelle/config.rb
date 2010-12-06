puts "Loading ZanelleConfig"
class ZanelleConfig
  def initialize
    puts "zanelle_config initialized"
  end

  def load_dialplans
    Zanelle.dialplans = %w(6825)
  end
end

