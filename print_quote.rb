require_relative 'quote'

def print_quote
  file_path = ARGV[0]
  json = IO.read(file_path)
  cost_params = CostParams.new(0.1, 0.75, 0.5, 0.07)
  cost = Quote.new(json).cost(cost_params)
  puts "#{cost} dollars"
end

print_quote
