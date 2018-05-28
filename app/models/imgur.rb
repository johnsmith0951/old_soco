
class Imgur
  require 'net/http'
  require 'net/https'
  require 'open-uri'
  require 'json'
  require 'base64'
  require 'json'
  require 'openssl'
  require 'httpclient'
  URL = 'https://api.imgur.com/3/image'
  def initialize(client_id)
    mime_type, data = @image.match(/data:(.*?);(?:.*?),(.*)$/).captures
    extention = mime_type.split('/')
    File.open("./" + "/" + ["tmpura"].join('.'), 'wb') do|f|
      f.write(Base64.decode64(data))
    end
    @client_id = client_id
  end

  def anonymous_upload(file_path)
    auth_header = { 'Authorization' => 'Client-ID ' + @client_id }
    upload(auth_header, file_path)
  end

  private
  def upload(auth_header, file_path)
    http_client = HTTPClient.new
    File.open(file_path) do |file|
      body = { 'image' => file }
      @res = http_client.post(URI.parse(URL), body, auth_header)
    end
    @img_link = JSON.parse(@res.body)['data']['link']
    p @img_link
  end
end
