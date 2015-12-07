require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'sinatra'
require 'twilio-ruby'
require 'yaml'

set twilio_account_sid: ENV['TWILIO_ACCOUNT_SID']
set twilio_auth_token: ENV['TWILIO_AUTH_TOKEN']
set twilio_phone_number: ENV['TWILIO_PHONE_NUMBER']

# Render `html.erb` files in /views folder
Tilt.register Tilt::ERBTemplate, 'html.erb'

# Twilio authentication
Twilio.configure do |config|
  config.account_sid = settings.twilio_account_sid
  config.auth_token = settings.twilio_auth_token
end

def insult(target_phone_number, classy)
  begin
    @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    url = @base_url
    url += params[:classy] ? '/twiml/classy' : '/twiml'
    url += '.xml'
    @client = Twilio::REST::Client.new
    @client.calls.create(
      from: settings.twilio_phone_number,
      to: target_phone_number,
      url: url
    )
  rescue Twilio::REST::RequestError => e
    puts e.message
  end
end

# Routes

get '/' do
  erb :index
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
  @phone_number = params[:phone_number]
  erb :index
end
