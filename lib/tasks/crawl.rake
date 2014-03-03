task :crawl => :environment do
  puts Member.crawl_and_make_users
end