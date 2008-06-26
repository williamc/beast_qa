class QuestionsController < ApplicationController
  before_filter :find_category_and_question, :except => :index
  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy]

  caches_formatted_page :rss, :show
  cache_sweeper :posts_sweeper, :only => [:create, :update, :destroy]

  def index
    respond_to do |format|
      format.html { redirect_to category_path(params[:category_id]) }
      format.xml do
        @questions = Question.paginate_by_category_id(params[:category_id], :order => 'sticky desc, replied_at desc', :page => params[:page])
        render :xml => @questions.to_xml
      end
    end
  end

  def new
    @question = Question.new
  end
  
  def show
    respond_to do |format|
      format.html do
        # see notes in application.rb on how this works
        update_last_seen_at
        # keep track of when we last viewed this question for activity indicators
        (session[:questions] ||= {})[@question.id] = Time.now.utc if logged_in?
        # authors of questions don't get counted towards total hits
        @question.hit! unless logged_in? and @question.user == current_user
        @posts = @question.posts.paginate :page => params[:page]
        User.find(:all, :conditions => ['id IN (?)', @posts.collect { |p| p.user_id }.uniq]) unless @posts.blank?
        @post   = Post.new
      end
      format.xml do
        render :xml => @question.to_xml
      end
      format.rss do
        @posts = @question.posts.find(:all, :order => 'created_at desc', :limit => 25)
        render :action => 'show', :layout => false
      end
    end
  end
  
  def create
    # this is icky - move the question/first post workings into the question model?
    Question.transaction do
      @question  = @category.questions.build(params[:question])
      assign_protected
      @post       = @question.posts.build(params[:question])
      @post.question = @question
      @post.user  = current_user
      # only save question if post is valid so in the view question will be a new record if there was an error
      @question.body = @post.body # incase save fails and we go back to the form
      @question.save! if @post.valid?
      @post.save! 
    end
    respond_to do |format|
      format.html { redirect_to question_path(@category, @question) }
      format.xml  { head :created, :location => formatted_question_url(:category_id => @category, :id => @question, :format => :xml) }
    end
  end
  
  def update
    @question.attributes = params[:question]
    assign_protected
    @question.save!
    respond_to do |format|
      format.html { redirect_to question_path(@category, @question) }
      format.xml  { head 200 }
    end
  end
  
  def destroy
    @question.destroy
    flash[:notice] = "Question '{title}' was deleted."[:question_deleted_message, @question.title]
    respond_to do |format|
      format.html { redirect_to category_path(@category) }
      format.xml  { head 200 }
    end
  end
  
  protected
    def assign_protected
      @question.user     = current_user if @question.new_record?
      # admins and moderators can sticky and lock questions
      return unless admin? or current_user.moderator_of?(@question.category)
      @question.sticky, @question.locked = params[:question][:sticky], params[:question][:locked] 
      # only admins can move
      return unless admin?
      @question.category_id = params[:question][:category_id] if params[:question][:category_id]
    end
    
    def find_category_and_question
      @category = Category.find(params[:category_id])
      @question = @category.questions.find(params[:id]) if params[:id]
    end
    
    def authorized?
      %w(new create).include?(action_name) || @question.editable_by?(current_user)
    end
end
