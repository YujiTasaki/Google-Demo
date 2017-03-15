include ConnectHttp
require 'google/api_client'
require 'json'


class NotificationsController < ApplicationController
  
  # この↓一文がないとCSRF(Cross-Site Request Forgery)チェックでこけるので、APIをやりとりしているControllerには必要
  skip_before_filter :verify_authenticity_token
  
  #kke.remotelock@gmail.com
  @@googleAccountId = APP_CONFIG["google"]["user_name"]
  
  @@count = 0
  @@email = ""
  @@startStr = ""
  @@endStr = ""
  
  #push notificationの受取り
  def callback
    
	  @@count = @@count + 1
	  puts(@@count) 
	  
    #googleCalendarからのrequest情報
    channelId = request.headers["HTTP_X_GOOG_CHANNEL_ID"]#これで判定する。
    resourceId = request.headers["HTTP_X_GOOG_RESOURCE_ID"]
    
    #不要なchannelの削除
	  #deletechannel( channelId, resourceId )
    
    #イベント情報の取得
	  getevent
	  
  end
  
  
  #不要なchannelの削除
  def deletechannel( channelId, resourceId )
    accessToken = GoogleToken.find_by(account_id: @@googleAccountId).access_token
	  
    postbody = {
      "id": channelId,
      "resourceId": resourceId,
    }
    
    auth = "Bearer " + accessToken
    res = HTTP.headers("Content-Type" => "application/json",:Authorization => auth)
    .post("https://www.googleapis.com/calendar/v3/channels/stop", :ssl_context => CTX , :body => postbody.to_json)
    
    puts("channel削除")
    puts(res.code)
  end
  
  
  #イベント情報の取得
  def getevent
    
    #hookupクラスインスタンスの初期化
    hookup = HookupController.new
    
    clientId = GoogleAccount.find_by(account_id: @@googleAccountId).client_id
    clientSecret = GoogleAccount.find_by(account_id: @@googleAccountId).client_secret
    calendarId = GoogleAccount.find_by(account_id: @@googleAccountId).calendar_id
    refreshToken = GoogleToken.find_by(account_id: @@googleAccountId).refresh_token
    
    #カレンダーIDに紐付いたデバイスIDを取得
    lockId = CalendarToLock.find_by(calendar_id: calendarId).lock_id
    debugger
    #GoogleApiイベントメソッド呼出し
    client = Google::APIClient.new
    client.authorization.client_id = clientId
    client.authorization.client_secret = clientSecret
    client.authorization.refresh_token = refreshToken
    client.authorization.fetch_access_token!
    
    service = client.discovered_api('calendar', 'v3')
    
    res = client.execute!(
      api_method: service.events.list,
      parameters: {
        calendarId: calendarId,
        updatedMin: 1.minute.ago.to_datetime.rfc3339
      }
    )
    
    res_hash = ActiveSupport::JSON.decode(res.body)
    items = res_hash["items"]
    puts("イベント情報の取得")
    puts(items)
    
    if !items.blank?
      email = ""
      addemail = ""
      startStr = ""
      endStr = ""
      
      items.each do |item|
        email = item["creator"]["email"]
        startStr = item["start"]["dateTime"]
        endStr = item["end"]["dateTime"]
        
        #debugger
        if startStr.blank?
          startStr = item["start"]["date"]
        end
        if endStr.blank?
          endStr = item["end"]["date"]
        end 
        
        #登録ユーザのアクセス権を取得
        callconnectapi(email, email, startStr, endStr, lockId)
        
        #追加メンバーのアクセス権を取得
        attendees = item["attendees"]
        if !attendees.blank?
          attendees.each do |attendee|
            addemail = attendee["email"]
            callconnectapi(email, addemail, startStr, endStr, lockId)
          end
        end
      end
      
      @@email = email
      @@startStr = startStr
      @@endStr = endStr
      
    else
      puts("まだ")
	  end
    
  end
  
  
  #ConnectApiメソッド呼出し
  def callconnectapi(email, addemail, startStr, endStr, lockId)
    if @@email != email or @@startStr != startStr or @@endStr != endStr
      #ISO 8601時刻で日本時刻を世界時刻に変更（タイムゾーン+09:00 の文字列を削除(JST)）
      #startDatetime = startStr.to_datetime - Rational(9, 24)  
      startAt = startStr.slice(0,19)
      #endDatetime = endStr.to_datetime - Rational(9, 24)  
      endAt = endStr.slice(0,19)
      #ConnectAPIの呼出し
      #connectApi = ConnectApiExec.new
      #アクセスゲストの作成
      ConnectApiExec.createguests(addemail,startAt,endAt,lockId)
    end
  end
  
end
