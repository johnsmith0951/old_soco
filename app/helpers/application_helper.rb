module ApplicationHelper
require "uri"
	def text_url_to_link text
		URI.extract(text, ['http']).uniq.each do |url|
			sub_text = ""
		    sub_text << "<a href=" << url << " target=\"_blank\">" << url << "</a>"
		    text.gsub!(url, sub_text)
		end
		return text
	end
	def page_title
		title = "Soco β"
	    title = "#{@page_title}" + ' - ' + title if @page_title
	    title
	end
	def hbr(target)
	target = html_escape(target)
	if /&gt;&gt;\d*/ =~ target then
		key = $&.gsub!('&gt;&gt;', '')
		key = @postId.key(key.to_i + 1)
	end
	target.gsub(/\r\n|\r|\n/, " <br /> ").gsub(/https?:\/\/[\S]+/){"\<a class='post_link' href\=\"#{$&}\"target\=\"new\">#{$&}\<\/a\>"}.gsub(/&gt;&gt;\d*/){'<a class="anchor_link" href="#' + "#{key}" + '">' + $& +'</a>'}
	end
end

