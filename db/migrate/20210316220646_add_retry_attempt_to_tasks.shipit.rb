# This migration comes from shipit (originally 20201008145809)
class AddRetryAttemptToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :retry_attempt, :integer, null: false, default: 0
  end
end
