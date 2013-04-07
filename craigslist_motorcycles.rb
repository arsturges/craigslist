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

# Put all results above minimum_price into @mcs
minimum_price = 2000
@mcs = []
@motorcycles.each do |motorcycle|
  if motorcycle.price >= minimum_price
    @mcs.push(motorcycle)
  end
end

def convert_ForSale_to_hash(gem_results)
  # gem result is an array of CraigsList::ForSale objects.
  # Convert it to an array of hashes. Instead of obj.title
  # now we have to do obj[:title]. Whatever. I need to hash methds.
  @mcs_hashed = []
  @mcs.each do |mc|
    @mcs_hashed.push(mc.to_hash)
  end
  @mcs = @mcs_hashed
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
    "Sportster" => "Harley-Davidson",
    "Dyna" => "Harley-Davidson",
    "gsxr" => 'Suzuki',
    "ninja" => "Kawasaki",
    "Maurader" => "Suzuki",
    "Tiger" => "Triumph",
    "Sabre" => "Honda",
    "CBR" => "Honda",
    "CR" => "Honda",
    "zx6r" => "Kawasaki",
    "Shadow" => "Honda"}
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

def get_list_of_years()
  text_years = []
  (00..12).each {|n| text_years.push("%02d" % n)}
  (80..99).each {|n| text_years.push(n.to_s)}
  years = (1980..2012).to_a.push(text_years).flatten
end

def get_year(title,text, years)
  result = nil
  years.each do |year|
    if title.include?(year.to_s)
      result = year.to_i
      break
    end
  end
  if result.nil?
    years.each do |year|
      if text.include?(year.to_s)
        result = year.to_i
      end
    end
  end
  # make it 4 digits:
  if (0..13).member?(result)
    result = 2000 + result
  end
    if (80..99).member?(result)
      result = 1900 + result
  end
  return result
end

years = get_list_of_years()
@mcs = convert_ForSale_to_hash(@mcs)
@mcs.each do |mc|
  puts mc[:title]
  mc[:brand] = get_brand(mc[:title])
  text = get_body_text(mc[:url])
  mc[:year] = get_year(mc[:title], text, years)
  mc[:text] = text
end
