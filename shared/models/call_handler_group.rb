class CallHandlerGroup < Sequel::Model
  def self.up
    create_table :call_handler_groups do
      primary_key :id
      String :name
    end
  end

  def self.down
    drop_table :call_handler_groups
  end
  
  up unless table_exists?
  
end
