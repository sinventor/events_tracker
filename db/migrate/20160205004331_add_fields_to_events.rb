class AddFieldsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :end_date, :datetime
    add_column :events, :base_id, :integer
  end
end
