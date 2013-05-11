class Ticker
    BtcE = :btce
    MtGox = :mtgox

    attr_accessor :buy, :sell, :last, :time, :exchange

    def initialize exchange = Ticker::MtGox
        @time = Time.new
        @exchange = exchange
    end

    def to_s
        "%s %s: buy = %f, sell = %f, last = %f" % [
            @exchange ==  MtGox ? "MtGox" : "BTC-e",
            @time.to_s, @buy, @sell, @last]
    end
end

