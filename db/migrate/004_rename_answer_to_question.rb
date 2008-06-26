class RenameAnswerToQuestion < ActiveRecord::Migration
  def self.up
    rename_column :answers, :answer_id, :question_id
  end

  def self.down
    rename_column :answers, :question_id, :answer_id
  end
end
