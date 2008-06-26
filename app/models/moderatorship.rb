class Moderatorship < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  before_create { |r| count(:id, :conditions => ['category_id = ? and user_id = ?', r.category_id, r.user_id]).zero? }
end
