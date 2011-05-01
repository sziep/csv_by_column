# encoding: US-ASCII
# = csv_by_colum.rb -- iterate CSV data by colum easily
#
#  Created by Stephan Ziep on 2011-04-28.
#  Copyright 2011 Stephan Ziep. You can redistribute or modify this code
#  under the terms of Ruby's license.
#
# See CSV for documentation.
#
# == Description
# This small addition to Rubys default CSV class, enhances it in a way
# that lets you iterate over columns in a nice way syntacticly
# E.g: given a csv dataset like:
#
# Name,Nickname,Email,Message,ID
# Stephan,nick1,stephan@mail.de,"A first message",3
# Nico,nick2,nico@mail.de,"A second message",6
# Richard,nick3,richard@mail.de,"A third message",67
# Marc,nick4,marc@mail.de,"A fourth message",1234
#
# You can directly refer to the header (downcased) in the foreach method
# like this:
#
# OPTIONS = { converters:         :all,
#             headers:            true,
#             header_converters:  :downcase}
# 
# CSV.foreach_message("data.csv", OPTIONS).each do |msg|
#   p msg
# end
#
# CSV.foreach_message_and_nickname("data.csv", OPTIONS).each do |msg|
#   p msg
# end
#
# or you use the foreach_column method directly: 
#
# CSV.foreach_column("data.csv", OPTIONS, "email") do |mail|
#  p mail
# end

require 'csv'
require 'pp'

class CSV
  
  FUNCTION_DEF = /^foreach_(\w+)/
   
  # iterates over each line and yields the fields that belong to colName Header
  # yields a hash for multiple columns
  def self.foreach_column(data, options = Hash.new, colName)
    cols = colName.split('_and_')
    headers = []
    inited = false
    		
    foreach(data, options) do |row|
    	
    	unless inited
    		inited = true
    		
    		cnt=0
    		row.headers.each do |hdr|
    			cols.each do |col|
    				if (col == hdr)
    					headers << {:idx => cnt, :name => hdr}
    				end
    			end
    			cnt += 1
    		end
    	end
    	
    	if (headers.length > 1)
				thing = Hash.new
    		headers.each do |header|
    			thing[header[:name]] = row[header[:idx]]
    		end
    		yield(thing)
    	elsif
    		yield(row[headers[0][:idx]])
    	end
    end
  end
  
  # provide some syntax sugar
  def self.method_missing(name, *args)
    if (FUNCTION_DEF =~ name.to_s)
    
    		#puts "define method: '#{name}'"
        str = %{
          def self.#{name}(data, options)
            list = []
            foreach_column(data, options, "#{$1}") do |thing|
              list << thing
            end
            list
          end
        }
        #puts str
        class_eval(str)
        
        send name, args[0], args[1]
    elsif
   		super
    end
  end
end