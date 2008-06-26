class AnswersController < ApplicationController
  before_filter :find_answer,      :except => [:index, :create, :monitored, :search]
  before_filter :login_required, :except => [:index, :monitored, :search, :show]
  @@query_options = { :select => "#{Answer.table_name}.*, #{Question.table_name}.title as question_title, #{Category.table_name}.name as category_name", :joins => "inner join #{Question.table_name} on #{Answer.table_name}.question_id = #{Question.table_name}.id inner join #{Category.table_name} on #{Question.table_name}.category_id = #{Category.table_name}.id" }

  caches_formatted_page :rss, :index, :monitored
  cache_sweeper :answers_sweeper, :only => [:create, :update, :destroy]

  def index
    conditions = []
    [:user_id, :category_id, :question_id].each { |attr| conditions << Answer.send(:sanitize_sql, ["#{Answer.table_name}.#{attr} = ?", params[attr]]) if params[attr] }
    conditions = conditions.empty? ? nil : conditions.collect { |c| "(#{c})" }.join(' AND ')
    @answers = Answer.paginate @@query_options.merge(:conditions => conditions, :page => params[:page], :count => {:select => "#{Answer.table_name}.id"}, :order => answer_order)
    @users = User.find(:all, :select => 'distinct *', :conditions => ['id in (?)', @answers.collect(&:user_id).uniq]).index_by(&:id)
    render_answers_or_xml
  end

  def search
    conditions = params[:q].blank? ? nil : Answer.send(:sanitize_sql, ["LOWER(#{Answer.table_name}.body) LIKE ?", "%#{params[:q]}%"])
    @answers = Answer.paginate @@query_options.merge(:conditions => conditions, :page => params[:page], :count => {:select => "#{Answer.table_name}.id"}, :order => answer_order)
    @users = User.find(:all, :select => 'distinct *', :conditions => ['id in (?)', @answers.collect(&:user_id).uniq]).index_by(&:id)
    render_answers_or_xml :index
  end

  def monitored
    @user = User.find params[:user_id]
    options = @@query_options.merge(:conditions => ["#{Monitorship.table_name}.user_id = ? and #{Answer.table_name}.user_id != ? and #{Monitorship.table_name}.active = ?", params[:user_id], @user.id, true])
    options[:order]  = answer_order
    options[:joins] += " inner join #{Monitorship.table_name} on #{Monitorship.table_name}.question_id = #{Question.table_name}.id"
    options[:page]   = params[:page]
    options[:count]  = {:select => "#{Answer.table_name}.id"}
    @answers = Answer.paginate options
    render_answers_or_xml
  end

  def show
    respond_to do |format|
      format.html { redirect_to question_path(@answer.category_id, @answer.question_id) }
      format.xml  { render :xml => @answer.to_xml }
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
    @answer  = @question.answers.build(params[:answer])
    @answer.user = current_user
    @answer.save!
    respond_to do |format|
      format.html do
        redirect_to question_path(:category_id => params[:category_id], :id => params[:question_id], :anchor => @answer.dom_id, :page => params[:page] || '1')
      end
      format.xml { head :created, :location => formatted_answer_url(:category_id => params[:category_id], :question_id => params[:question_id], :id => @answer, :format => :xml) }
    end
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = 'Please answer something at least...'[:answer_something_message]
    respond_to do |format|
      format.html do
        redirect_to question_path(:category_id => params[:category_id], :id => params[:question_id], :anchor => 'reply-form', :page => params[:page] || '1')
      end
      format.xml { render :xml => @answer.errors.to_xml, :status => 400 }
    end
  end
  
  def edit
    respond_to do |format| 
      format.html
      format.js
    end
  end
  
  def update
    @answer.attributes = params[:answer]
    @answer.save!
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = 'An error occurred'[:error_occured_message]
  ensure
    respond_to do |format|
      format.html do
        redirect_to question_path(:category_id => params[:category_id], :id => params[:question_id], :anchor => @answer.dom_id, :page => params[:page] || '1')
      end
      format.js
      format.xml { head 200 }
    end
  end

  def destroy
    @answer.destroy
    flash[:notice] = "Answer of '{title}' was deleted."[:answer_deleted_message, @answer.question.title]
    respond_to do |format|
      format.html do
        redirect_to(@answer.question.frozen? ? 
          category_path(params[:category_id]) :
          question_path(:category_id => params[:category_id], :id => params[:question_id], :page => params[:page]))
      end
      format.xml { head 200 }
    end
  end

  protected
    def authorized?
      action_name == 'create' || @answer.editable_by?(current_user)
    end
    
    def answer_order
      "#{Answer.table_name}.created_at#{params[:category_id] && params[:question_id] ? nil : " desc"}"
    end
    
    def find_answer
      @answer = Answer.find_by_id_and_question_id_and_category_id(params[:id], params[:question_id], params[:category_id]) || raise(ActiveRecord::RecordNotFound)
    end
    
    def render_answers_or_xml(template_name = action_name)
      respond_to do |format|
        format.html { render :action => template_name }
        format.rss  { render :action => template_name, :layout => false }
        format.xml  { render :xml => @answers.to_xml }
      end
    end
end
