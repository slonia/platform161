class AddCommentToReport < ActiveRecord::Migration
  def change
    add_column :reports, :comment, :string
  end
end
