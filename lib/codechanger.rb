#coding : utf-8
#code_changer
#SJISをぜったいに許さない！

require 'rbconfig'

#SJISを絶対に許さない✌('ω')
module Unforginve
	class CodeChanger
		def changer(str)
			if str.empty? then
				return Exception.new("Number of charactor is 0.")
			end

			platform = RbConfig::CONFIG["target_os"].downcase
			os = platform =~ /mswin(?!ce)|mingw|cygwin|bccwin/ ? "win" : (platform =~ /linux/ ? "linux" : "other")

			case os
			when "win"
				if str.encode == "sjis"
					return str.encode!("utf-8")
				else
					return str
				end

			when "linux", "other"
				if str.encode == "utf-8"
					return str
				else
					return str.encode("utf-8")
				end
			end
		end# end of method
	end# end of class
end# end of module