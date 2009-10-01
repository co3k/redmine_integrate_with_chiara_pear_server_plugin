class PearUserController < ApplicationController
  unloadable

  def account
    @user = User.current
    if request.post?
      @user.pref.attributes = params[:pref]
      if @user.pref.save
        set_language_if_valid @user.language
        flash[:notice] = l(:notice_account_updated)
        redirect_to :action => 'account'
        return
      end
    end
  end

end
