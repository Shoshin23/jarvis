require 'open-uri'
require 'json'
require 'nokogiri'
class APIHelper

	def self.call(query,category,location="chennai")
	 	case category
		when /weather/
			 accu_weather(location)
		when /restaurant/
			 zomato(location,query)
		when /cricket/
			 cricinfo
		when /football/
			 espn
				
	    end 
	end

 	def self.accu_weather(location)
		end_point="http://openweathermap.org/data/2.1/find/name?q=#{location}"
		result=JSON.parse open(end_point).read
		weather_data=result["list"].first
		{:type=>"weather",:main=>weather_data["main"],:wind=>weather_data["wind"],:clouds=>weather_data["clouds"],:gist=>weather_data["weather"],:external_url=>weather_data["url"]}		
	end 

	def self.zomato(location,query)
	     puts "#{location}:#{query}"
	     end_point="http://www.zomato.com/#{location.downcase}/restaurants/#{query}"
	     html_document=Nokogiri::HTML(open(end_point))
	     restaurants=html_document.css('h3.search-result-title a').collect{|search_result| search_result['title']}
	     {:type=>"restaurants",:suggestions=>restaurants}
	end 	

	def self.cricinfo
		end_point="http://www.cricbuzz.com/scores-home"
		html_document=Nokogiri::HTML(open(end_point))
		score=html_document.css('div.cbz_pg_lft_content').first.css('div.schd_data_row').collect do |search_result|
			 search_result.css('div.schd_data').collect{ |news_item| news_item.content }

		end
		{:type=>"cricket_score",:results=>score}
	        	
	end 	

	def self.espn
	   end_point="http://www.premierleague.com/en-gb/matchday/results.html?paramComp_100=true&view=.dateSeason"
	   base_url="http://www.premierleague.com"
	   html_document=Nokogiri::HTML(open(end_point))
	   data_table=html_document.css('table.contentTable').first.css('tr')
	   score=data_table[1..data_table.length].collect do |result|
		   
		home_team=result.css('td.clubs.rHome a').first
		score=result.css('td.clubs.score a').first
		away_team=result.css('td.clubs.rAway a').first
		result={:home=>{:team=>home_team.content,:url=>base_url+home_team['href']},:score=>{:match_score=>score.content,:url=>base_url+score['href']},:away=>{:team=>away_team.content,:url=>base_url+away_team['href']}}
	   end  
	      {:type=>"football_score",:results=>score}
	end 	
end

