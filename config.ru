# config.ru (this can be run with `rackup`)

require './server'
run Sinatra::Application

# Enable realtime logging for heroku
$stdout.sync = true
