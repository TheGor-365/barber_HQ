class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.text :username
      t.text :phone
      t.text :datestamp
      t.text :barber
      t.text :color

      t.timestamps
    end
  end
end
