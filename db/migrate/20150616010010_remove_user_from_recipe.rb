class RemoveUserFromRecipe < ActiveRecord::Migration
  def change
    remove_column :recipes, :user
  end
end
