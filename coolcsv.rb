require 'csv'
require 'pp'

class CoolCSV

  attr_reader :data
  attr_reader :options
  
  DEF_LIST_GETTER = /^all_(\w+)/
  DEF_BLOCK_GETTER = /^each_(\w+)/
  
  # constructor
  def initialize(data, options = Hash.new)
    @data = data
    @options = options
  end
  
  # iterates over each line and yields the fields that belong to colName Header
  def each_column(colName, &block)
    cnt = 0
    CSV.foreach(@data, @options) do |row|
      row.headers.each do |hdr|
        if colName == hdr
          cnt += 1
          yield(row.fields(colName)) 
        end
      end
    end
    puts "Warning: no such header: '#{colName}'" if cnt == 0
  end
  
  
  
  # provide syntax sugar
  def method_missing(name, *args)
  
    match = DEF_LIST_GETTER.match(name.to_s)
    if match
        #puts "define method: '#{name}'"
        
        str = %{
          def #{name}
            list = []
            each_column("#{match[1]}") do |thing|
              list << thing
            end
            return list.flatten!
          end
        }
        #puts str
        self.class.class_eval(str)
        
        #puts "call it"
        return send name        
    end
    
    # fall back to default behavior
    super
  end
  
end



coolcsv = CoolCSV.new("data.csv", 
                      headers: true, 
                      header_converters: :downcase, 
                      converters: :all, 
                      quote_char: '"')

coolcsv.all_email.each do |mail|
  p mail
end

