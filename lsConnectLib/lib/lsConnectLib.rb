require "lsConnectLib/version"

require 'lsConnectLib/OAuth'

#module LsConnectLib
module TestGem

  @max_network_retry_delay = 2
  @initial_network_retry_delay = 0.5

  class << self
    attr_accessor :client_id, :clientSecret_id
    #aa

    attr_reader :max_network_retry_delay, :initial_network_retry_delay
  end  
  
  #def self.auth
    # auth起動
    #require 'lsConnectLib/OAuth'
    # access user登録
    # access gest登録
    # decive 登録
    # device 紐付け
    # mail送信
  #end
end
#end
