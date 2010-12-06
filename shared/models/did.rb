class Did < Sequel::Model
  many_to_one :call_handler_group
  def self.up
    create_table :dids do
      primary_key :id
      String :number
      String :pri_number
      String :description
      foreign_key :call_handler_group_id
    end
  end

  def self.down
    drop_table
  end
  
  up unless table_exists?
  
end
