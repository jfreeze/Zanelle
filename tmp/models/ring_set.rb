class RingSet < Sequel::Model
  extend ModelHelpers
  include ModelHelperMethods
  one_to_many :extensions
  nested_attributes :extensions
    
  unless table_exists?
    set_schema do
      primary_key :id, :null => false, :default => 0, :autoincrement => true
      varchar :name, :length => 256
      timestamp :created_at
    end
    create_table
  end

  + Add Ring Set
    name
    extension group


  use_css_class_methods_for_errors

  def ring_sets=(t)
    self.ring_sets_attributes = t.map{|topic| {:title=>topic}}
  end
  

  def validate
    # validates_numeric   [:ext]
    # validates_presence  [:ext]
    # validates_min_length 1, :message
  end
  
  before_create {self.created_at = Time.now}
end

Ring Center
  Name
    + Add External/Inbound Number
      Number
    + Add Ring Set
      name
      extension group
