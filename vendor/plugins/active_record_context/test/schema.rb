ActiveRecord::Schema.define(:version => 0) do
  create_table :questions, :force => true do |t|
    t.column :title, :string
  end

  create_table :posts, :force => true do |t|
    t.column :question_id, :integer
    t.column :question_type, :string
    t.column :type, :string
    t.column :body, :string
  end
end