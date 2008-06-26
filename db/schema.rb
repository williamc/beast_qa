# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 53) do

  create_table "categories", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.integer "questions_count",  :limit => 11, :default => 0
    t.integer "posts_count",      :limit => 11, :default => 0
    t.integer "position",         :limit => 11
    t.text    "description_html"
  end

  create_table "logged_exceptions", :force => true do |t|
    t.string   "exception_class"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "message"
    t.text     "backtrace"
    t.text     "environment"
    t.text     "request"
    t.datetime "created_at"
  end

  create_table "moderatorships", :force => true do |t|
    t.integer "category_id", :limit => 11
    t.integer "user_id",     :limit => 11
  end

  add_index "moderatorships", ["category_id"], :name => "index_moderatorships_on_category_id"

  create_table "monitorships", :force => true do |t|
    t.integer "question_id", :limit => 11
    t.integer "user_id",     :limit => 11
    t.boolean "active",                    :default => true
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.binary  "server_url"
    t.string  "handle"
    t.binary  "secret"
    t.integer "issued",     :limit => 11
    t.integer "lifetime",   :limit => 11
    t.string  "assoc_type"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.string  "nonce"
    t.integer "created", :limit => 11
  end

  create_table "open_id_authentication_settings", :force => true do |t|
    t.string "setting"
    t.binary "value"
  end

  create_table "posts", :force => true do |t|
    t.integer  "user_id",     :limit => 11
    t.integer  "question_id", :limit => 11
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id", :limit => 11
    t.text     "body_html"
  end

  add_index "posts", ["category_id", "created_at"], :name => "index_posts_on_category_id"
  add_index "posts", ["user_id", "created_at"], :name => "index_posts_on_user_id"
  add_index "posts", ["question_id", "created_at"], :name => "index_posts_on_question_id"

  create_table "questions", :force => true do |t|
    t.integer  "category_id",  :limit => 11
    t.integer  "user_id",      :limit => 11
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hits",         :limit => 11, :default => 0
    t.integer  "sticky",       :limit => 11, :default => 0
    t.integer  "posts_count",  :limit => 11, :default => 0
    t.datetime "replied_at"
    t.boolean  "locked",                     :default => false
    t.integer  "replied_by",   :limit => 11
    t.integer  "last_post_id", :limit => 11
  end

  add_index "questions", ["category_id"], :name => "index_questions_on_category_id"
  add_index "questions", ["category_id", "sticky", "replied_at"], :name => "index_questions_on_sticky_and_replied_at"
  add_index "questions", ["category_id", "replied_at"], :name => "index_questions_on_category_id_and_replied_at"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
    t.integer  "user_id",    :limit => 11
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "topics", :force => true do |t|
    t.integer  "category_id",  :limit => 11
    t.integer  "user_id",      :limit => 11
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hits",         :limit => 11, :default => 0
    t.integer  "sticky",       :limit => 11, :default => 0
    t.integer  "posts_count",  :limit => 11, :default => 0
    t.datetime "replied_at"
    t.boolean  "locked",                     :default => false
    t.integer  "replied_by",   :limit => 11
    t.integer  "last_post_id", :limit => 11
  end

  add_index "topics", ["category_id"], :name => "index_topics_on_category_id"
  add_index "topics", ["category_id", "sticky", "replied_at"], :name => "index_topics_on_sticky_and_replied_at"
  add_index "topics", ["category_id", "replied_at"], :name => "index_topics_on_category_id_and_replied_at"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "password_hash"
    t.datetime "created_at"
    t.datetime "last_login_at"
    t.boolean  "admin"
    t.integer  "posts_count",          :limit => 11, :default => 0
    t.datetime "last_seen_at"
    t.string   "display_name"
    t.datetime "updated_at"
    t.string   "website"
    t.string   "login_key"
    t.datetime "login_key_expires_at"
    t.boolean  "activated",                          :default => false
    t.string   "bio"
    t.text     "bio_html"
    t.string   "openid_url"
  end

  add_index "users", ["last_seen_at"], :name => "index_users_on_last_seen_at"
  add_index "users", ["posts_count"], :name => "index_users_on_posts_count"

end
