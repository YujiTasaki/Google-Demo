class ConnectApiExec
    require 'http'
    include ConnectHttp
    
    def self.refreshtoken(account)
        #accountは更新するconnecttokensのレコード
        postform = {
            'client_id' => ConnectAccount.find_by(key: account.key).client_id ,
            'client_secret' => ConnectAccount.find_by(key: account.key).client_secret ,
            'refresh_token' => account.refresh_token,
            'grant_type' => 'refresh_token'     
        }
    end
    
    #アクセスゲスト作成
    def self.createguests(email="名無し", statAt="2017-01-24T16:04:00", endAt="2017-01-25T16:04:00", lockId="c744baed-9b63-4b73-bbcc-a5406ebdd8ae")
        
        #PINコード番号のランダム生成
        pin = (0..9).sort_by{rand}[0,6].join.to_s
        #pin = (0..3).sort_by{rand}[0,4].join.to_s
        
        #emailからname生成
        #name = email
        #name = name.slice!(email.index("@"), email.length - email.index("@") + 1)
       
        postbody = {
          "type": "access_guest",
          "attributes": {
            "name": email,
            "pin": pin,
            "starts_at": statAt,
            "ends_at": endAt,
            "email": email
          }
        }
        
        authtoken = "Bearer "+ ConnectToken.find_by(key: "demo@remotelock.com").access_token
        res = HTTP.headers("Content-Type" => "application/json",:Authorization => authtoken )
        .post("https://api.lockstate.jp/access_persons", :ssl_context => CTX , :body => postbody.to_json)
        
        return res
        
    end
  
    
    #アクセスゲストにロック権限を追加
    def self.appendguest2lock(access_persons_id = "0905462f-1a3c-45fd-a330-85c0865d5ef5", lockId = "c744baed-9b63-4b73-bbcc-a5406ebdd8ae")
        #ctx = OpenSSL::SSL::SSLContext.new
        #ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
        postbody = {
          "attributes": {
            "accessible_id": lockId,
            "accessible_type": "lock",
          }
        }
        
        authtoken = "Bearer "+ ConnectToken.find_by(key: APP_CONFIG["connect"]["user_name"]).access_token
        apiUri = "https://api.lockstate.jp/access_persons/" + access_persons_id + "/accesses"
        
        res = HTTP.headers("Content-Type" => "application/json",:Authorization => authtoken)
        .post(apiUri, :ssl_context => CTX , :body => postbody.to_json)
        
        return res
    end
    
    
    #アクセスゲストにメールを送信
    def self.sendemail(access_persons_id = "0905462f-1a3c-45fd-a330-85c0865d5ef5")
        authtoken = "Bearer "+ ConnectToken.find_by(key: APP_CONFIG["connect"]["user_name"]).access_token
        apiuri = "https://api.lockstate.jp/access_persons/" + access_persons_id + "/email/notify"
        
        res = HTTP.headers("Content-Type" => "application/json","Accept-Language" => "ja", :Authorization => authtoken )
        .post(apiuri, :ssl_context => CTX)
        
        return res
    end
    
    
    #ロック一覧を取得
    def self.getlocks(user_name)
        client_id = ConnectAccount.find_by(key: user_name).client_id
        authtoken = "Bearer "+ ConnectToken.find_by(key: user_name).access_token
        res = HTTP.headers(:accept => "vnd.lockstate.v1+json",:Authorization => authtoken)
        .get("https://api.lockstate.jp/devices?type=lock", :ssl_context => CTX)
        @res = ActiveSupport::JSON.decode(res.body)
        #puts @res
        return @res
    end
    
    def post_connect(postform)
        res = HTTP.headers("Content-Type" => "application/x-www-form-urlencoded")
        .post("https://connect.lockstate.jp/oauth/token", :ssl_context => CTX , :form => postform)
        return res
    end
    
    def get_connect(uri)
        return
    end
    
    #アクセスゲスト削除
    def self.deleteguests(userId)
        
        authtoken = "Bearer "+ ConnectToken.find_by(key: "demo@remotelock.com").access_token
        res = HTTP.headers("Content-Type" => "application/json",:Authorization => authtoken )
        .delete("https://api.lockstate.jp/access_persons/" + userId, :ssl_context => CTX )
        
        return res
        
    end
    
    
    
    
end