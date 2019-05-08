#
# COPYRIGHT
#

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Open an irb session preloaded with this library'
task :console do
  sh 'irb -I lib -r bundler/setup'
end

task default: [:spec]
