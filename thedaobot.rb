require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

require 'Redd'
require 'yaml'

secret = YAML.load_file(ARGV[0])

puts secret

# Authorization
r = Redd.it(:script, secret['id'],secret['secret'],secret['username'],secret['password'], user_agent: "thedaobot v0.0.1")
r.authorize!

puts r.methods
