require 'digest/md5'
require 'net/http'
require 'activesupport'

Net::HTTP.version_1_2

class PearChannelServerHandler

  def initialize
    @http = Net::HTTP.new('plugins.openpne.jp')
    @entry_point = '/rest.php'
    @token_param = ''
  end

  def login(username, password)
    param = 'user='+username+'&password='+password
    response = @http.post(@entry_point+'/authenticate', param)

    if ActiveSupport::JSON.decode(response.body) then
      @token_param = param
      return true
    end

    return false
  end

  def get_user(username)
    response = @http.get(@entry_point+'/user?user='+username)
    return ActiveSupport::JSON.decode(response.body)
  end

  def get_users()
    response = @http.get(@entry_point+'/users?'+@token_param)
    return ActiveSupport::JSON.decode(response.body)
  end

  def add_user(username, password, name, email)
    @http.post(@entry_point+'/user', 'user='+username+'&password='+password+'&name='+name+'&email='+email)
  end

  def delete_user(username)
    @http.delete(@entry_point+'/user?'+@token_param+'&username='+username)
  end

  def get_package(package)
    response = @http.get(@entry_point+'/package'+@token_param+'&package='+package)
    return ActiveSupport::JSON.decode(response.body)
  end

  def is_package_lead(package)
    response = @http.get(@entry_point+'/isPackageLead'+@token_param+'&package='+package)
    return ActiveSupport::JSON.decode(response.body)
  end

  def add_package(name, license, summary, description)
    @http.post(@entry_point+'/package', @token_param+'&package='+name+'&license='+license+'&summary='+summary+'&description='+description)
  end
end
