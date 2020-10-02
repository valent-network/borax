# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:urls) do
      primary_key :id
      String :address, null: false
      String :status, null: false
      String :source, null: false
      Time :created_at, null: false
      Time :updated_at, null: false
    end

    add_index :urls, %i[updated_at source]
    add_index :urls, %i[address source], unique: true
  end
end
