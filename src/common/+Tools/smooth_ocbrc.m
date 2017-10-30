function [ out ] = smooth_ocbrc( in, s )

    se = strel('disk', s);

    %OPEN BY RECONSTRUCTION%
    Ie = imerode(in, se);
    Iobr = imreconstruct(Ie, in);

    %CLOSE BY RECONSTRUCTION%
    Iobrd = imdilate(Iobr, se);
    Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
    out = imcomplement(Iobrcbr);


end

