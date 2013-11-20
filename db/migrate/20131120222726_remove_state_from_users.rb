class RemoveStateFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :state, :string
  end
end
