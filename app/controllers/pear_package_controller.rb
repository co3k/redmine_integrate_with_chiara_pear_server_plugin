require 'activesupport'
require 'pear_channel_server_handler'

class PearPackageController < ApplicationController
  unloadable
  before_filter :require_login

  def add
    @project = Project.find(params[:project_id])
    @user = User.current
    username = @user.pref.channnel_server_user
    password = @user.pref.channnel_server_password
    if request.post?
      info = params[:plugin]

      handler = PearChannelServerHandler.new()
      if !handler.login(username, password) then
        flash[:error] = "プラグインチャンネルサーバとの通信に失敗しました。アカウント画面から、チャンネルサーバのユーザ名とパスワードの設定をおこなってからもう一度やりなおしてください。"
        redirect_to :action => 'add', :project_id => params[:project_id]
        return
      end

      if !(/^op.+Plugin$/ =~ info[:name])
        flash[:error] = "プラグイン名は op ではじまり、 Plugin で終わっている必要があります。"
        redirect_to :action => 'add', :project_id => params[:project_id]
        return
      end

      package = handler.get_package(info[:name])
      if package then
        if !handler.is_package_lead(info[:name]) then
          flash[:error] = "lead ではないため、プラグインの紐付けがおこなえませんでした。"
          redirect_to :action => 'add', :project_id => params[:project_id]
          return
        end
      else
        if info[:name] == "" || info[:license] == "" || info[:summary] == "" || info[:description] == "" then
          flash[:error] = "新しくプラグインを登録する場合、プラグイン名、ライセンス、概要、説明は必須項目です。"
          redirect_to :action => 'add', :project_id => params[:project_id]
          return
        end

        handler.add_package(info[:name], info[:license], info[:summary], info[:description])
      end

      @plugin_project = Project.new({
        "name" => info[:name],
        "description" => info[:description],
        "identifier" => 'plg-'+info[:name][2 .. -7].underscore.gsub(/_/, '-'),
        "parent_id" => params[:parent_id]
      });
      @plugin_project.enabled_module_names = ['repository', 'issue_tracking']
      if @plugin_project.save
        @plugin_project.set_parent!(@project)
        r = Role.givable.find_by_id(Setting.new_project_user_role_id.to_i) || Role.givable.first
        m = Member.new(:user => User.current, :roles => [r])
        @plugin_project.members << m
        flash[:notice] = "プラグインが正しく登録されました。"
        redirect_to :action => 'add', :project_id => params[:project_id]
      end
    end
  end
end
