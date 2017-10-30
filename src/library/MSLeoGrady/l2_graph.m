function [pt,e,w] = l2_graph(X,Y,n);

[edgeX, edgeY] = meshgrid(-n:n,-n:n);

edges = [edgeX(:),edgeY(:)];
edges = edges(find(sum(edges'.^2)),:);
edges = edges(find(gcd(edges(:,1),edges(:,2))==1),:);
dirs = atan2(edges(:,2),edges(:,1));
[dirs,j] = sort(dirs);
edges = edges(j,:);
weights = 0.5*1./sqrt(sum(edges'.^2)');

classes = cumsum([1;(dirs(2:end)-dirs(1:end-1))~=0]);
indices = cell(max(classes),1);

for i=1:length(edges)
    indices{classes(i)}(end+1) = i;
end

for i=1:length(edges)
    delta = ...
        dirs(indices{mod(classes(i),length(indices))+1}(1))-dirs(i);    
    delta = mod(delta,2*pi);
    delta = mod(min(delta,2*pi-delta),pi);
    delta = min(delta,pi-delta);
    weights(i) = weights(i)*delta;
end

[nodeX, nodeY] = meshgrid(1:X,1:Y);
nodeX = nodeX(:);
nodeY = nodeY(:);
pt = [nodeX, nodeY];

nodes = 1:X*Y;

[e,w] = insert_edges(X,Y,nodes,edges,weights);