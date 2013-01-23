module IndexHelper
  def get_usernames
    url = "http://api.thriftdb.com/api.hnsearch.com/items/_search?sortby=create_ts%20desc&limit=100"
    doc = open(url).read
    j = JSON.parse(doc)
    usernames = []
    j['results'].each do |item|
      usernames.push item['item']['username']
    end
    usernames
  end
end
