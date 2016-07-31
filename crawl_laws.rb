# city counselors = vereador
require 'harvestman'
require 'json'

class Crawler
  def initialize(name, url)
    @name = name
    @url = url
  end

  def fix_encoding(str)
    str.encode("iso-8859-1").force_encoding("utf-8")
  end

  def url_for_page(page)
    "#{@url}&Start=#{page}"
  end

  def crawl
    projects = self.start_crawling
    File.open("#{@name}-#{DateTime.now.to_time.to_i}.json", "w") do |f|
      f.puts JSON.pretty_generate(projects)
    end
  end

  # TODO: scrape the next url instead of adding 99... we're missing some data at the last page
  def crawl_page(page = 1)
    projects = []
    puts "- crawling URL: #{url_for_page(page)}"
    begin
      Harvestman.crawl url_for_page(page) do
        if !css("h2").empty?
          puts "- END OF CRAWLING"
          return []
        end
        css 'table[cellpadding="2"] tr[valign="top"]' do
          fix_encoding = -> (str) { str.encode("iso-8859-1").force_encoding("utf-8") }
          projects << {
            id: fix_encoding.call(css('a').inner_text),
            url: css('a')[0].attributes['href'].value,
            description: fix_encoding.call(css('font')[1].inner_text),
            date: fix_encoding.call(css('font')[2].inner_text),
            author: fix_encoding.call(css('font')[3].inner_text)
          }
        end
      end
      puts "- SUCCESS: #{projects.count} projects"
      return projects + self.crawl_page(page + 99)
    rescue Exception => msg
      puts "- ERROR: #{msg}"
      return []
    end
  end

  alias start_crawling crawl_page
end

simple_law_crawler = Crawler.new("projeto-lei-simples-2013-2016","http://mail.camara.rj.gov.br/APL/Legislativos/scpro1316.nsf/Internet/LeiInt?OpenForm")

[simple_law_crawler].each do |crawler|
  crawler.crawl
end

# def fix_encoding(str)
#   str.encode("iso-8859-1").force_encoding("utf-8")
# end
#
# def url_for_page(page)
#   "http://mail.camara.rj.gov.br/APL/Legislativos/scpro1316.nsf/Internet/LeiInt?OpenForm&Start=#{page}"
# end


# def scrape(num)
#   projects = []
#   puts "- crawling URL: #{url_for_page(num)}"
#   begin
#     Harvestman.crawl url_for_page(num) do
#       if !css("h2").empty?
#         puts "- END OF CRAWLING"
#         return []
#       end
#       css 'table[cellpadding="2"] tr[valign="top"]' do
#         projects << {
#           id: fix_encoding(css('a').inner_text),
#           url: css('a')[0].attributes['href'].value,
#           description: fix_encoding(css('font')[1].inner_text),
#           date: fix_encoding(css('font')[2].inner_text),
#           author: fix_encoding(css('font')[3].inner_text)
#         }
#       end
#     end
#     puts "- SUCCESS: #{projects.count} projects"
#     return projects + scrape(num + 99)
#   rescue Exception => msg
#     puts "- ERROR: #{msg}"
#     return []
#   end
# end
#
# all_projects = scrape(1)