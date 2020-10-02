Sequel.migration do
  change do
    create_table(:schema_info) do
      column :version, "integer", :default=>0, :null=>false
    end
    
    create_table(:urls) do
      primary_key :id
      column :address, "text", :null=>false
      column :status, "text", :null=>false
      column :source, "text", :null=>false
      column :created_at, "timestamp without time zone", :null=>false
      column :updated_at, "timestamp without time zone", :null=>false
      
      index [:address, :source], :unique=>true
      index [:updated_at, :source]
    end
  end
end
