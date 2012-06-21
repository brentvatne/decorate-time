# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'coffeescript', :input => 'coffeescripts', :output => 'javascripts' do
  watch(%r{^coffeescripts/(.+\.coffee)$})
end

guard 'coffeescript', :input => 'spec/coffeescripts', :output => 'spec/javascripts' do
  watch(%r{^spec/coffeescripts/(.+\.coffee)$})
end
