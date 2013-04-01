require 'craig'
require 'pp'
require 'nokogiri'
require 'open-uri'

# Scrape SF Bay Area craigslist for beginner motorcycles.
# Capture offer information.
# Identify whether the offer is a repost. 
# Get price, brand, URL from Craigslist gem.
# Then use URL to Nokogiri the engine size and year

@motorcycles = Craig.query(
  :sf_bay_area, 
  :for_sale => :motorcycles)
# If this were Python I would dump it into Pandas and filter it.

# Put all results above minimum_price into @mcs
minimum_price = 2000
@mcs = []
@motorcycles.each do |motorcycle|
  if motorcycle.price >= minimum_price
    @mcs.push(motorcycle)
  end
end

def get_brand(cl_title)
  # take a Craigslist posting title and get the brand/make from it.
  brands = [
    'BMW', 'Honda', 'Suzuki', 'Yamaha', 'Aprilia', 'Harley-Davidson', 
    'Harley', 'Triumph', 'Ducati', 'Vespa', 'Kawasaki', 'Hyosung', 'KTM',
    'Bultaco']
  result = nil
  brands.each do |brand|
    if cl_title.downcase.include?(brand.downcase)
      result = brand
      break
    end
  end
  if result.nil?
    result = get_brand_from_model(cl_title)
  end
  return result
end

def get_brand_from_model(cl_title)
  # Take a Craigslist posting title and get the model from it, 
  # then use that to get the model.
  models = {
    "Heritage" => "Harley-Davidson",
    "gsxr" => 'Suzuki',
    "ninja" => "Kawasaki"}
  result = nil
  models.keys.each do |model|
    if cl_title.downcase.include?(model.downcase)
      result = models[model]
      break
    end
  end
  return result
end

def get_body_text(url)
  doc = Nokogiri::HTML(open(url))
  post_text = doc.css("section#postingbody").text
end

def get_engine_size(text)
end

def get_year(title,text)
  text_years = []
  (00..12).each {|n| text_years.push("%02d" % n)}
  (90..99).each {|n| text_years.push(n.to_s)}
  years = (1990..2012).to_a.push(text_years).flatten
end

@results = []
n = 0
@mcs.each do |mc|
  @results[n] = {}
  #scrape_body(mc.url)
  @results[n]['URL'] = mc.url
  @results[n]['price'] = mc.price
  @results[n]['brand'] = get_brand(mc.title)
  @results[n]['title'] = mc.title
  n +=1
end
