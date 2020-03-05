figure;    
for k = 1:100
    h1 = plot(dataLogging(k*3-2,2),dataLogging(k*3-2,3),'bo');hold on;
    h2 = plot(dataLogging(k*3-1,2),dataLogging(k*3-1,3),'ro');
    h3 = plot(dataLogging(k*3,2),dataLogging(k*3,3),'ko');
    axis([min(dataLogging(:,2)) max(dataLogging(:,2)) min(dataLogging(:,3)) max(dataLogging(:,3))])
    drawnow;
    pause(0.1);
    set(h1,'Visible','off');
    set(h2,'Visible','off');
    set(h3,'Visible','off');

end

figure;
index1 = 1:3:298;
plot(dataLogging(index1',2),dataLogging(index1',3),'b');hold on;
plot(dataLogging(index1'+1,2),dataLogging(index1'+1,3),'r');
plot(dataLogging(index1'+2,2),dataLogging(index1'+2,3),'k');