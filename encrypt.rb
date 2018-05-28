  def trip10(tripkey)
      salt = (tripkey + "H.").slice(1, 2)
      salt = salt.gsub(/[^\.-z]/, ".")
      salt = salt.tr(":;<=>?@[\\]^_`", "ABCDEFGabcdef");
      trip = tripkey.crypt(salt).slice(-8, 8);
      return trip
  end

author = 'hoge#29283'
if author.include?('#') then
	author.gsub(/#.*?$/, '#')
	tripword = $&
	tripword.slice!(0)
	p tripword
	trip = trip10(tripword)
	author = author.gsub(/#.+?$/, '#' + trip)
end
p author