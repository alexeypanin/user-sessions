require File.join(__dir__, 'data_parser')
require File.join(__dir__, 'report_builder')

require 'benchmark'
require 'benchmark/memory'
require 'get_process_mem'

desc "data import from file and report generation"

task :import_data_and_calc_stats do
  time = Benchmark.measure {

    mem = GetProcessMem.new
    puts "Memory usage before: #{mem.mb} MB."

    DataParser.new(file_name: './files/data.txt').parse

    puts "Done. Check files/result.json"

    mem = GetProcessMem.new
    puts "Memory usage after: #{mem.mb} MB."
  }

  puts "Execution time: #{time}"
end