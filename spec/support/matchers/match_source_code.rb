RSpec::Matchers.define :match_source_code do |expected|
  match do |actual|
    canonize(actual).should == canonize(expected)
  end

  failure_message_for_should do |actual|
    "Expected\n#{canonize(actual)}\n to match\n#{canonize(expected)}"
  end

  def canonize(code)
    code.squeeze("\s").gsub("\n", '').strip
  end
end
