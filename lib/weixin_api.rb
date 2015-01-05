require "weixin_api/version"
require "rest-client"
require "multi_json"

module Kehutong

  class WeixinApi

    @@access_token = nil

    ACCESS_TOKEN_ERRCODES = [40001, 40014, 41001, 42001]
    OPENID_ERRCODES = [40003]

    def initialize(weixin_info = {})
      @app_id = weixin_info[:app_id]
      @app_secret = weixin_info[:app_secret]
      @token = weixin_info[:token] || 'weixin'
    end

    #To validate weixin get request and return what's you should return to weixin server
    def validate(params)
      if _validate?(params)
        { text: params[:echostr], status: 200 }
      else
        { text: 'Forbidden', status: 403 }
      end
    end

    #To confirm whether the message is sent by weixin
    def validate?(params)
      _validate?(params)
    end

    #To fetch user info from weixin by snsapi_base of weixin o_auth
    def fetch_user_info_by_base_oauth(code)
      open_id = _oauth_get_open_id(code)
      _fetch_user_info(open_id)
    end

    #To generate temporary qrcode
    def generate_temporary_qrcode(scene_id)
      _generate_qrcode(scene_id, 'QR_SCENE')
    end

    #To generate forever qrcode
    def generate_forever_qrcode(scene_id)
      _generate_qrcode(scene_id, 'QR_LIMIT_SCENE')
    end

    def fetch_user(open_id)
      _fetch_user_info(open_id)
    end

    def fetch_open_id(code)
      _oauth_get_open_id(code)
    end

    private

    def _validate?(params)
      encoded_string = Digest::SHA1.hexdigest([@token, params[:timestamp], params[:nonce]].sort.join)
      params[:signature] == encoded_string
    end

    def _oauth_get_open_id(code)
      RestClient.get("https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{@app_id}&secret=#{@app_secret}&code=#{code}&grant_type=authorization_code") do |response|
        MultiJson.load(response)['openid']
      end
    end

    def _fetch_user_info(open_id)
      request_to_weixin {
        RestClient.get("https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{@@access_token}&openid=#{open_id}&lang=zh_CN")
      }
    end

    def _fetch_access_token
      RestClient.get("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{@app_id}&secret=#{@app_secret}") do |response|
        @@access_token = MultiJson.load(response)['access_token']
      end
    end

    def _generate_qrcode(scene_id, action_name)
      qrcode_data = {"action_name" => action_name, "action_info" => {"scene" => {"scene_id" => scene_id}}}
      qrcode_data.merge!({"expire_seconds" => 1800}) if "QR_SCENE" == action_name
      request_to_weixin {
        RestClient.post("https://api.weixin.qq.com/cgi-bin/qrcode/create?access_token=#{@@access_token}", qrcode_data.to_json, :content_type => :json)
      }
    end

    def request_to_weixin(&block)
      response_json = MultiJson.load(yield)
      errcode = response_json['errcode']
      return response_json unless errcode
      type = find_error_type(errcode)
      return send("process_#{type}_errors", &block) if type
      response_json
    end

    def find_error_type(errcode)
      ['access_token', 'openid'].find do |item|
        self.class.const_get("#{item}_errcodes".upcase).include?(errcode)
      end
    end

    def process_access_token_errors(&block)
      _fetch_access_token
      request_to_weixin(&block) if @@access_token
    end

    def process_openid_errors
      nil
    end

  end
end

