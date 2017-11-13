include ConnectHttp
require 'net/https'
require 'http'
require 'time'
  
#ConnectのAOuth認証
class ConnecthookupController < ApplicationController
  
  def setup
    #認証情報の入力画面
    #print "セッション"
    #print session["session_id"]
    #session[:test]="テスト"
    #hensuu = Session.find_by(:session_id => session[:session_id])
    #print session["test"]
  end
    
  def getcode
    print('getcode来た')
    @@key = 	params[:email].presence	|| APP_CONFIG["connect"]["user_name"]
    @@client =	params[:clientId].presence || APP_CONFIG["connect"]["client"]
    @@secret =	params[:clientSecret].presence || APP_CONFIG["connect"]["secret"]
    #@@callbackuri = URI.encode(APP_CONFIG["webhost"]+'connecthookup/callback')
    @@callbackuri = 'https://rails-tutorial-kke1573.c9users.io/connecthookup/callback'
    #params[:uuId]
    
    #if ConnectAccount.find_by(key: @@key) == nil
    #  account = ConnectAccount.new(key: @@key,client_id: @@client,client_secret: @@secret)
    #  account.save
    #end
    
    req = 'https://connect.lockstate.jp/oauth/'+'authorize?'+'client_id='+@@client+'&response_type=code&redirect_uri='+@@callbackuri
    redirect_to req
  end

  #トークンの受取り
  def callback
    tmp_token = params[:code]
    postform = {'code' => tmp_token \
    ,'client_id' => @@client \
    ,'client_secret' => @@secret \
    ,'redirect_uri' => @@callbackuri\
    ,'grant_type' => 'authorization_code' }
    
    
    
    res = HTTP.headers("Content-Type" => "application/x-www-form-urlencoded")
    .post("https://connect.lockstate.jp/oauth/token", :ssl_context => CTX , :form => postform)
   
    if res.code!=200
      @res = res
      @error = res
      @state = "認証に失敗しました"
      render
    else
      @res = res
      @error = ""
      j = ActiveSupport::JSON.decode( @res.body )
      require 'time'
      #require 'date'
      #Time.now.strftime("%Y年 %m月 %d日, %H:%M:%S")
      key =	@@key
      data = { \
        :key => key \
        ,:access_token => j["access_token"] \
        ,:refresh_token => j["refresh_token"] \
        ,:expire => Time.at(j["created_at"])+j["expires_in"].second \
        ,:status => 1
      }
      #begin
      
      if ConnectToken.find_by(key: key) == nil
        connecttoken = ConnectToken.new(data)
        connecttoken.save
        puts "新しいものとして認識"
      else
        connecttoken = ConnectToken.find_by(:key => key)
        ConnectToken.update(connecttoken.id , :key => key,:access_token => j["access_token"] ,:refresh_token => j["refresh_token"] ,:expire => j["created_at"]+j["expires_in"],:updated_at => Time.now)
        puts "更新する"
      end
      #rescue
      #  puts "データベースへの保存で問題が発生しました"
      #end
      session[:session_id]
      @res = connecttoken
      @state = "認証に成功しました"
      render
    end
  end
  
  def selectlock
    res = ConnectApiExec.getlocks( @@key )
    @locks = [["名前","Wi-Fi接続レベル","デバイスID"]] 
    res['data'].each do |lock|
      @locks.append( [lock["attributes"]["name"],lock["attributes"]["wifi_level"],lock["id"]] )
      if ConnectLock.find_by(:uuid => lock["id"]) == nil
        lockrecord = ConnectLock.new(:uuid => lock["id"],:account_id => @@client )
        lockrecord.save
      end
    end
    render
  end
  
end
