require_relative 'mtgoxobserver.rb'
require_relative 'btceobserver.rb'
require 'thread'

class Observer
    @@ticker_btce = nil
    @@ticker_mtgox = nil

    def self.start
        ticker_queue = Queue.new
        btce_t = Thread.new do
            BtcEObserver.start do |ticker|
                ticker_queue.enq ticker
            end
        end

        mtgox_t = Thread.new do
            MtGoxObserver.start do |ticker| 
                ticker_queue.enq ticker
            end
        end

        while ticker = ticker_queue.deq do
            case ticker.exchange
            when Ticker::MtGox
                @@ticker_mtgox = ticker
            when Ticker::BtcE
                @@ticker_btce = ticker
            end

            current_time = Time.new
            if @@ticker_mtgox and @@ticker_btce then
                if (current_time - @@ticker_mtgox.time) < Consts::TimeInterval and (current_time - @@ticker_btce.time) < Consts::TimeInterval
                    yield @@ticker_mtgox, @@ticker_btce
                end
            end
        end
    end
end

