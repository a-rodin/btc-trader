BTC-trader
=======
A trading bot for BTC-e that uses arbitrage between MtGox and BTC-e.

Dependencies
-------
Depends on following gems:

* json
* rest-client

Setup
-------
To set up the script one should set BTC-e API key with full permissions (info, trade, withdraw) and secret for it in consts.rb.


Output
-------
The program writes all output to data directory in following files
* log.txt -- program log, good to see the state of the program
* fundslog.txt -- log of funds state in format "date, usd, btc, total"
* pricelog.txt -- log of prices in format "date, mtgox buy, mtgox sell, btce buy, btce sell"

