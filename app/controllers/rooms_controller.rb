class RoomsController < ApplicationController
# layout 'timeline'

def index
  check_locked_room_exist
  respond_to do |format|
    format.html{}
    format.json {
      @room_list = nil
      @user_latitude = params[:latitude]
      @user_longitude = params[:longitude]
      calculate_range_for_search
      @room_list = Timeline.
      where(latitude: @start_latitude..@end_latitude).
      where(longitude: @start_longitude..@end_longitude)
    }
  end
end

def timeline
  respond_to do |format|
    format.html{
      @room_id = params[:id]
      @room = Timeline.find_by(id: @room_id)
      if @room == nil
        @room = Timeline.new(id: "0", name: "ラウンジ")
        @room.save
      end
      @user_latitude = @room.latitude
      @user_longitude = @room.longitude
      calculate_range_for_search
      @posts = Post.order(created_at: :desc).where('room = ?', params[:id])
      convert_post_id_for_reply
    }
    format.json {
      @new_posts = nil
      @new_posts = Post.
      where('id > ?', params[:last_id]).
      where('room = ?', params[:id]).order(id: :asc)
    }
  end
end

def lock_room
  respond_to do|format|
    format.json {
        Rails.cache.write("lockRoom", params[:lockRoom], expires_in: 1.hours)
        @locked_room = params[:lockRoom]
    }
  end
end

def create
  timeline = Timeline.new(name:params[:room_name],
   longitude:params[:longitude], latitude:params[:latitude])
  timeline.save
  redirect_to("/rooms")
end

def calculate_range_for_search
  if @room_id == "0" || @room_id == "-1"
    @start_latitude = -1000
    @end_latitude = 1000
    @start_longitude = -1000
    @end_longitude = 1000
  else
    @start_latitude = @user_latitude.to_f - 0.00138889
    @end_latitude = @user_latitude.to_f + 0.00138889
    @start_longitude = @user_longitude.to_f - 0.00138889
    @end_longitude = @user_longitude.to_f + 0.00138889
  end
end

def check_locked_room_exist
  if Rails.cache.read('lock_room').present?
    @locked_room_num = Rails.cache.read('lock_room')
    @locked_room_content = Timeline.find_by(id: @locked_room_num)
    @locked_room_name =  @locked_room.name
  else
    @locked_room_content = nil
    @locked_room_name = 0
    @locked_room_num = 0
  end
end


private
#DBのユニークなIDとチャットルーム内での投稿ナンバーをハッシュで紐付けしている
def convert_post_id_for_reply
  @postId = {}
  @postNum = @posts.count
  @posts.each do |post|
    @postId[post.id] = @postNum
    @postNum = @postNum - 1
  end
end

end