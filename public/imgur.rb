require 'httpclient'

# imgur upload simple module
class Imgur

  URL = 'https://api.imgur.com/3/image'

  def initialize(client_id)
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
      p body
      @res = http_client.post(URI.parse(URL), body, auth_header)
    end

    @img_link = JSON.parse(@res.body)['data']['link']
  end

end
