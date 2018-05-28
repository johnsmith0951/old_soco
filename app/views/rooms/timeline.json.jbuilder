if @new_posts.present?
  json.array! @new_posts
end
if @hoge.present?
  json.array! @hoge
end