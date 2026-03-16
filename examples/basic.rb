require_relative '../lib/yournotify/client'
client = Yournotify::Client.new('YOUR_API_KEY')
puts client.get_profile
