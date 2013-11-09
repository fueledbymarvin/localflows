class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :city
      t.string :state
      t.string :gaccess
      t.string :grefresh
      t.string :image
      t.string :gid

      t.timestamps
    end
  end
end
