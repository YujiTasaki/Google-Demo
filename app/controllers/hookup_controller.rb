require 'http'
require 'google/api_client'
require 'date'

#GoogleCalendarのAOuth認証
class HookupController < ApplicationController
  
  # この↓一文がないとCSRF(Cross-Site Request Forgery)チェックでこけるので、APIをやりとりしているControllerには必要
  skip_before_filter :verify_authenticity_token
  
  #kke.remotelock@gmail.com
  @@googleAccountId = APP_CONFIG["google"]["user_name"]
  
  #クライアントID,クライアントシークレット,承認済みのリダイレクトURI,カレンダーIDを入力
  def setup
  end
  
  #上記変数を受取る
  def getcode
    
    @@clientId = params[:clientId]
    @@clientSecret = params[:clientSecret]
    @@calendarId = params[:calendarId]
    @@redirectUri = params[:redirectUri]
    
    #GoogleAccountテーブルに値を保存⇒1アカウントにつき1カレンダーIDとする
    if GoogleAccount.find_by(account_id: APP_CONFIG["google"]["user_name"]) == nil
    #新規作成
      googleAccount = GoogleAccount.new(account_id: @@googleAccountId, client_id: @@clientId, client_secret: @@clientSecret, calendar_id:@@calendarId, redirect_uri:@@redirectUri )
      googleAccount.save
    else
    #更新
      id = GoogleAccount.find_by(account_id: APP_CONFIG["google"]["user_name"]).id
      gAccount = GoogleAccount.find(id)
      gAccount.update_attributes(:client_id => @@clientId, :client_secret => @@clientSecret, :calendar_id => @@calendarId, :redirect_uri => @@redirectUri)
    end  
    
    #google認証のURLにリダイレクト
    url = 'https://accounts.google.com/o/oauth2/auth?client_id=' + @@clientId + '&redirect_uri=' + @@redirectUri + 
    '&scope=https://www.googleapis.com/auth/calendar&response_type=code&approval_prompt=force&access_type=offline'
    
    redirect_to(url)
  end
  
  
  #google認証後のリダイレクト先URI
  def callback
    
    #引数(=コード)を取得して、DBを更新
    code = params[:code]
    if GoogleAccount.find_by(account_id: @@googleAccountId) != nil
      result = GoogleAccount.where(:account_id => @@googleAccountId).update_all(:code => code)
    end
    
    #リフレッシュトークンとアクセストークンを取得してDB保存
    googleToken = GoogleToken.new
    googleToken.refresh
    
    #アクセストークンを利用してチャネルを作成
  	createchannel
  	render action: 'createchannel'

  end
  
  
  #アクセストークンを利用してチャネルを作成
  def createchannel
    #channel作成
    googleChannel = GoogleChannel.new
    @status = googleChannel.update
    
    if @status != "認証に成功しました"
      #google_accountsとgoogle_tokensのDBを削除
      if GoogleAccount.find_by(account_id: @@googleAccountId) != nil
        gaId = GoogleAccount.find_by(account_id: @@googleAccountId).id
        GoogleAccount.delete(gaId)
      end
      if GoogleToken.find_by(account_id: @@googleAccountId) != nil
        gtId = GoogleToken.find_by(account_id: @@googleAccountId).id
        GoogleToken.delete(gtId)
      end
    end
    
  end
  
  
end
