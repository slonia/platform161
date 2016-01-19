class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :campaign_id, null: false
      t.string :campaign_name
      t.date :start_on
      t.date :end_on
      t.float :media_budget, null: false, default: 0
      t.float :media_spent, null: false, default: 0
      t.integer :impressions, null: false, default: 0
      t.integer :clicks, null: false, default: 0
      t.float :ctr, null: false, default: 0
      t.integer :conversions, null: false, default: 0
      t.float :gross_revenues, null: false, default: 0
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
