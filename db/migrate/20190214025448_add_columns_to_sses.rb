class AddColumnsToSses < ActiveRecord::Migration[5.0]
  def change
    add_column :sses, :alias, :string
    add_column :sses, :url, :string
    add_column :sses, :review_count, :integer
    add_column :sses, :rating, :float
    add_column :sses, :city, :string
    add_column :sses, :zip_code, :string
    add_column :sses, :state, :string
    add_column :sses, :display_address, :string
    add_column :sses, :phone, :string
  end
end
