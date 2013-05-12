function data = load_data 
    persistent src_data;
    if isempty(src_data)
        src_data = importdata('pricelog.txt', ' ');
    end
    data = src_data;
end
