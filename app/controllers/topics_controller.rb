class TopicsController < ApplicationController
  before_filter :find_forum_and_topic, :except => :index
  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy]
#  before_filter :update_last_seen_at, :only => :show

  def index
    redirect_to forum_path(params[:forum_id])
  end

  def new
    @topic = Topic.new
  end
  
  def show
    respond_to do |format|
      format.html do
        # see notes in application.rb on how this works
        update_last_seen_at
        # keep track of when we last viewed this topic for activity indicators
        (session[:topics] ||= {})[@topic.id] = Time.now.utc if logged_in?
        # authors of topics don't get counted towards total hits
        @topic.hit! unless logged_in? and @topic.user == current_user
        @post_pages, @posts = paginate(:posts, :per_page => 25, :order => 'posts.created_at', :include => :user, :conditions => ['posts.topic_id = ?', params[:id]])
        @voices = @posts.map(&:user) ; @voices.uniq!
        @post   = Post.new
      end
      format.rss do
        @posts = @topic.posts.find(:all, :order => 'created_at desc', :limit => 25)
        render :action => 'show.rxml', :layout => false
      end
    end
  end
  
  def create
    # this is icky - move the topic/first post workings into the topic model?
    Topic.transaction do
      @topic  = @forum.topics.build(params[:topic])
      assign_protected
      @topic.save!
      @post   = @topic.posts.build(params[:topic])
      @post.user = current_user
      @post.save!
    end
    redirect_to topic_path(@forum, @topic)
  end
  
  def update
    @topic.attributes = params[:topic]
    assign_protected
    @topic.save!
    redirect_to topic_path(@topic.forum, @topic)
  end
  
  def destroy
    @topic.destroy
    flash[:notice] = "Topic '#{CGI::escapeHTML @topic.title}' was deleted."
    redirect_to forum_path(@forum)
  end
  
  protected
    def assign_protected
      @topic.user     = current_user if @topic.new_record?
      # admins and moderators can sticky and lock topics
      return unless admin? or current_user.moderator_of?(@topic.forum)
      @topic.sticky, @topic.locked = params[:topic][:sticky], params[:topic][:locked] 
      # only admins can move
      return unless admin?
      @topic.forum_id = params[:topic][:forum_id] if params[:topic][:forum_id]
    end
    
    def find_forum_and_topic
      @forum = Forum.find(params[:forum_id])
      @topic = @forum.topics.find(params[:id]) if params[:id]
    end
    
    def authorized?
      %w(new create).include?(action_name) || @topic.editable_by?(current_user)
    end
end