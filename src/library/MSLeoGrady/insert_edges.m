function [e,w] = insert_edges(X, Y, selected_pts, edges, weights, OPTS);

if nargin<=5
	OPTS.directed = 0;
end

[pts_x, pts_y] = meshgrid(1:X,1:Y); pts = [pts_x(:),pts_y(:)];
num_edges = length(edges);
num_pts = length(selected_pts);

dst_nodes_x = repmat(pts(selected_pts,1),1,num_edges) + ...
		      repmat(edges(:,1)',num_pts,1);
dst_nodes_y = repmat(pts(selected_pts,2),1,num_edges) + ...
		      repmat(edges(:,2)',num_pts,1);

invalid_pts = find(dst_nodes_x<1 | dst_nodes_x>X | ...
				   dst_nodes_y<1 | dst_nodes_y>Y);

dst_nodes_x(invalid_pts) = +inf;
	 
src_nodes = repmat(selected_pts, 1, num_edges);
dst_nodes = (dst_nodes_x-1)*Y+dst_nodes_y;
weights = repmat(weights', num_pts, 1);

e = [src_nodes(:), dst_nodes(:)];
w = weights(:);

valid_edges = find(e(:,2)<+inf);

e = e(valid_edges,:);
w = w(valid_edges);

if ~OPTS.directed
	valid_edges = find(e(:,2)>e(:,1));
	e = e(valid_edges,:);
	w = w(valid_edges);
end