class RemoveExtraColumnsFromStatistics < ActiveRecord::Migration[8.0]
  def change
    remove_column :statistics, :country
  end
end
