# Hooks to attach to the Redmine Projects.
class PearServerHook < Redmine::Hook::ViewListener

  def protect_against_forgery?
    false
  end

  # Context:
  # * :user
  # * :form
  def view_my_account(context ={ })
    return "<h4>プラグインチャンネルサーバ設定</h4>
    <p style=\"padding-left: 0\">#{link_to "こちら", :controller => 'pear_user', :action => 'account'}から設定をおこなってください</p>"
  end

end
