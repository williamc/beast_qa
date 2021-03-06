class UpdateWhiteList < ActiveRecord::Migration
  def self.up
    [Answer, Category, User].each do |klass|
      klass.transaction do
        klass.find(:all).each do |record|
          begin
            record.save_without_validation!
          rescue
            puts message_for_record(record, "[#{$!.class.name}] #{$!.message}")
          end
        end
      end
    end
  end

  def self.down
  end
  
  private
    def self.message_for_record(record, message)
      case record
        when Answer
          "Answer ##{record.id} of /categories/#{record.category_id}/questions/#{record.question_id}"
        when User
          "User #{record.display_name} /users/##{record.id}"
        when Category
          "Category /categories/##{record.id}"
      end << " errored with: '#{message}'"
    end
end
