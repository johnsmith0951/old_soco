post = "ここ参考にしました\r\nhttp://kazukiyunoue-tech.hatenablog.com/entry/2012/12/28/13064"
if post.include?("http")
	post = post.gsub(/http.*/){"\<a href\=\"#{$&}\" target\=\"\_blank\"\>#{$&}\<\/a\>"}
    p post
end