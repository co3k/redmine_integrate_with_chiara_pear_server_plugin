require 'pear_channel_server_handler'

class PearAdminController < ApplicationController

  before_filter :require_admin

  def index
    @project = Project.find(params[:project_id])
  end

  def user
    @project = Project.find(params[:project_id])
    user = User.current

    handler = PearChannelServerHandler.new()
    handler.login(user.pref.channnel_server_user, user.pref.channnel_server_password)
    @users = handler.get_users()

    if request.post?
      handler.delete_user(params[:handle])

      flash[:notice] = "ユーザを正常に削除しました。"
      redirect_to :action => 'user', :project_id => params[:project_id]
    end
  end
end
