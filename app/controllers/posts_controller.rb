class PostsController < ApplicationController
  before_filter :find_post,      :except => [:index, :create, :monitored, :search]
  before_filter :login_required, :except => [:index, :monitored, :search, :show]
  @@query_options = { :select => "#{Post.table_name}.*, #{Question.table_name}.title as question_title, #{Category.table_name}.name as category_name", :joins => "inner join #{Question.table_name} on #{Post.table_name}.question_id = #{Question.table_name}.id inner join #{Category.table_name} on #{Question.table_name}.category_id = #{Category.table_name}.id" }

  caches_formatted_page :rss, :index, :monitored
  cache_sweeper :posts_sweeper, :only => [:create, :update, :destroy]

  def index
    conditions = []
    [:user_id, :category_id, :question_id].each { |attr| conditions << Post.send(:sanitize_sql, ["#{Post.table_name}.#{attr} = ?", params[attr]]) if params[attr] }
    conditions = conditions.empty? ? nil : conditions.collect { |c| "(#{c})" }.join(' AND ')
    @posts = Post.paginate @@query_options.merge(:conditions => conditions, :page => params[:page], :count => {:select => "#{Post.table_name}.id"}, :order => post_order)
    @users = User.find(:all, :select => 'distinct *', :conditions => ['id in (?)', @posts.collect(&:user_id).uniq]).index_by(&:id)
    render_posts_or_xml
  end

  def search
    conditions = params[:q].blank? ? nil : Post.send(:sanitize_sql, ["LOWER(#{Post.table_name}.body) LIKE ?", "%#{params[:q]}%"])
    @posts = Post.paginate @@query_options.merge(:conditions => conditions, :page => params[:page], :count => {:select => "#{Post.table_name}.id"}, :order => post_order)
    @users = User.find(:all, :select => 'distinct *', :conditions => ['id in (?)', @posts.collect(&:user_id).uniq]).index_by(&:id)
    render_posts_or_xml :index
  end

  def monitored
    @user = User.find params[:user_id]
    options = @@query_options.merge(:conditions => ["#{Monitorship.table_name}.user_id = ? and #{Post.table_name}.user_id != ? and #{Monitorship.table_name}.active = ?", params[:user_id], @user.id, true])
    options[:order]  = post_order
    options[:joins] += " inner join #{Monitorship.table_name} on #{Monitorship.table_name}.question_id = #{Question.table_name}.id"
    options[:page]   = params[:page]
    options[:count]  = {:select => "#{Post.table_name}.id"}
    @posts = Post.paginate options
    render_posts_or_xml
  end

  def show
    respond_to do |format|
      format.html { redirect_to question_path(@post.category_id, @post.question_id) }
      format.xml  { render :xml => @post.to_xml }
    end
  end

  def create
    @question = Question.find_by_id_and_category_id(params[:question_id],params[:category_id])
    if @question.locked?
      respond_to do |format|
        format.html do
          flash[:notice] = 'This question is locked.'[:locked_question]
          redirect_to(question_path(:category_id => params[:category_id], :id => params[:question_id]))
        end
        format.xml do
          render :text => 'This question is locked.'[:locked_question], :status => 400
        end
      end
      return
    end
    @category = @question.category
    @post  = @question.posts.build(params[:post])
    @post.user = current_user
    @post.save!
    respond_to do |format|
      format.html do
        redirect_to question_path(:category_id => params[:category_id], :id => params[:question_id], :anchor => @post.dom_id, :page => params[:page] || '1')
      end
      format.xml { head :created, :location => formatted_post_url(:category_id => params[:category_id], :question_id => params[:question_id], :id => @post, :format => :xml) }
    end
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = 'Please post something at least...'[:post_something_message]
    respond_to do |format|
      format.html do
        redirect_to question_path(:category_id => params[:category_id], :id => params[:question_id], :anchor => 'reply-form', :page => params[:page] || '1')
      end
      format.xml { render :xml => @post.errors.to_xml, :status => 400 }
    end
  end
  
  def edit
    respond_to do |format| 
      format.html
      format.js
    end
  end
  
  def update
    @post.attributes = params[:post]
    @post.save!
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = 'An error occurred'[:error_occured_message]
  ensure
    respond_to do |format|
      format.html do
        redirect_to question_path(:category_id => params[:category_id], :id => params[:question_id], :anchor => @post.dom_id, :page => params[:page] || '1')
      end
      format.js
      format.xml { head 200 }
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = "Post of '{title}' was deleted."[:post_deleted_message, @post.question.title]
    respond_to do |format|
      format.html do
        redirect_to(@post.question.frozen? ? 
          category_path(params[:category_id]) :
          question_path(:category_id => params[:category_id], :id => params[:question_id], :page => params[:page]))
      end
      format.xml { head 200 }
    end
  end

  protected
    def authorized?
      action_name == 'create' || @post.editable_by?(current_user)
    end
    
    def post_order
      "#{Post.table_name}.created_at#{params[:category_id] && params[:question_id] ? nil : " desc"}"
    end
    
    def find_post
      @post = Post.find_by_id_and_question_id_and_category_id(params[:id], params[:question_id], params[:category_id]) || raise(ActiveRecord::RecordNotFound)
    end
    
    def render_posts_or_xml(template_name = action_name)
      respond_to do |format|
        format.html { render :action => template_name }
        format.rss  { render :action => template_name, :layout => false }
        format.xml  { render :xml => @posts.to_xml }
      end
    end
end
