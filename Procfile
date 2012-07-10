web: bundle exec thin start -p $PORT
worker: bundle exec rake resque:work
redis: redis-server /usr/local/etc/redis.conf