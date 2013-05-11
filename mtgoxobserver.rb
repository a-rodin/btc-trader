require 'json'
require_relative 'lib/SocketIO'
require_relative 'ticker'
require_relative 'log'

class MtGoxObserver
    class Channel
        Trade = "dbf1dee9-4f2e-4a08-8cb7-748919a71b21"
        Ticker = "d5f06780-30a8-4a48-a2f8-7ed181b4a13f"
        Depth = "24e67e0d-1cad-4cc0-9e7a-f8523ef460fe"
    end

    def self.start
        while true do
            begin
                client = SocketIO.connect("http://socketio.mtgox.com/mtgox", {reconnect: true} ) do
                    channels = {
                        Channel::Trade => true, 
                        Channel::Ticker => true,
                        Channel::Depth => true
                    }

                    before_start do
                        on_json_message do |message|
                            message = JSON.parse message
                            if message.key? "channel_name" and message["channel_name"] == "ticker.BTCUSD" then
                                ticker = Ticker.new Ticker::MtGox
                                ticker.last = message["ticker"]["last"]["value"].to_f
                                ticker.sell = message["ticker"]["buy"]["value"].to_f
                                ticker.buy = message["ticker"]["sell"]["value"].to_f

                                yield ticker
                            elsif message.key? "op" && message["op"] == "subscribe" then
                                channels[message["channel"]] = true
                            elsif message.key? "op" && message["op"] == "unsubscribe" then
                                channels[message["channel"]] = false
                            end
                            if channels[Channel::Trade] then
                                send_json_message({ op: "unsubscribe", channel: Channel::Trade  })
                            end
                            if channels[Channel::Depth] then
                                send_json_message({ op: "unsubscribe", channel: Channel::Depth })
                            end
                        end
                    end
                    after_start do
    #                    send_connect
                        Log.puts 'MtGox: connected ' + send_connect.inspect
                    end
                end
            rescue
                retry
            end
        end
    end

end

