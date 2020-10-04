function countdownVerbose( T )
tStart = tic;
tLast = 0;
t = 0;
while ( t <= T )
   if ( t >= tLast )
       fprintf('%f...\n',T-floor(t));
       tLast = tLast + 1;
   end
   t = toc(tStart);
end
fprintf('\n');
end