#!/usr/bin/env ruby

require_relative 'btce'
require_relative 'consts'
require_relative 'observer'
require_relative 'state'
require_relative 'trader'
require 'thread'

Thread.abort_on_exception = true

BtcE.configure do |config|
    config.key = Consts::BtcE::Key
    config.secret = Consts::BtcE::Secret
end

time_prev = Time.at(0)

Observer.start do |ticker_mtgox, ticker_btce |
    time_cur = Time.new
    if time_cur - time_prev > Consts::LogInterval then
        Log.puts "alive, MtGox price is %f, BTC-e price is %f" % [ticker_mtgox.last, ticker_btce.last ]
        time_prev = time_cur
    end

    Trader.process ticker_mtgox, ticker_btce

    PriceLog.puts "%f %f %f %f %f" % [time_cur.to_f, ticker_mtgox.buy, ticker_mtgox.sell, ticker_btce.buy, ticker_btce.sell ]
end

