require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone_number)
    new_number = phone_number.tr('-.() ' , '')
    if new_number.length == 11 && new_number[0] == 1
        new_number[1..-1]
    elsif new_number.length != 10
        'invalid number'
    else
        new_number
    end
end

def legislators_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        civic_info.representative_info_by_address(
            address: zip,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        ).officials
    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
end

def save_thank_you_letter(id, form_letter)
    Dir.mkdir('output') unless Dir.exist?('output')

    filename = "output/thanks_#{id}.html"

    File.open(filename, 'w') do |file|
        file.puts form_letter
    end
end

puts 'Event manager initialized!'

contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
    id = row[0]
    name = row[:first_name]

    zipcode = clean_zipcode(row[:zipcode])

    phone_number = clean_phone_number(row[:homephone])

    legislators = legislators_by_zipcode(zipcode)

    form_letter = erb_template.result(binding)

    puts "#{row[:first_name]}\t#{phone_number}"

    save_thank_you_letter(id, form_letter)
end

contents.rewind
#registration_hours = contents.reduce(Hash.new(0)) do |hours, row|
#    datetime = Time.parse(row[:regdate])
#    hours[row[0]] = 1
#    hours
#end

def peak_registration_hours(contents)
    hours = contents.reduce(Hash.new(0)) do |hours, row|
        time = Time.parse(row[:regdate].split[1])
        hour = time.hour
        hours[hour] += 1
        hours
    end
    hours_nums = hours.sort_by do |hour, num|
        num
    end

    best_hours = ""
    3.times do |i|
        best_hours += "#{hours_nums[-1-i][0]}:00: #{hours_nums[-1-i][1]}\n"
    end
    return best_hours
end
puts "3 Best registration hours:\n#{peak_registration_hours(contents)}"
