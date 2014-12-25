# WeixinApi
---
## 目的

将与微信交互的接口封装成gem包，为之后其他项目的开发提供便利

---
## 功能及用法
**注意：目前功能只支持单一公众平台账号开发**

目前，所有方法都是实例方法，使用时应首先new一个Kehutong::WeixinApi对象，将app_id、app_secret以及与微信对接的token以hash形式传入，token默认值为“weixin”。

例如:api_obj = Kehutong::WeixinApi.new(app_id: 'app_id', app_secret: 'app_secret', token: 'weixin123')

### 验证（与微信对接） validate(params)
- 该方法用于系统验证微信的第一次get请求。如果成功，返回值为{text: params[:echostr], status: 200}；如果失败，返回值为{ text: 'Forbidden', status: 403 }。返回值可直接作为response返回给微信服务
  
### 验证消息正确性（验证是否为微信发来的请求） validate?(params)
- 该方法验证请求是否为微信所发请求，验证通过返回true，否则返回false
  
### 通过snsapi_base方式的微信o_auth获取访问用户的微信信息  fetch_user_info_by_base_oauth(code)
- 传入o_auth重定向后携带的code参数获取访问用户的open_id，通过微信提供的获取用户基本信息接口获取访问用户的微信信息。
- 该方法只支持获取已关注公众号的用户信息
  
### 生成临时二维码  generate_temporary_qrcode(scene_id)
- 传入自定义的scene_id，返回生成二维码的ticket、expire_seconds和url，生成二维码的有效时间为30分钟，暂不支持自定义。
- 通过https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=TICKET（将TICKET替换为所生成二维码的ticket）获取二维码图片
  
### 生成永久二维码  generate_forever_qrcode(scene_id)
- 传入自定义的scene_id，返回生成二维码的ticket、expire_seconds和url。
- 通过https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=TICKET（将TICKET替换为所生成二维码的ticket）获取二维码图片
- 永久二维码最多只能有100000个，scene_id的值只能为1--100000
