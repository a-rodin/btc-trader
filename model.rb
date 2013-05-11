class Model
    IntStart = 0.0
    IntEnd = 0.1
    ExecRatioDiff = 1000.0# 0.01

    def self.btc_for_ratio(ratio)
        if ratio <= IntStart
            return 0
        elsif ratio >= IntEnd
            return 1
        else
            return (ratio - IntStart) / (IntEnd - IntStart)
        end
    end
end

