module Zanelle
  module Config
    require 'pp'
  
    ROOT        = File.dirname(File.expand_path(__FILE__))
    OFFSET      = '../../../config'
    CONFIG_FILE = File.join(ROOT, OFFSET, 'config.yml')

    def load_config
      h = YAML.load(File.read(CONFIG_FILE))
      post_load_process(h)
      pp h if $DEBUG
      h
    end
  
    private

    def post_load_process(h)
      set_env_to_development_if_no_asterisk_found(h)
      load_profiles(h)
    end

    def set_env_to_development_if_no_asterisk_found(h)
      ast = `which asterisk`
      h[:env] = :development if ast.empty?
    end
  
    def load_profiles(h)
      h[:profiles] = h[:user_configs][:file].map { |file| File.basename(file, ".*").to_sym }
      h[:profile] ||= {}
      h[:user_configs][:file].each do |file|
        name = File.basename(file, ".*").to_sym
        yml = File.join(ROOT, OFFSET, file)
        h[:profile][name] = YAML.load(File.read(yml))
        h[:profile][name][:name] = name
      end
    end

  end
end