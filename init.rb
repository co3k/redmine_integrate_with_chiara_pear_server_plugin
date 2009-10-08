require 'redmine'

# Hooks
require 'pear_server_hook.rb'

# Patches to the Redmine core
require 'dispatcher'

Dispatcher.to_prepare do
  require 'pear_server_user_preference_patch'
  UserPreference.send(:include, PearServerUserPreferencePatch)
end

Redmine::Plugin.register :redmine_integrate_with_chiara_pear_server_plugin do
  name 'Redmine Integrate With Chiara Pear Server Plugin plugin'
  author 'Kousuke Ebihara'
  description 'This is a plugin for Redmine'
  version '0.0.1'

  project_module :pear_channel_server do
    permission :pear_package, { :pear_package => [:add] }, :public => true
  end
  menu :project_menu, :pear_package, { :controller => 'pear_package', :action => 'add'}, :caption => 'プラグイン登録', :last => true, :param => :project_id, :if => Proc.new {User.current.logged?}
end
