class CreateSss < ActiveRecord::Migration[5.0]
  def change
    create_table :sss do |t|
      t.string :name
    end
  end
end
