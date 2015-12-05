require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'sinatra'
require 'twilio-ruby'

# Twilio setup
Twilio.configure do |config|
  config.account_sid = ENV['TWILIO_ACCOUNT_SID']
  config.auth_token = ENV['TWILIO_AUTH_TOKEN']
end

def insult(target_phone_number)
  @twilio = Twilio::REST::Client.new
  @twilio.calls.create(
    from: ENV['TWILIO_PHONE_NUMBER'],
    to: target_phone_number,
    url: ENV['TWIML_URL']
  )
end

# Routes

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/insult/:number' do
  insult(params[:number])
  "Your message to #{params[:number]} has just gone through"
end
