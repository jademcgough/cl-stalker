require 'open-uri'
require 'nokogiri'
require 'uri'

desc "craigslist scraper"
task :scrape => :environment do

  doc = Nokogiri::HTML(open(ENV['url']))
  results = doc.css('.row')

  host = "https://#{URI.parse(ENV['url']).host}"

  results.each do |result|
    url = host + result.css('a').first['href']
    post_id = result['data-pid']
    price = result.css('.price').text.gsub(/[^0-9]/,'').to_i
    description = result.css('a')[1].text

    user_agent = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.28 Safari/537.36"
    result_page = Nokogiri::HTML(open(url, 'User-Agent' => user_agent))
    content = result_page.css('#postingbody').text

    unless Listing.find_by post_id: post_id
      Listing.create(post_id: post_id, price: price, description: description, content: content, url: url)
    end
  end

end