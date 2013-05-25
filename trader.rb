require_relative 'state'
require_relative 'btce'
require_relative 'model'
require_relative 'ticker'
require_relative 'consts'
require_relative 'log'

class Trader
    def self.process mtgox_ticker, btce_ticker
        begin
            @@ticker = btce_ticker
            if @@first_time
                update_funds
                @@first_time = false
                return
            end
            State.btc_max = btc_max

            check_order

            ratio = Math.log(mtgox_ticker.sell) - Math.log(btce_ticker.buy)
            expected_btc = Model.btc_for_ratio(ratio) * State.btc_max
            diff = expected_btc - State.btc_amount

            if ! diff.to_f.nan? && diff > 0.01 && (ratio - State.last_sell_ratio).abs >= Model::ExecRatioDiff
                State.last_buy_ratio = ratio
                trade(expected_btc)
            else
                ratio = Math.log(mtgox_ticker.buy) - Math.log(btce_ticker.sell)
                expected_btc = Model.btc_for_ratio(ratio) * State.btc_max
                diff = expected_btc - State.btc_amount
                if ! diff.to_f.nan? && diff < -0.01 && (ratio - State.last_buy_ratio).abs >= Model::ExecRatioDiff
                    State.last_sell_ratio = ratio
                    trade(expected_btc)
                end
            end
        rescue
        end
    end

    private
    @@order = nil
    @@expected_btc = nil
    @@first_time = true

    def self.btc_max
        State.btc_amount + State.usd_amount / (@@ticker.buy * 1.002)
    end

    def self.update_funds
        funds = BtcE.get_funds
        FundsLog.puts("%f %f %f %f" % [Time.new.to_f, funds.usd, funds.btc, funds.usd + funds.btc * @@ticker.sell])
        State.btc_amount = funds.btc
        State.usd_amount = funds.usd - 1.0
        State.btc_amount = funds.btc - btc_max * 0.01
        State.btc_max = btc_max
    end

    def self.trade(expected_btc)
        if expected_btc > State.btc_amount
            @@order = BtcE.buy!((expected_btc - State.btc_amount).abs, @@ticker.buy)
            if @@order.nil? 
                update_funds
            else
                @@expected_btc = expected_btc
            end
        elsif expected_btc < State.btc_amount
            @@order = BtcE.sell!((expected_btc - State.btc_amount).abs, @@ticker.sell)
            if @@order.nil?
                update_funds
            else
                @@expected_btc = expected_btc
            end
        end
    end

    def self.check_order
        if @@order
            orders = BtcE.orders
            orders = orders[:buys] + orders[:sells]
            if orders.find { |order| order.id == @@order }
                BtcE.cancel @@order
            end

            update_funds
            @@order = nil
        end
    end
end

