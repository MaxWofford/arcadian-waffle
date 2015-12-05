require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'sinatra'
require 'twilio-ruby'

account_sid = ENV['TWILIO_ACCOUNT_SID']
auth_token = ENV['TWILIO_AUTH_TOKEN']
twilio_phone_number = ENV['TWILIO_PHONE_NUMBER']
twiml_url = ENV['TWIML_URL']

# set up a client to talk to the Twilio REST API
@client = Twilio::REST::Client.new account_sid, auth_token

def insult(target_phone_number)
  @call = @client.call.create(
    from: twilio_phone_number,
    to: target_phone_number,
    url: twiml_url
  )
end

# Routes

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/insult/:number' do
  insult(params[:number])
end
