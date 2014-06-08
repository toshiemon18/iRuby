# -*- coding : utf-8 -*-

require 'win32ole'
require 'nkf'
require 'json'
require './lib/tweetlib'

class IRuby

	def initialize
		keys = JSON.parse(File.read("./keys.json"))
		@client = Tweetlib::Client.new(keys.values)
	end

	def nowplaying
		itunes = WIN32OLE.new("iTunes.Application")
		track = itunes.CurrentTrack
		track
	end

	def update(track)
		trackname = NKF.nkf('-m0Z1 -w', track.Name)
		artist = NKF.nkf('-m0Z1 -w', track.Artist)
		playedcount = track.PlayedCount

		response = @client.update("#{trackname} : #{artist} (#{playedcount}回目)\n#nowpalying")
		response
	end

	def checker
		now = nowplaying
		success = update(now)

		begin
			loop do 
				comp = nowplaying
				if comp != now
					success = update(comp)
					now = nowplaying
				end
			end

		rescue
			retry
		end
	end
end

iRuby = IRuby.new
iRuby.checker
