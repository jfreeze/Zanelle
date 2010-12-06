class Number < Sequel::Model
  def self.up
    create_table :numbers do
      primary_key :id
      String :number
      TrueClass :is_sip
    end
  end

  def self.down
    drop_table
  end
  
  up unless table_exists?
  
end
