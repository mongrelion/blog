require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.libs    << 'lib'
  t.libs    << 'lib/core_ext'
  t.libs    << 'models'
  t.libs    << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
end

task default: :spec
