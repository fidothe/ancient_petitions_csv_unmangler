#!/usr/bin/env ruby
# encoding: utf-8

require 'csv'
require 'cgi'

input_path = ARGV[0]
raise "input file doesn't exist" unless File.file?(input_path)
output_path = File.join(File.dirname(input_path), (File.basename(input_path, '.csv') + '-unmangled.csv')) 

input_csv = CSV.open(input_path, 'r:windows-1252', :headers => true, :return_headers => true)
input_headers = input_csv.shift.headers
input_headers.delete('scopeoflow') 
input_headers = input_headers + ['date_from', 'date_to', 'url']
out = CSV.open(output_path, 'wb:windows-1252')

def consolidate_docscope(row_hash)
  row_hash['docscope'] = (row_hash['docscope'] + row_hash['scopeoflow']) unless row_hash['scopeoflow'].nil?
end

def extract_date_fields(row_hash)
  # [c YYYY - c YYYY]
  # [c YYYY - c]
  # [c YYYY - c YYYY]
  # [YYYY - YYYY]
  # [YYYY]
  # YYYY
  
  date_field = row_hash['docdate']
  if date_field.nil?
    start_date = end_date = nil
  else
    date_match = date_field.match(/[^0-9]*([0-9]{4})(?:[^0-9]+([0-9]{4}))?/)
    start_date, end_date = date_match.nil? ? [nil, nil] : date_match.captures
  end
  row_hash['date_from'] = start_date
  row_hash['date_to'] = end_date
end

def construct_url(row_hash)
  row_hash['url'] = "http://discovery.nationalarchives.gov.uk/SearchUI/Result.mvc?searchQuery=#{CGI.escape("#{row_hash['letter_code']} #{row_hash['class_no']}/#{row_hash['pref']}/#{row_hash['iref']}")}"
end

def construct_row(headers, row_hash)
  headers.collect { |k| row_hash[k] }
end

@processed_rows = 0
def update_progress
  @processed_rows += 1
  $stdout.print "." if @processed_rows % 100 == 0
end

out << input_headers
while row = input_csv.shift
  row_hash = row.to_hash
  consolidate_docscope(row_hash)
  extract_date_fields(row_hash)
  construct_url(row_hash)

  out << construct_row(input_headers, row_hash)

  update_progress
end
puts ""