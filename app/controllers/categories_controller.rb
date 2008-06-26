class CategoriesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  before_filter :find_or_initialize_category, :except => :index

  cache_sweeper :answers_sweeper, :only => [:create, :update, :destroy]

  def index
    @categories = Category.find_ordered
    # reset the page of each category we have visited when we go back to index
    session[:category_page] = nil
    respond_to do |format|
      format.html
      format.xml { render :xml => @categories }
    end
  end

  def show
    respond_to do |format|
      format.html do
        # keep track of when we last viewed this category for activity indicators
        (session[:categories] ||= {})[@category.id] = Time.now.utc if logged_in?
        (session[:category_page] ||= Hash.new(1))[@category.id] = params[:page].to_i if params[:page]

        @questions = @category.questions.paginate :page => params[:page]
        User.find(:all, :conditions => ['id IN (?)', @questions.collect { |t| t.replied_by }.uniq]) unless @questions.blank?
      end
      format.xml { render :xml => @category }
    end
  end

  # new renders new.html.erb
  
  def create
    @category.attributes = params[:category]
    @category.save!
    respond_to do |format|
      format.html { redirect_to @category }
      format.xml  { head :created, :location => formatted_category_url(@category, :xml) }
    end
  end

  def update
    @category.update_attributes!(params[:category])
    respond_to do |format|
      format.html { redirect_to @category }
      format.xml  { head 200 }
    end
  end
  
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_path }
      format.xml  { head 200 }
    end
  end
  
  protected
    def find_or_initialize_category
      @category = params[:id] ? Category.find(params[:id]) : Category.new
    end

    alias authorized? admin?
end
