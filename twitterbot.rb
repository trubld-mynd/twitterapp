require 'rubygems'
require 'oauth'
require 'json'
require 'time'
require 'date'

require 'clockwork'
require './config/boot'
require './config/environment'

$t_start = Time.new(2014,9,12,17,30,0,"+10:00")
$t_start_local = $t_start.localtime("+10:00") 
$t_end = Time.new(2014,9,12,20,00,0,"+10:00")
$t_end_local = $t_end.localtime("+10:00") 
$startmessages = ["Hi there...",
    "Welcome to Snakes N Ladders Pub Quest! I am the Pub Questbot. Tweet me your drink count at each pub (max 4) AND A PHOTO", 
       "E.g. if your team has had 3 drinks, take a photo of your team with the drinks, and tweet '@pubquestbot 3 drinks'. Don't forget the pic!",
       "Your move will be determined by your 'dice roll' (your drink count +/-1). E.g. your 3 drinks might move you 2, 3 or 4 spaces on the board.",
       "I will then tell you where to go (If you land on a snake/ladder, I'll send you straight to the bottom/top of it).",
       "I'm only awake every 20 mins. Make sure your tweet to me is the last thing you tweet to anyone before I wake, or I'll give you a roll of 1.",
       "Tweeting more than 4 drinks will land you a 1 point penalty - you'd get 2, 3 or 4 instead of 3, 4 or 5.",
       "The winner will be the first to roll on to Frankie's, OR the team that gets the furtherest in 2.5 hours.",
       "I will start the pubquest at#{$t_start_local.strftime(" %I:%M%p")} and finish at#{$t_end_local.strftime(" %I:%M%p")} local time.",
       "Check out the Snakes N Ladders map, and a copy of these rules, at the website http://www.pubquest.info",
        "LET THE GAMES BEGIN!",
        "The pubquest is over! Come to Frankie's Pizza (Pub 30) to celebrate & party with the winners!"]

$names = ["PoisonSlammers", "TheWindSlayers", "PurpleSquirels", "TheGhostSharks", "MightyCommandos", "DreamLightning", "StokedTurtles"]
$users_list = Hash[$names.map{|user| [user, 0]}]
$users_score = Hash[$names.map{|user| [user, 0]}]
$users_last_time = Hash[$names.map{|user| [user, 0]}]
$users_last_location = Hash[$names.map{|user| [user, 0]}]


$bars = [0,1,2,3,2,6,6,7,11,13,7,11,12,13,14,12,20,17,18,19,20,17,22,27,24,25,24,27,28,28,30]
$barnames = ["Start", "Sweeny's", "Grandma's", "Cuban", "99onYork", "The Rook", "Barbershop", "SG's", "Forbes", "PJs", "CBD", "Le Pub", "Mojo", "Bavarian", "Stitch", "Uncle Ming's", "Steel Br & Grill", "GPO Bar", "Angel Hotel", "Ivy/Felix/Ash St)", "Royal George", "Establish", "Metropolitan", "Mr Wong's", "BridgeSt", "Republic", "Tank", "Palmer & Co", "Ryans", "Grand Hotel", "Frankies"]
$barsnls = ["Start","Go on to ", "Go down to ", "Go on to ", "SNAKE! Go back to ", "LADDER! Go up to ", "Go on to ", "Go on to ", "LADDER! Go up to ", "LADDER! Go up to ", "SNAKE! Go back to ", "Le stop at ", "Party at ", "Go on to ", "Pop into ", "SNAKE! Go back to ", "LADDER! Go up to ", "Go down to ", "Go on to ", "Go to ", "Stop in at ", "SNAKE! Go back to ", "Go on to ", "LADDER! Go up to ", "Tune up at ", "Party on to ", "SNAKE! Go back to ", "So close! Go to ", "Move closer to ", "SNAKE! Go back to ", "You made it! "]


class TwitterDM
    def initialize()
        t = Time::new
        
    ## Verify connection to Twitter API
consumer_key = OAuth::Consumer.new(
"lZLYSIi4dbgIN9yRzTcIeP8Fk",
"3BqN9Qz9iVdYpPKJxXR0hjuaC1KXXPc03lIv02PyZGnXo5CRhR")
access_token = OAuth::Token.new(
"2776153651-zpSsnVPbMUhl34fWK2DdCmAhc2kG41aDPaZxiBP",
"yiXJmkrdheEi4PNGu4IS7WcX1tC9y9hDR06EFqOtIg2Gg")
baseurl = "https://api.twitter.com"

