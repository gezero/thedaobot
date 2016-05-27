#Please do not run this application on any machine that has access to your crypto...
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

require 'Redd'
require 'yaml'
require 'rest-client'
require 'ecdsa'
require 'digest'
require 'digest/sha3'

secret = YAML.load_file(ARGV[0])

class RedditApi
    def initialize secret
        @r = Redd.it(:script, secret['id'],secret['secret'],secret['username'],secret['password'], {user_agent: "thedaobot v0.0.1",rate_limit: Redd::RateLimit.new(10)})
    end

    def authorize!
        @r.authorize!
    end

    def get_new_messages
        @r.my_messages('unread')
    end

end

class DAOApi
    def initialize secret
        @api_key = secret['token']
    end

    def account_details account
        link = "https://api.etherscan.io/api?module=account&action=tokenbalance&tokenname=THEDAO&address=#{account}&apikey=#{@api_key}"
        puts link
        YAML.load RestClient.get(link)
    end

    def account_tokens account
        account_details(account)["result"]
    end
end


class DaoBot
    def initialize secret
        @r = RedditApi.new secret
        @d = DAOApi.new secret
    end

    def extract_keys_from_signature signature, message_hash
        r = signature.slice(0, 66)
        s = '0x' + signature.slice(66, 64)
        v = '0x' + signature.slice(130, 2)
        v = v.to_i(16)
        v += 27 if v<27

        group = ECDSA::Group::Secp256k1
        sign = ECDSA::Signature.new r.to_i(16),s.to_i(16)

        #puts "s: #{signature} m_h:#{message_hash}"
        #puts "r: #{r} s:#{s} v:#{v}"

        keys =[]
        ECDSA::recover_public_key(group,[message_hash].pack('H*'), sign) do |k|
            if k!= nil
                puts k
                pub = k.x.to_s(16)+k.y.to_s(16)
                pub_b =[pub].pack('H*')
                keys << (Digest::SHA3.new(256).hexdigest(pub_b))[-40..-1]
            end
        end

        return keys
    rescue 
        return []        
    end

    def authorize!
        @r.authorize!
    end

    def step  
        @r.get_new_messages .each do |m|
            sleep 2

            next if m.read?

            author = m.author
            body = m.body

            message_hash = Digest::SHA3.new(256).hexdigest(author)

            match = /Signature: (0x\p{XDigit}*)/.match(body)

            signature = match[1] if match
            puts "User: #{author} message_hash = #{message_hash} signature=#{signature}"

            if signature
                keys = extract_keys_from_signature signature, message_hash

                total = 0
                keys.each do |k|
                    amount = @d.account_details(k)['result'].to_i
                    puts "key: #{k} amount:#{amount}"
                    total += amount
                end

                puts "total = #{total}"

                if total>0
                    m.reply("The signature from #{author} is valid and related DAO account contains #{total} DAO tokens.\n\n I am a bot. [Report problem](https://www.reddit.com/r/thedaobot/) or [use me](https://www.reddit.com/r/thedaobot/wiki/thedaobot/usage).")
                end

            end
            m.mark_as_read            
        end
    end

    def start_looping
        loop do
            sleep 1
            puts "Going for next step..."
            step
        end
    end

end




bot = DaoBot.new secret

bot.authorize!

bot.start_looping