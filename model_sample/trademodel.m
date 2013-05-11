function trademodel()
    r_min = -0.01; % bottom of R values range
    r_max = 0.11;  % top of R values range
    delta = 0.01;  % minimal R change for trading execution

    data = load_data;
    time = data(:, 1);
    time = time / 3600 / 24 + datenum(1970, 1, 1); % convert unix timestamp to matlab date
    mtgox_buy = data(:, 2) ;
    mtgox_sell = data(:, 3);
    btce_buy = data(:, 4) ;
    btce_sell = data(:, 5); 
  
    btce_btc_amount = 0;
    btce_usd_amount = btce_buy(1) * 1.002;    
    
    function state = total_in_usd(index) 
        state = btce_usd_amount + btce_sell(index) * btce_btc_amount / 1.002;
    end
    
    function state = total_in_btc(index)
        state = btce_btc_amount + (btce_usd_amount - 1) / (btce_buy(index) * 1.002);
    end

    function expected_btc = btc_for_ratio(ratio)
        if ratio <= r_min
            expected_btc = 0;
        elseif ratio >= r_max
            expected_btc = 1;
        else
            expected_btc = (ratio - r_min) / (r_max - r_min);
        end
    end
        
    count = 1;
    trading_times = zeros(1, length(time));
    trading_states = zeros(1, length(time));
    
    trading_times(1) = time(1);
    trading_states(1) = total_in_usd(1);
    
    last_buy_ratio = 0.0;
    last_sell_ratio = 0.0;
    
    for i = 1:length(time)
        ratio = log(mtgox_sell(i)) - log(btce_buy(i));
        expected_btce = btc_for_ratio(ratio) * total_in_btc(i);
        btce_diff = expected_btce - btce_btc_amount;
        
        if btce_diff > 0.01 && abs(last_sell_ratio - ratio) >= delta
            last_buy_ratio = ratio;
            btce_usd_amount = btce_usd_amount - btce_buy(i) * abs(btce_diff) * 1.002;
            btce_btc_amount = expected_btce;
            
            count = count + 1;
            trading_times(count) = time(i);
            trading_states(count) = total_in_usd(i);
        else
            ratio = log(mtgox_buy(i)) - log(btce_sell(i));
            expected_btce = btc_for_ratio(ratio);
            expected_btce = expected_btce * total_in_btc(i);
            btce_diff = expected_btce - btce_btc_amount;
            
            if btce_diff < -0.01 && abs(last_buy_ratio - ratio) >= delta
                last_sell_ratio = ratio;
                btce_usd_amount = btce_usd_amount + btce_sell(i) * abs(btce_diff) / 1.002;
                btce_btc_amount = expected_btce;

                count = count + 1;
                trading_times(count) = time(i);
                trading_states(count) = total_in_usd(i);
            end
        end
    end
    
    count = count + 1;
    trading_times(count) = time(end);
    trading_states(count) = total_in_usd(length(time));
    
    trading_times = trading_times(1:count);
    trading_states = trading_states(1:count);
    
    subplot(2, 1, 1);
    plot(trading_times, 100*(trading_states / trading_states(1) - 1), '.-');
    grid on;
    title 'Total profit, %';
    set(gca, 'XTick', trading_times(1):((trading_times(end) - trading_times(1)) / 5):trading_times(end));
    datetick('x', 'dd.mm', 'keepticks');
    
    subplot(2, 1, 2); 
    plot(time, (btce_buy + btce_sell) / 2);
    grid on;
    title 'BTC-e price, USD';
    set(gca, 'XTick', time(1):((time(end) - time(1)) / 10):time(end));
    datetick('x', 'dd.mm', 'keepticks');
    
    result_profit = trading_states(end) / trading_states(1) - 1;
    fprintf('profit: %f, profit per day: %f\n', result_profit, result_profit / (max(time) - min(time)));    
end