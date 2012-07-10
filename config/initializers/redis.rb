# reestablish DB connection for the forked process within each job
Resque.after_fork do
  ActiveRecord::Base.establish_connection
  resque_config = YAML.load_file(Rails.root.join("config", "resque.yml"))
  Resque.redis = resque_config[Rails.env]
end

# load resque config
resque_config = YAML.load_file(Rails.root.join("config", "resque.yml"))
Resque.redis = resque_config[Rails.env]

Dir[Rails.root.join("app", "jobs", "*.rb")].each { |file| require file }