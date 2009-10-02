require 'digest/md5'
require 'net/http'
require 'activesupport'

Net::HTTP.version_1_2

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
      username = self.channnel_server_user
      password = self.channnel_server_password

      userinfo = ActiveSupport::JSON.decode(Net::HTTP.get('plugins.openpne.jp', '/rest.php/user?user='+username))
      if userinfo then
        # try to login
        http = Net::HTTP.new('plugins.openpne.jp')
        response = http.post('/rest.php/authenticate', 'user='+username+'&password='+password)
        authenticate = ActiveSupport::JSON.decode(response.body)

        if !authenticate then
          errors.add_to_base '認証に失敗しました'
          errors.add_to_base Net::HTTP.get('plugins.openpne.jp', '/rest.php/user?user='+username)
          return
        end
      else
        if password == "" then
          errors.add_to_base 'パスワードを入力してください'
        end

        http = Net::HTTP.new('plugins.openpne.jp')
        http.post('/rest.php/user', 'user='+username+'&password='+password+'&name='+self.user.firstname+' '+self.user.lastname+'&email='+self.user.mail)
      end
    end
  end
end


