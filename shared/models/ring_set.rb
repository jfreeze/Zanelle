class RingSet < Sequel::Model
  def self.up
    create_table :ring_sets do
      primary_key :id
      String :name
    end
  end

  def self.down
    drop_table :ring_sets
  end
  
  up unless table_exists?
  
end
