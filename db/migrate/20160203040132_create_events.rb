class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.datetime :start, null: false
      t.string :repeat_interval
      t.references :user, null: false, index: true, foreign_key: true
    end
  end
end
