class AddAnswersBodyHtml < ActiveRecord::Migration
  def self.up
    add_column "answers",  "body_html",        :text
    add_column "users",  "bio_html",         :text
    add_column "categories", "description_html", :text
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
    remove_column "answers", "body_html"
    remove_column "users", "bio_html"
    remove_column "categories", "description_html"
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
