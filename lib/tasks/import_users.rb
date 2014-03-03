task :import_users => :environment do

	require 'csv'    

	#TODO: finish code that creates the csv, parse it here properly, test this code

	csv_text = File.read("hn_users.csv")
	csv = CSV.parse(csv_text, :headers => true)
	csv.each do |row|
		# TODO: call appropriate function to get karma for that user

		member = Member.where(:username => username).first
		if not member
			sleep 1.0 # to be nice to the API provider
			Member.make_from_api(username)
			new_members += 1
	end

	puts "# created: {new_members}"
end