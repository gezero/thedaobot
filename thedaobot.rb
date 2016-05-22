require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

require 'Redd'
require 'yaml'
require 'rest-client'

secret = YAML.load_file(ARGV[0])

r=nil

class RedditApi
    def initialize secret
        @r = Redd.it(:script, secret['id'],secret['secret'],secret['username'],secret['password'], user_agent: "thedaobot v0.0.1")
    end

    def authorize!
        @r.authorize!
    end

    def get_new_messages
        @r.my_messages
    end

end

class DAOApi
    def initialize secret
        @api_key = secret['token']
    end

    def account_details account
        YAML.load RestClient.get("https://api.etherscan.io/api?module=account&action=tokenbalance&tokenname=THEDAO&address=#{account}&apikey=#{@api_key}")
    end

    def account_tokens account
        account_details(account)["result"]
    end
end



r = RedditApi.new secret
r.authorize!


messages = r.get_new_messages

messages.each do |m|
    puts m.body
end

d = DAOApi.new secret
account = "0x33d9b12b3b05927a1a00d5896017c5ff4967fca9"
puts d.account_details(account)['result']

