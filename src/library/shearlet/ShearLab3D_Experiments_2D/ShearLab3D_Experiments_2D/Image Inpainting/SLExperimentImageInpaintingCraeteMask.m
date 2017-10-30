mask_rand = 255*(rand(512) > 0.8);

imwrite(mask_rand,'mask_rand.png','png');


stepsize = 20;

squaresize = 5;

mask_squares = 255*ones(512,512);

idx_curr = [stepsize,stepsize];

while idx_curr(2) + stepsize < 512
    mask_squares((idx_curr(1)-squaresize):1:(idx_curr(1)+5),(idx_curr(2)-squaresize):1:(idx_curr(2)+5)) = 0;
    if idx_curr(1) + stepsize < 512
        idx_curr(1) = idx_curr(1) + stepsize;
    else
        idx_curr(1) = stepsize;
        idx_curr(2) = idx_curr(2) + stepsize;
    end
end

imwrite(mask_squares,'mask_squares.png','png');