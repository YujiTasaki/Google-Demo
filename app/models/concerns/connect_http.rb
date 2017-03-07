module ConnectHttp
  require 'http'
  require 'json'
  extend ActiveSupport::Concern
  CTX = OpenSSL::SSL::SSLContext.new
  CTX.verify_mode = OpenSSL::SSL::VERIFY_NONE
end