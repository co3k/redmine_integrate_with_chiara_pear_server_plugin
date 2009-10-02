require 'activesupport'

class PearPackageController < ApplicationController
  unloadable

  def add
    @project = Project.find(params[:project_id])
    @user = User.current
    username = @user.pref.channnel_server_user
    password = @user.pref.channnel_server_password
    if request.post?
      info = params[:plugin]

      http = Net::HTTP.new('plugins.openpne.jp')
      response = http.post('/rest.php/authenticate', 'user='+username+'&password='+password)
      authenticate = ActiveSupport::JSON.decode(response.body)

      if !authenticate then
        flash[:error] = "プラグインチャンネルサーバとの通信に失敗しました。アカウント画面から、チャンネルサーバのユーザ名とパスワードの設定をおこなってからもう一度やりなおしてください。"
        redirect_to :action => 'add', :project_id => params[:project_id]
        return
      end

      if !(/^op.+Plugin$/ =~ info[:name])
        flash[:error] = "プラグイン名は op ではじまり、 Plugin で終わっている必要があります。"
        redirect_to :action => 'add', :project_id => params[:project_id]
        return
      end

      package = ActiveSupport::JSON.decode(Net::HTTP.get('plugins.openpne.jp', '/rest.php/package?user='+username+'&password='+password+'&package='+info[:name]))
      if package then
        is_lead = ActiveSupport::JSON.decode(Net::HTTP.get('plugins.openpne.jp', '/rest.php/isPackageLead?user='+username+'&password='+password+'&package='+info[:name]))
        if !is_lead then
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

        http = Net::HTTP.new('plugins.openpne.jp')
        response = http.post('/rest.php/package', 'user='+username+'&password='+password+'&package='+info[:name]+'&license='+info[:license]+'&summary='+info[:summary]+'&description='+info[:description])

      end



      @plugin_project = Project.new({
        "name" => info[:name],
        "description" => info[:description],
        "identifier" => info[:name][2 .. -7].underscore.gsub(/_/, '-'),
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
