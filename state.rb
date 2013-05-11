require 'json'

class State
    def self.btc_amount
        @@btc_amount
    end

    def self.usd_amount
        @@usd_amount
    end

    def self.btc_max
        @@btc_max
    end

    def self.btc_amount=(btc_amount)
        @@btc_amount = btc_amount
    end

    def self.usd_amount=(usd_amount)
        @@usd_amount = usd_amount
    end

    def self.btc_max=(btc_max)
        @@btc_max = btc_max
    end

    def self.last_buy_ratio
        @@last_buy_ratio
    end

    def self.last_buy_ratio=(ratio)
        @@last_buy_ratio = ratio
        save_state
    end

    def self.last_sell_ratio
        @@last_sell_ratio
    end

    def self.last_sell_ratio=(ratio)
        @@last_sell_ratio = ratio
        save_state
    end

    private 
    ConfigFile = "data/config.txt"

    def self.save_state
        vals = {
            "last_buy_ratio" => @@last_buy_ratio,
            "last_sell_ratio" => @@last_sell_ratio
        }
        out = File.open ConfigFile, "w"
        out.write vals.to_json
        out.close
    end

    begin
        vals = JSON.parse(IO.read ConfigFile)
    rescue
        vals = JSON.parse("{}")
    end
    @@last_buy_ratio = vals["last_buy_ratio"]
    @@last_sell_ratio = vals["last_sell_ratio"]

    @@btc_amount ||= 0.0
    @@usd_amount ||= 0.0
    @@btc_max ||= 0.0
    @@last_buy_ratio ||= 10.0
    @@last_sell_ratio ||= 10.0

    save_state
end

