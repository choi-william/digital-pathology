function [filtered_dpids] = remove_edge_images(dpids)
    filtered_dpids = [];
    for i=1:size(dpids,1)
        dpid = dpids(i);
        im = rgb2gray(DPImage(dpid).image);
        whites = im>230;
        if sum(whites(:)) > 10000
            continue;
        end
        filtered_dpids = [filtered_dpids; dpid]; 
    end
end

