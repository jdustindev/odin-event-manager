require 'csv'
puts 'Event manager initialized!'

contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
)

contents.each do |row|
    name = row[:first_name]
    zipcode = row[:zipcode]

    # if the zip code is exactly 5 digits, assume that it is ok
    # if the zip code is more than 5 digits, truncate it to the first 5 digits
    # if the zip code is less than 5 digits, add zeros to the front until it becomes 5 digits

    puts "#{name} #{zipcode}"
end