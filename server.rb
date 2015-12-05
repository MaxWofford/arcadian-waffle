require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'sinatra'
require 'twilio-ruby'
require 'yaml'


# Twilio setup

Twilio.configure do |config|
  config.account_sid = ENV['TWILIO_ACCOUNT_SID']
  config.auth_token = ENV['TWILIO_AUTH_TOKEN']
end

def insult(target_phone_number, classy)
  @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  url = @base_url
  url += params[:classy] ? '/twiml/classy' : '/twiml'
  url += '.xml'
  @twilio = Twilio::REST::Client.new
  @twilio.calls.create(
    from: ENV['TWILIO_PHONE_NUMBER'],
    to: target_phone_number,
    url: url
  )
end

# Routes

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

post '/twiml/classy.xml' do
  content_type 'text/xml'
  data = YAML.load_file(File.expand_path('data/insults.yml'))
  insult = 'Thou art a '
  for column in data.keys
    insult += " #{data[column][rand(data[column].length)]}"
  end
  Twilio::TwiML::Response.new do |r|
    r.Say insult, voice: 'alice'
  end.text
end

post '/twiml.xml' do
  content_type 'text/xml'
  Twilio::TwiML::Response.new do |r|
    r.Say 'Fuck you'
  end.text
end

post '/' do
  insult(params[:phone_number], params[:classy])
  "Your message to #{params[:phone_number]} has just gone through"
end
