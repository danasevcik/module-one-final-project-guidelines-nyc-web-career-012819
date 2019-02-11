class CreateSaves < ActiveRecord::Migration[5.0]
  def change
    create_table :saves do |t|
      t.integer :user_id
      t.integer :ss_id
    end
  end
end
