require 'spec_helper'

describe Kehutong::WeixinApi, type: :request do

  describe '#send_text_service_message_to' do

    it "should send message to wechat and response correct" do
      stub_request(:post, /https:\/\/api\.weixin\.qq\.com\/cgi-bin\/message\/custom\/send\?access_token=.*/).
          to_return(:body => {"errcode"=>0, "errmsg"=>"ok"}.to_json)

      api = Kehutong::WeixinApi.new
      expect(api.send_text_service_message_to('openid', 'content')).to eq({"errcode"=>0, "errmsg"=>"ok"})
    end
  end

end
