require 'net/http'
require 'uri'
require 'json'
require 'digest/sha2'
require 'scanf'
require_relative 'log'

class BtcE
    class Configuration
        attr_accessor :key, :secret
    end
    @@config = Configuration.new

    class Order
        attr_accessor :id, :date, :amount, :price
    end

    class Funds
        attr_accessor :usd, :btc
    end

    def self.configure
        yield @@config
        err = call_method("getInfo")["error"]
        @@nonce = err.scanf("invalid nonce parameter; %i")[0] if err
        if @@nonce 
            @@nonce += 1
        else
            @@nonce = 2
        end
    end

    def self.get_funds
        data = call_method("getInfo")
        if data["success"] != 1
            throw Exception.new("BTC-e exception")
        end
        funds = Funds.new
        funds.usd = data["return"]["funds"]["usd"]
        funds.btc = data["return"]["funds"]["btc"]
        funds
    end

    def self.orders
        data = call_method("OrderList", { "pair" => "btc_usd" })
        result = { :buys => [], :sells => [] }
        if (data.key? "error") and (data["error"] == "no orders")
            return result
        end
        data["return"].each do |id, info| 
            order = Order.new
            order.id = id
            order.date = Time.at(info["timestamp_created"])
            order.amount = info["amount"]
            order.price = info["rate"]
            case info["type"]
            when "buy"
                result[:buys] << order
            when "sell"
                result[:sells] << order
            end
        end
        result
    end

    def self.sell! amount, price
        Log.puts "selling %f BTC on BTC-e for price $%f..." % [amount, price]
        res = call_method("Trade", {
            "pair" => "btc_usd",
            "type" => "sell",
            "rate" => price,
            "amount" => ("%.8f" % amount)
        })["return"]["order_id"].to_s
        res == "0" ? nil : res
    end


    def self.buy! amount, price
        Log.puts "buying %f BTC on BTC-e for price $%f..." % [amount, price]
        res = call_method("Trade", {
            "pair" => "btc_usd",
            "type" => "buy",
            "rate" => price,
            "amount" => ("%.8f" % amount)
        })["return"]["order_id"].to_s
        res == "0" ? nil : res
    end

    def self.cancel order_id
        Log.puts "canceling last order on BTC-e..."
        call_method("CancelOrder", { "order_id" => order_id })["success"] == 1
    end

    @@nonce = 0

    def self.call_method(method, params = {})
        uri = URI.parse "https://btc-e.com/tapi"
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        data = URI::encode_www_form params.merge( { "method" => method, "nonce" => (@@nonce += 1) } )
        sign = OpenSSL::HMAC.hexdigest("sha512", @@config.secret, data)
        headers = {
            "Key" => @@config.key,
            "Sign" => sign
        }

        response = http.post(uri.request_uri, data, headers)

        JSON.parse response.body
    end

end

