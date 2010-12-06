class Identity < Sequel::Model
  def self.up
    create_table :identities do
      primary_key :id
      String :name
    end
  end

  def self.down
    drop_table :identities
  end
  
  up unless table_exists?
  
end
