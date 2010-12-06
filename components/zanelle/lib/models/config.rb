class Init < Sequel::Model
  extend ModelHelpers
  include ModelHelperMethods

  unless table_exists?
    set_schema do
      primary_key :id, :null => false, :default => 0, :autoincrement => true
      varchar :name, :length => 64
      varchar :email, :length => 256
      varchar :subject, :length => 64
      varchar :phone, :length => 16
      boolean :thankyou_posted, :length => 1, :default => 0
      tinyint :contacted, :length => 1, :default => 0   # 0 not, 1 email, 2 phone
      text :message
      timestamp :created_at
    end
    create_table
  end

  use_css_class_methods_for_errors

  def validate
  end

  before_create {self.created_at = Time.now}

end
