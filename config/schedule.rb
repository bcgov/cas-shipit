# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "/dev/null"

every 1.minute do
  rake 'cron:minutely'
end

every 1.hour do
  rake 'cron:hourly'
  # rake 'teams:fetch'
end

# Learn more: http://github.com/javan/whenever
