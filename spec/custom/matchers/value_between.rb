RSpec::Matchers.define :value_between do |x, y|
  match { |actual| actual.between?(x, y) }
end