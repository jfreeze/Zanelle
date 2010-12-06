$LOAD_PATH.unshift(File.join(File.dirname(File.expand_path(__FILE__)), 'lib', 'zanelle'))

require 'zanelle'

methods_for :dialplan do
  def zanelle(options={})
    Zanelle::Base.new(self, options).run
  end
end


