#!/usr/bin/env ruby
# encoding: utf-8

require 'csv'

input_path = ARGV[0]
raise "input file doesn't exist" unless File.file?(input_path)
output_path = File.join(File.dirname(input_path), (File.basename(input_path, '.csv') + '-unmangled.csv')) 

input_csv = CSV.open(input_path, 'r:windows-1252', :headers => true, :return_headers => true)
out = CSV.open(output_path, 'wb:windows-1252', :headers => input_csv.shift.headers)
processed_rows = 0

def consolidate_docscope(row)
  row['docsope'] = row['docscope'] + row['scopeoflow'] unless row['scopeoflow'].nil?
  row.delete('scopeoflow')
end

while row = input_csv.shift
  consolidate_docsope(row)

  out << row
  processed_rows += 1
  print "." if processed_rows % 100 == 0
end
