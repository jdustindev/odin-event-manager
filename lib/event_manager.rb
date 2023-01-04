require 'csv'
puts 'Event manager initialized!'

def clean_zipcode(zipcode)
    if zipcode.nil?
        '00000'
    elsif zipcode.length < 5
        zipcode.rjust(5, '0')
    elsif zipcode.length > 5
        zipcode.slice[0..4]
    else
        zipcode
    end
end

contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
)

contents.each do |row|
    name = row[:first_name]
    zipcode = row[:zipcode]

    if zipcode.nil?
        zipcode = '00000'
    elsif zipcode.length < 5
        zipcode = zipcode.rjust(5, '0')
    elsif zipcode.length > 5
        zipcode = zipcode.slice[0..4]
    end

    puts "#{name} #{zipcode}"
end