## Run the following script for each message 
## in the $directmessages array above
message_to_tweet = nil
$startmessages.each do |message|

    ## Search past pubquestbot tweets for direct messages
    ## Using the same search method as to establish
    ## users past pub instructions
    firstpath = "/1.1/statuses/user_timeline.json"
    locationquery = URI.encode_www_form(
        "screen_name" => "pubquestbot",
        "count" => 200,
        )
    firstaddress = URI("#{baseurl}#{firstpath}?#{locationquery}")
    request = Net::HTTP::Get.new firstaddress.request_uri

    http             = Net::HTTP.new firstaddress.host, firstaddress.port
    http.use_ssl     = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request.oauth! http, consumer_key, access_token
    http.start
    response = http.request request

    pasttweets = nil
    if response.code == '200' then
      pasttweets = JSON.parse(response.body)
        pasttweets.reverse_each do |pasttweet|
        ## set message_to_tweet if don't find message in pasttweets
        message_to_tweet = case message
        when pasttweet then break
        when $startmessages.last then message if t > $t_end
        else message
        # end of message_to_tweet case
        end 

        # end of bottweets.reverse_each
        end
    # end of response.code == '200'
    end    

## Post direct tweets for pubquest instructions
## Use same script for outgoing Tweets
## As section 3 of the search & tweet.

            thirdpath    = "/1.1/statuses/update.json"
            thirdaddress = URI("#{baseurl}#{thirdpath}")
            request = Net::HTTP::Post.new thirdaddress.request_uri
            request.set_form_data(
              "status" => "#{message_to_tweet}"
            )
            
            # Set up HTTP.
            http             = Net::HTTP.new thirdaddress.host, thirdaddress.port
            http.use_ssl     = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
            
            # Issue the request.
            request.oauth! http, consumer_key, access_token
            http.start
            response = http.request request
            
            # Parse and print the Tweet if the response code was 200
            tweet = nil
            if response.code == '200' then
              tweet = JSON.parse(response.body)
              puts "Successfully sent start tweet #{tweet["text"]}"
            else
              puts "Could not send the start tweet #{message_to_tweet}! " +
              "Code:#{response.code} Body:#{response.body}"
            end
            sleep 5
        # end of directmessages.each do |message|
        end
    # end of def initialize()
    end
# end of class TwitterDM 
end
#####################################
#####################################
#####################################
class TwitterTweet
    def initialize()

t = Time::new
t_20 = t + (20 * 60)
t_local = t.localtime("+10:00")
t_local_string = t_local.strftime(" %I:%M%p")
t_20_local = t_20.localtime("+10:00")
t_20_local_string = t_20_local.strftime(" %I:%M%p")

## Establish Users

## Verify connection to Twitter API
consumer_key = OAuth::Consumer.new(
"lZLYSIi4dbgIN9yRzTcIeP8Fk",
"3BqN9Qz9iVdYpPKJxXR0hjuaC1KXXPc03lIv02PyZGnXo5CRhR")
access_token = OAuth::Token.new(
"2776153651-zpSsnVPbMUhl34fWK2DdCmAhc2kG41aDPaZxiBP",
"yiXJmkrdheEi4PNGu4IS7WcX1tC9y9hDR06EFqOtIg2Gg")
baseurl = "https://api.twitter.com"

## Tweet that pubquest bot is about to wake
## up in 60 seconds
###################################

                    thirdpath    = "/1.1/statuses/update.json"
                    thirdaddress = URI("#{baseurl}#{thirdpath}")
                    request = Net::HTTP::Post.new thirdaddress.request_uri
                    request.set_form_data(
                      "status" => "It's#{t_local_string} - you've got 1 minute to tweet '@pubquestbot n drinks' and a pic!"
                    )
                    
                    # Set up HTTP.
                    http             = Net::HTTP.new thirdaddress.host, thirdaddress.port
                    http.use_ssl     = true
                    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
                    
                    # Issue the request.
                    request.oauth! http, consumer_key, access_token
                    http.start
                    response = http.request request
                    
                    # Parse and print the Tweet if the response code was 200
                    tweet = nil
                    if response.code == '200' then
                      tweet = JSON.parse(response.body)
                      puts "Successfully sent #{tweet["text"]}"
                    else
                      puts "Could not send the warning tweet#{t_local_string}! " +
                      "Code:#{response.code} Body:#{response.body}"
                    end

sleep 60

