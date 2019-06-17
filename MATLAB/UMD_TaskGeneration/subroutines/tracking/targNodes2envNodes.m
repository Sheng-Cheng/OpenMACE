function envNodes = targNodes2envNodes( Mc , Mp, targNodes )
    envNodes = [];
    for i = 1:1:length(targNodes)
        envNodes = [envNodes find( Mc(:,targNodes(i)) == 1 )];
        envNodes = [envNodes find( Mp(:,targNodes(i)) == 1 )];        
    end
    envNodes = unique(envNodes);
end