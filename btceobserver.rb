require 'net/http'
require 'json'
require 'uri'
require_relative 'ticker'

class BtcEObserver
    def self.start
        while true do
            begin 
                data = JSON.parse(get("https://btc-e.com/api/2/btc_usd/ticker"))
                ticker = Ticker.new Ticker::BtcE
                ticker.buy = data["ticker"]["buy"]
                ticker.sell = data["ticker"]["sell"]
                ticker.last = data["ticker"]["last"]

                yield ticker
            rescue
                retry
            end
            sleep 2
        end
    end

    private 
    def self.get(url)
        uri = URI.parse url
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        response.body
    end
end