## Tweet that pubquest bot is awake
## and reading tweets
###################################

                    thirdpath    = "/1.1/statuses/update.json"
                    thirdaddress = URI("#{baseurl}#{thirdpath}")
                    request = Net::HTTP::Post.new thirdaddress.request_uri
                    request.set_form_data(
                      "status" => "I'm awake at#{t_local_string} and starting to read tweets"
                    )
                    
                    # Set up HTTP.
                    http             = Net::HTTP.new thirdaddress.host, thirdaddress.port
                    http.use_ssl     = true
                    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
                    
                    # Issue the request.
                    request.oauth! http, consumer_key, access_token
                    http.start
                    response = http.request request
                    
                    # Parse and print the Tweet if the response code was 200
                    tweet = nil
                    if response.code == '200' then
                      tweet = JSON.parse(response.body)
                      puts "Successfully sent #{tweet["text"]}"
                    else
                      puts "Could not send the wake-up tweet#{t_local_string}! " +
                      "Code:#{response.code} Body:#{response.body}"
                    end

## Establish Keywords
keywords = ["pubquestbot", "drinks"]

## Establish Bar Locations

## Get User current position from Pubquestbot's 
## previous instruction tweets 

firstpath = "/1.1/statuses/user_timeline.json"
locationquery = URI.encode_www_form(
    "screen_name" => "pubquestbot",
    "count" => 20,
    )
firstaddress = URI("#{baseurl}#{firstpath}?#{locationquery}")
request = Net::HTTP::Get.new firstaddress.request_uri

http             = Net::HTTP.new firstaddress.host, firstaddress.port
http.use_ssl     = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

request.oauth! http, consumer_key, access_token
http.start
response = http.request request

bottweets = nil
if response.code == '200' then
  bottweets = JSON.parse(response.body)
    bottweets.reverse_each do |bottweet|
    ## puts bottweet["user"]["name"] + " - " + bottweet["text"]
    ## Identify User from bottweet
   to_user = bottweet["in_reply_to_screen_name"]
    to_user_freeze = to_user.freeze
    if to_user != nil && to_user != ""
        ## SPLIT TWEET UP INTO WORDS 
        botwords = bottweet["text"].to_s.split(" ")
        lastpub = botwords.last.to_i
        $users_score[to_user_freeze] = lastpub
    # if to_user != nil
    end
    # end of bottweets.reverse_each
    end
# end of response.code == '200'
end

puts "users_score = " + $users_score.to_s


## Run the search & tweet script for all 
## users in the user_list

$users_list.each do |name, number|
    puts "New loop: " + name
    name_freeze = name.freeze
## Search User Timelines

secondpath = "/1.1/statuses/user_timeline.json"
userquery = URI.encode_www_form(
    "screen_name" => name,
   "count" => 1,
    )
secondaddress = URI("#{baseurl}#{secondpath}?#{userquery}")
request = Net::HTTP::Get.new secondaddress.request_uri

http             = Net::HTTP.new secondaddress.host, secondaddress.port
http.use_ssl     = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

request.oauth! http, consumer_key, access_token
http.start
response = http.request request

