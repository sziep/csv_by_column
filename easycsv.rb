require './csv_by_column.rb'

OPTIONS = { converters:         :all,
            headers:            true,
            header_converters:  :downcase}


CSV.foreach_message("data.csv", OPTIONS).each do |msg|
  p msg
end

CSV.foreach_message_and_nickname("data.csv", OPTIONS).each do |msg|
  p msg
end

#CSV.foreach_column("data.csv", OPTIONS, "email") do |mail|
#  p mail
#end
