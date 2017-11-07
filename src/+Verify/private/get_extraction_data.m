function [ data,dpids ] = get_extraction_data(dpids)  
    data=[];
    for i=1:size(dpids,1)
        dpid = dpids(i);
        found_soma = Segment.Soma.extract_soma(DPImage(dpid));
        for j=1:size(found_soma,2) 
            soma = found_soma{j};
            if soma.isFalsePositive == 1
                continue;
            end
            data = [data; dpid soma.centroid(1) soma.centroid(2)];
        end
        fprintf('Finished analyzing %d of %d\n',i,size(dpids,1));
    end
end

