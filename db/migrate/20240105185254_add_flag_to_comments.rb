class AddFlagToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :flag, :boolean, default: false, index: true
  end
end
