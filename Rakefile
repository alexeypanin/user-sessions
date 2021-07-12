require File.join(__dir__, 'data_parser')
require File.join(__dir__, 'report_builder')

require 'benchmark'

desc "data import from file and report generation"

task :import_data_and_calc_stats do
  time = Benchmark.measure {
    parsed_objects = DataParser.new(file_name: './files/data.txt').parse

    puts "\nCalculations started.."

    ReportBuilder.new(objects: parsed_objects).call

    puts "Done. Check result.json"
  }

  puts "Execution time: #{time.real}"
end