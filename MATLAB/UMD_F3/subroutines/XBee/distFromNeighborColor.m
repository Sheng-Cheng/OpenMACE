function color = distFromNeighborColor(position,N,k,radius)
    idealAngle = 360/N;
    idealDistance = 2*abs(radius)*sind(idealAngle/2);
    for i=1:N
        dist2Neighbors(i) = abs(pdist([position(k,1) position(k,2); position(i,1) position(i,2)]));
    end
    dist2Neighbors(k) = [];
    closestNeighbor = min(dist2Neighbors);
    
    if closestNeighbor >= idealDistance
        R = 0;
        G = 255;
        B = 0;
    else
        R = 255*(1 - (closestNeighbor/idealDistance));
        G = 255*(closestNeighbor/idealDistance);
        B = 0;
    end
    color = [G R B];
end