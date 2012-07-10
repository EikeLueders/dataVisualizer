require 'resque/tasks'

task 'resque:setup' => :environment do
    # ENV['VERBOSE'] = '1'
    ENV['QUEUE'] = '*'
end
