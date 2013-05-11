class Logger 
    def initialize filename
        @log_file = File.new filename, "a"
        @log_mutex = Mutex.new
    end

    def puts message
        @log_mutex.synchronize do
            @log_file.puts Time.new.strftime("[%d.%m.%Y %H:%M:%S] ") + message.to_s
            @log_file.flush
        end
    end
end

class Log
    @@logger = Logger.new "data/log.txt"

    def self.puts message
        @@logger.puts message
    end
end

class TradeLog
    @@logger = Logger.new "data/tradelog.txt"

    def self.puts message
        @@logger.puts message
    end
end

class FundsLog
    @@logger = File.new "data/fundslog.txt", "a"

    def self.puts message
        @@logger.puts message
        @@logger.flush
    end
end

class PriceLog
    @@logger = File.new "data/pricelog.txt", "a"
    def self.puts message
        @@logger.puts message
        @@logger.flush
    end
end

