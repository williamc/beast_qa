class MonitorshipsController < ApplicationController
  before_filter :login_required

  cache_sweeper :monitorships_sweeper, :only => [:create, :destroy]

  def create
    @monitorship = Monitorship.find_or_initialize_by_user_id_and_question_id(current_user.id, params[:question_id])
    @monitorship.update_attribute :active, true
    respond_to do |format| 
      format.html { redirect_to question_path(params[:category_id], params[:question_id]) }
      format.js
    end
  end
  
  def destroy
    Monitorship.update_all ['active = ?', false], ['user_id = ? and question_id = ?', current_user.id, params[:question_id]]
    respond_to do |format| 
      format.html { redirect_to question_path(params[:category_id], params[:question_id]) }
      format.js
    end
  end
end
