require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

require 'Redd'
require 'yaml'
require 'rest-client'
require 'ecdsa'
require 'digest'
require 'digest/sha3'

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


def step secret
    r = RedditApi.new secret
    r.authorize!

    messages = r.get_new_messages

    messages.each do |m|
        puts m.body
    end

    d = DAOApi.new secret
    account = "0x33d9b12b3b05927a1a00d5896017c5ff4967fca9"
    puts d.account_details(account)['result']
end


def extract_account_from_signature signature
    r = signature.slice(0, 66)
    s = '0x' + signature.slice(66, 64)
    v = '0x' + signature.slice(130, 2)
    v = v.to_i(16)
    v += 27 if v<27
    puts "r=#{r} s=#{s} v=#{v}"

    message_hash="d030d9a04df643f62a1502b017f51c41a659268091abbd20e2de97b935724d7c"

    group = ECDSA::Group::Secp256k1

    sign = ECDSA::Signature.new r.to_i(16),s.to_i(16)
    ECDSA::recover_public_key(group,message_hash, sign) do |k|
        if k!= nil
            pub = k.x.to_s(16)+k.y.to_s(16)
            puts pub
            puts Digest::SHA3.new(256).hexdigest(pub)
        end
    end


end


extract_account_from_signature "0xf4dffb108315560563e30657c1a5d7942f54bf321593797f08f84ff0601643e2683eb468ddd5f5d9c5bea00a9661beb6e042d335706763957f40f81d790e7aa301"