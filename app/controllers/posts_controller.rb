class PostsController < ApplicationController
  def index
    @posts = Post.order(created_at: :desc)
    respond_to do |format|
      format.html{}
      format.json {
        @new_posts = nil
        @new_posts = Post.where('id > ?', params[:id])
      }
    end
  end

  def create
    check_content_and_image_are_empty
    check_numbers_of_content
    check_anchor_is_exsited
    check_image_is_existed

    @room = Timeline.find_by(id: params[:roomId])
    calculate_range_for_location_check
    @user_latitude = params[:latitude].to_f
    @user_longitude = params[:longitude].to_f
    if @start_latitude < @user_latitude && @user_latitude < @end_latitude &&
      @start_longitude < @user_longitude && @user_longitude  < @end_longitude ||
      @room_id == "0" || @room_id == Rails.cache.read('lock_room')
      post = Post.new(content:params[:content], room:params[:roomId],
        image:@image_link, similarity: @mostSimId, simvalue: @mostSimvValue,
        latitude: params[:latitude], longitude: params[:longitude])
      post.save
    end
    redirect_to("/rooms/" + params[:roomId])
  end

  def similarity(post)
    posts = Post.where('room = ?', params[:roomId])
    .select("id", "content").map{ |p| p.attributes }
    unless posts.count == 0 || params[:content].length < 2
      if posts.count > 20 then
        counts = posts.count - 20
        posts = posts[counts..posts.count]
      end
      jsonPosts = {}
      for i in posts do
        jsonPosts[i["id"]] = i["content"]
      end
      uri = URI.parse URI.encode("http://iiojun.xyz:5000/api.soco.com/v1/similarity?comment=#{post}")
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
      req.body = jsonPosts.to_json
      res = http.request(req)
      result = JSON.parse(res.body).to_hash
      unless result["comment_id"] == 400 then
        @mostSimvValue = "1"
        @mostSimId = result["comment_id"]
      end
    end
  end

  def imgur
    require 'net/http'
    require 'net/https'
    require 'open-uri'
    require 'json'
    require 'base64'
    def web_client
      http = Net::HTTP.new(API_URI.host, API_URI.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http
    end
    @image64 = @image.gsub(/^.+?,/, "")
    params = {:image =>  @image64,
      :gallery => "gallery",
      :name => "name"
    }
    request = Net::HTTP::Post.new(API_URI.request_uri + ENDPOINTS[:image])
    request.set_form_data(params)
    request.add_field('Authorization', API_PUBLIC_KEY)
    response = web_client.request(request)
    @image_link = JSON.parse(response.body)['data']['link']
  end

  def calculate_range_for_location_check
    if @room_id == "0" || @room_id == "-1"
      @start_latitude = -1000
      @end_latitude = 1000
      @start_longitude = -1000
      @end_longitude = 1000
    else
      @start_latitude = @room.latitude.to_f - 0.00138889
      @end_latitude = @room.latitude.to_f + 0.00138889
      @start_longitude = @room.longitude.to_f - 0.00138889
      @end_longitude = @room.longitude.to_f + 0.00138889
    end
  end

  def check_content_and_image_are_empty
    if params[:content].empty? && params[:image].empty?
      redirect_to("/rooms/" + params[:roomId])
    end
  end

  def check_image_is_existed
    if params[:image].present?
      @image = params[:image]
      imgur()
    end
  end
  def check_numbers_of_content
    if params[:content].length > 300
      redirect_to("/rooms/" + params[:roomId])
    end
  end

  def check_anchor_is_exsited
    unless params[:content].include?('>>')
      similarity(params[:content])
    end
  end

end

API_URI = URI.parse('https://api.imgur.com')
API_PUBLIC_KEY = 'Client-ID ad65ddb032d22d9'
ENDPOINTS = {
  :image => '3/image',
  :upload => '/3/upload'
}