tweets = nil
tweet_t = nil
$rollcount = 0
if response.code == '200' then
  tweets = JSON.parse(response.body)
    tweets.each do |tweet|
        if $rollcount == 0
        $tweetout = nil
        botroll = 0
        rollout = Array.new
        $tweetout = Array.new
        # puts "New tweet found - " + tweet["text"]
        ## Get tweet location (if available) and push to 
        ## users_last_location hash
        # tweet_geo = tweet["coordinates"]
        # users_last_location[name_freeze] = tweet_geo if (tweet_geo != "null")
        
        ## Set time of tweet to variable tweet_t
        # time_arr = (tweet["created_at"].to_s.split(" "))
        # time_time = (time_arr[3].to_s.split(":"))
        # time_arr.delete_at(3)
        # time_arr.insert(3, time_time[0].to_i, time_time[1].to_i, time_time[2].to_i)
        # tweet_t = Time.new(time_arr[7].to_i,Date::ABBR_MONTHNAMES.index(time_arr[1]),time_arr[2].to_i,time_arr[3],time_arr[4],time_arr[5]).localtime("+10:00") 

            # puts "Last logged time = " + $users_last_time[name].to_s
            # wait_time = case $users_last_time[name]
            #    when 0 then ($t_start + 60*20)
            #    else ($users_last_time[name] + (60 * 20))
                # end of time_to_go case
            #    end
            # wait_time_local = wait_time.localtime("+10:00") 
            
            # puts "Wait-time = " +wait_time.to_s
            # puts wait_time_local.strftime("Wait-time = %m/%d/%Y %I:%M%p")            
            # time_to_go = wait_time - t
            # t_go = Time.at(time_to_go.to_i.abs).utc.strftime "%H:%M:%S"
            
            if $users_score[name].to_i == 0
                $tweetout << "@#{name}#{t_local_string} Start the quest at #{$barnames[1]} - # 1"
                $rollcount += 1
                #   $users_last_time[name_freeze] = $t_start_local
            #end of if $users_score[name].to_i == 0
        end
            
            ########
            # puts $tweetout[0]
            #########
        ## puts tweet["user"]["screen_name"] + " - " + tweet["text"]
        ## ^ Removed because list of tweets is flooding heroku logs
        # CHECK TWEET FOR KEY WORDS
        if keywords.all?{|keyword| tweet["text"].to_s.downcase.include? keyword}
        # If Key word found in tweet
        puts tweet["created_at"] + " Key words found in " + tweet["user"]["screen_name"] + " - " + tweet["text"]
        
        ## Check if Media is included in tweet
        ## If no pics, tweet "Pics or it didn't happen!"
        pic = (tweet["entities"].has_key?("media"))
        
        ####
        # puts "Pic = " + pic.to_s
        ###
        
        # if tweet_t < ($t_start + 60*20) 
                # $tweetout << "@#{name} That tweet is #{t_go} minutes too early! Tweet to me again later"
                # elsif ($users_last_time[name] != 0 && tweet_t < ($users_last_time[name] + (60 * 20)))
                # $tweetout << "@#{name} Your last tweet was #{t_go} minutes outside the next window. Tweet to me again later"
            #end of if tweet_t < ($t_start + 60*20)
            # end
        ## SPLIT TWEET UP INTO WORDS 
        words = tweet["text"].to_s.split(" ")
        # puts "Words = " + words.to_s
        ## SEARCH FOR INTERGERS & GENERATE
        ## RANDOM +/- 1 ROLLS
        words.each do |word|
          puts "Word test: " + word.to_s if  (word.to_i < 5 && word.to_i != 0 && $rollcount == 0)
            
            if word.to_i < 5 && word.to_i != 0 && $rollcount == 0 && pic
            botroll = - 1 + rand(3)
            roll = [(word.to_i + botroll), 1].max
            botroll_talk = case botroll
                when -1 then " & I take 1! "
                when 1 then " & I add 1! "
                else ". "
            end
            go_to_bar = $bars[[($users_score[name] + roll), 30].min]
            go_to_barname = $barnames[go_to_bar]
            go_to_bartalk = $barsnls[($users_score[name] + roll)]

            $tweetout << "@#{name}#{t_local_string} on #{$users_score[name]} and drank #{word.to_i}#{botroll_talk}You roll #{roll} to ##{($users_score[name] + roll)}: #{go_to_bartalk}#{go_to_barname} # #{go_to_bar}"
            $users_score[name_freeze] = go_to_bar.to_i
            # $users_last_time[name_freeze] = tweet_t
            $rollcount += 1
            
            end
            
            if word.to_i != 0 && $rollcount == 0 && pic
            
            botroll = - 2 + rand(3)
            roll = [(4 + botroll), 1].max
            botroll_talk = case botroll
                when -2 then " & I take 2! "
                when -1 then " & I take 1! "
                when 1 then " & I add 1! "
                else ". "
            end
            go_to_bar = $bars[[($users_score[name] + roll), 30].min]
            go_to_barname = $barnames[go_to_bar]
            go_to_bartalk = $barsnls[($users_score[name] + roll)]
            $tweetout << "@#{name}#{t_local_string} on #{$users_score[name]}, tried #{word.to_i} drinks (cheeky). Max is 4#{botroll_talk}You roll #{roll} to ##{($users_score[name] + roll)}: #{go_to_bartalk}#{go_to_barname} # #{go_to_bar}"
            
            $users_score[name_freeze] = go_to_bar.to_i
            $users_last_time[name_freeze] = tweet_t
            $rollcount += 1
            
            end

            # end of else if word.to_i != 0
            # end
            #end of word.to_i < 5
            #end

        if pic == false && $rollcount == 0
            if word.to_i < 5 && word.to_i != 0
                botroll = - 2 + rand(3)
            roll = [(word.to_i + botroll), 1].max
            botroll_talk = case botroll
                when -2 then "-2 (No pic)!"
                when -1 then " & I take 1! "
                when 1 then " & I add 1! "
                else ". "
            end
            go_to_bar = $bars[[($users_score[name] + roll), 30].min]
            go_to_barname = $barnames[go_to_bar]
            go_to_bartalk = $barsnls[($users_score[name] + roll)]

            $tweetout << "@#{name}#{t_local_string} on #{$users_score[name]} and drank #{word.to_i}#{botroll_talk}You roll #{roll} to ##{($users_score[name] + roll)}: #{go_to_bartalk}#{go_to_barname} # #{go_to_bar}"
            $users_score[name_freeze] = go_to_bar.to_i
            # $users_last_time[name_freeze] = tweet_t
            $rollcount += 1
        
            else
                roll = 1
                go_to_bar = $bars[[($users_score[name] + roll), 30].min]
                go_to_barname = $barnames[go_to_bar]
                go_to_bartalk = $barsnls[($users_score[name] + roll)]

                $tweetout << "@#{name}#{t_local_string} on #{$users_score[name]} but neither pic nor valid drink count! Move #{roll} to ##{($users_score[name] + roll)}: #{go_to_bartalk}#{go_to_barname} # #{go_to_bar}"
            $users_score[name_freeze] = go_to_bar.to_i
            # $users_last_time[name_freeze] = tweet_t
            $rollcount += 1

        end
        # end if pic == false
        end


        # end of words.each
        end
        
             # end of if keywords.all?{|str|...
            end

            # end of if tweet_t < users_last_time[name] && tweet_t < t
            # end
            
            # end of tweets.reverse_each
            end

        if $tweetout[0] == nil 
                botroll = - 1 + rand(2)
                roll = [botroll, 1].max
            go_to_bar = $bars[[($users_score[name] + roll), 30].min]
            go_to_barname = $barnames[go_to_bar]
            go_to_bartalk = $barsnls[($users_score[name] + roll)]
            $tweetout << "@#{name}#{t_local_string} on #{$users_score[name]}, drank a min. 1 drink. You roll #{roll} to ##{($users_score[name] + roll)}: #{go_to_bartalk}#{go_to_barname} # #{go_to_bar}"
            
            $users_score[name_freeze] = go_to_bar.to_i
            # $users_last_time[name_freeze] = tweet_t
            # end of if $tweetout[0] != nil
        end

        # end of if $rollcount == 0
        end
