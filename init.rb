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
end
