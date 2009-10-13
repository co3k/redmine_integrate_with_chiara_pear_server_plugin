require 'digest/md5'
require 'pear_channel_server_handler'

module PearServerUserPreferencePatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
    end

  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def channnel_server_user; self[:channnel_server_user] end
    def channnel_server_user=(username); self[:channnel_server_user]=username end
    def channnel_server_password; self[:channnel_server_password] end
    def channnel_server_password=(password)
      if password != "" then
        self[:channnel_server_password]=Digest::MD5.hexdigest(password)
      end
    end

    def validate
      handler = PearChannelServerHandler.new()

      username = self.channnel_server_user
      password = self.channnel_server_password

      if !username && !password then
        return
      end

      if handler.get_user(username) then
        if !handler.login(username, password) then
          errors.add_to_base '認証に失敗しました'
          return
        end
      else
        if password == "" then
          errors.add_to_base 'パスワードを入力してください'
        end

        handler.add_user(username, password, self.user.firstname+' '+self.user.lastname, self.user.mail)
      end
    end
  end
end


