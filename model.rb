class Model
    IntStart = -0.01
    IntEnd = 0.11
    ExecRatioDiff = 0.01

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

