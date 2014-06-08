#coding : utf-8

require 'rubygems'
require 'net/https'
require 'openssl'
require 'oauth'
require 'json'

module Tweetlib
	class Client
		def initialize(keys)
			keys.each do |key|
				exit if key == nil || key == ""
			end

			if keys.size != 4 then
				puts "The number of elements in the argument is different."
				puts "Number of elements are 4."
				exit
			end

			consumer_key = keys[0]
			consumer_secret = keys[1]
			oauth_token = keys[2]
			oauth_token_secret = keys[3]

			@consumer = OAuth::Consumer.new(
				consumer_key,
				consumer_secret,
				{:site => "https://api.twitter.com/"}
			)

			@access_token = OAuth::AccessToken.new(
				@consumer,
				oauth_token,
				oauth_token_secret
		  	)
		end
		
		#update tweet
		def update(body, id="")
			if id.empty? then
				@access_token.post(
					"/1.1/statuses/update.json",
					{:status => body.to_s}
				)

			else
				@access_token.post(
					"/1.1/statuses/update.json",
					{:status => body.to_s,
					:in_reply_to_status_id => id.to_s }
				)
			end
		end

		#delete tweet
		def delete_tweet(id)
			@access_token.post("/1.1/status/destroy/#{id}.json")
		end

		#post favorite
		def favorite(id)
			@access_token.post(
					"/1.1/favorites/create.json",
					{:id => id}
				)
		end

		#post unfavorite
		def unfavorite(id)
			@access_token.post(
					"/1.1/favorites/destroy.json",
					{:id => id}
				)
		end

		#post retweet
		def retweet(id)
			@access_token.post("/1.1/status/retweet/#{id}.json")
		end

		#track streaming
		def track_stream(track_word, &block)
			uri = URI.parse("https://stream.twitter.com/1.1/statuses/filter.json")
			param = { "track" => track_word }

			connection_streaming(uri, param) do |status|
				yield status
			end
		end

		#userstream
		def userstream(&block)
			uri = URI.parse("https://userstream.twitter.com/1.1/user.json")
			
			connection_streaming(uri) do |status|
				yield status
			end
		end

    	#streaming setup
		def connection_streaming(uri, param=nil, &block)
			https = Net::HTTP.new(uri.host, uri.port)
			https.use_ssl = true
			https.verify_mode = OpenSSL::SSL::VERIFY_NONE

			https.start do |https|
				request = Net::HTTP::Post.new(uri.request_uri, 'Accept-Encoding'=>'identity')
				request.set_form_data(param) if param!=nil
			    request.oauth!(https, @consumer, @access_token)
			    buf = ""

			    https.request(request) do |responsed|
			    	responsed.read_body do |chunk|
				        buf << chunk
				        while(line = buf[/.*(\r\n)+/m])
				        begin
				           	buf.sub!(line, "")
				            line.strip!
				            status = JSON.parse(line)
				        rescue
				             break
				        end
				        yield status
				        end
					end
				end
			end
		end
	end
end