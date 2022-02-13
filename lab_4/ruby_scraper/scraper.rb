require 'watir'
require 'webdrivers'
require 'nokogiri'
require 'csv'
require 'byebug'

#Create url to scrape using provided command line arguments
url = 'https://allegro.pl/kategoria/'

isCategory = true
isFirstKeyword = true

ARGV.each do |argument|

    if isCategory
        url = url + argument
        isCategory = false
    else
        if isFirstKeyword
            url = url + '?string=' + argument
            isFirstKeyword = false
        else
            url = url + '%20' + argument
        end
    end
end

#Visit requested category page to obtain data to scrape
browser = Watir::Browser.new
browser.goto url
parsedPage = Nokogiri::HTML(browser.html)

#Get all article nodes from requested category
articles = parsedPage.xpath("//article[contains(@class, 'mx7m_1 mnyp_co mlkp_ag _6a66d_YapB2')]")

#Create .csv file to store scraped data
CSV.open("articles.csv", "a+") do |csv|
    csv << ["name", "price", "url", "description"]

    #For each article obtain name and price and visit it's page
    articles.each do |article|

        name = article.xpath('.//h2[@class="mgn2_14 m9qz_yp mqu1_16 mp4t_0 m3h2_0 mryx_0 munh_0"]')
        price = article.xpath('.//div[@class="mpof_92 myre_zn"]')
        visitUrl = article.xpath('.//a[@class="mpof_ki myre_zn _6a66d_oLBtv mj9z_5r _6a66d_dAsMB"]/@href').text

        browser.goto visitUrl
        parsedArticlePage = Nokogiri::HTML(browser.html)

        #From article page obtain description and url
        if visitUrl.include? "allegrolokalnie"
            articleUrl = parsedArticlePage.xpath('//link[@rel="canonical"]/@href')

            rawDescription = parsedArticlePage.xpath("//div[contains(@class, 'offer-page__description overflow-wrap')]")
            description = rawDescription.text.gsub(/\n/, ' ').gsub(/\s+/, ' ').strip
        else
            articleUrl = parsedArticlePage.xpath('//link[@rel="canonical"]/@href')

            rawDescription = parsedArticlePage.xpath("//div[contains(@class, '_1h7wt msts_9u _0d3bd_1NgnH')]")
            description = rawDescription.text.gsub(/\n/, ' ').gsub(/\s+/, ' ').strip
        end

        csv << [name.text, price.text, articleUrl, description]
    end
end

browser.close