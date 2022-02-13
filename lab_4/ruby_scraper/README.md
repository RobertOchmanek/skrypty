To run this Allegro scraper:

 - Ruby 2.7.x should be installed
 - from project root directory run 
     - `gem install bundler` 
     - `bundle install`
     - `ruby scraper.rb <category> <keword 1> <keword 2> ...`
 - for example scraper invoked using `ruby scraper.rb telefony-i-akcesoria apple iphone` will scrape first page of `Telefony i akcesoria` category with keywords `apple` and `iphone`
 - `articles.csv` file in this repo contains example data scraped using above invocation
