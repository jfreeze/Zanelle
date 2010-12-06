class Extension < Sequel::Model
  extend ModelHelpers
  include ModelHelperMethods
    
  unless table_exists?
    set_schema do
      primary_key :id, :null => false, :default => 0, :autoincrement => true
      varchar :ext, :length => 32
      timestamp :created_at
    end
    create_table
  end

  use_css_class_methods_for_errors

  def validate
    validates_numeric   [:ext]
    validates_presence  [:ext]
    validates_min_length 1, :message
  end
  
  before_create {self.created_at = Time.now}
end

