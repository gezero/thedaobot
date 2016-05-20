require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

require 'Redd'
require 'yaml'
require 'rest-client'

secret = YAML.load_file(ARGV[0])

r=nil

def connect secret
	# Authorization
	r = Redd.it(:script, secret['id'],secret['secret'],secret['username'],secret['password'], user_agent: "thedaobot v0.0.1")
	r.authorize!
end 

def checkDaoAccount secret, account
	puts account
	response = RestClient.get("https://api.etherscan.io/api?module=account&action=tokenbalance&tokenname=THEDAO&address=#{account}&apikey=#{secret['token']}")
	puts response.code
	puts response.to_str
end


checkDaoAccount secret, "0x33d9b12b3b05927a1a00d5896017c5ff4967fca9"