## TWEET BACK THE TWEETOUT


                    thirdpath    = "/1.1/statuses/update.json"
                    thirdaddress = URI("#{baseurl}#{thirdpath}")
                    request = Net::HTTP::Post.new thirdaddress.request_uri
                    request.set_form_data(
                      "status" => "#{$tweetout[0]}",
                    )
                    
                    # Set up HTTP.
                    http             = Net::HTTP.new thirdaddress.host, thirdaddress.port
                    http.use_ssl     = true
                    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
                    
                    # Issue the request.
                    request.oauth! http, consumer_key, access_token
                    http.start
                    response = http.request request
                    
                    # Parse and print the Tweet if the response code was 200
                    tweet = nil
                    if response.code == '200' then
                      tweet = JSON.parse(response.body)
                      puts "Successfully sent #{tweet["text"]}"
                    else
                      puts "Could not send the Tweet #{$tweetout[0]}! " +
                      "Code:#{response.code} Body:#{response.body}"
                    end
                
                # puts "tweetout = " + $tweetout[0].to_s
                puts "Users_score: " + name + " = " + $users_score[name].to_s
                puts "**********************"
                puts " "
                
            
        ## sleep for 3 seconds, so don't get 429 code
           ############################
           sleep 2
           ############################
            

        # end of if response.code == '200'
        end

        #end of users.list.each
        end

## TWEET SIGNOFF TWEET


                    thirdpath    = "/1.1/statuses/update.json"
                    thirdaddress = URI("#{baseurl}#{thirdpath}")
                    request = Net::HTTP::Post.new thirdaddress.request_uri
                    request.set_form_data(
                      "status" => "Have fun! I'm going back to sleep until #{t_20_local_string}...",
                    )
                    
                    # Set up HTTP.
                    http             = Net::HTTP.new thirdaddress.host, thirdaddress.port
                    http.use_ssl     = true
                    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
                    
                    # Issue the request.
                    request.oauth! http, consumer_key, access_token
                    http.start
                    response = http.request request
                    
                    # Parse and print the Tweet if the response code was 200
                    tweet = nil
                    if response.code == '200' then
                      tweet = JSON.parse(response.body)
                      puts "Successfully sent #{tweet["text"]}"
                    else
                      puts "Could not send the Tweet #{$tweetout[0]}! " +
                      "Code:#{response.code} Body:#{response.body}"
                    end

    # end of def initialize()
    end

# end of class TwitterTweet 
end


include Clockwork

every(180.minutes, 'Queueing instruction-tweets') { Delayed::Job.enqueue TwitterDM.new }
every(20.minutes, 'Queueing twitter-tweet') { Delayed::Job.enqueue TwitterTweet.new }
