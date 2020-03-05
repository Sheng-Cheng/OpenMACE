% Controller 19 from Dr. Paley's paper
% Fixed so that Parallel Flight works



% function u = controller19fix(position, angle, N, K, wo)
% sum_rk=0;
%         for i=1:N
%             sum_rk=sum_rk + position(1,i)+1i*position(2,i);
%         end
%     R = (1/N)*sum_rk;
%     Ro = 15; % Anchor value for circle formation
%         for j=1:N
%             r_tilda(j) = (position(1,j)+1i*position(2,j)) - Ro; % Replace with Ro to anchor circle to a point
%         end
%     for l=1:N
%        
%        u(l) = wo*(1+K*real(dot(r_tilda(l),exp(1i*angle(l)))));  % leaving out the U and partial deriv's 
%         
%     end
% 
% end

% -----------------------------------------------------------------%
% Sim version of the fixed controller19 (for easy comparison)

function u = controller19_fix(position, angle, N, K, wo, KK)
    
    sum_rk=0;
        for i=1:N
            sum_rk=sum_rk + position(1,i)+1i*position(2,i);
        end
    R = (1/N)*sum_rk;
    Ro = 10; % Anchor value for circle formation
        for j=1:N
            r_tilda(j) = (position(1,j)+1i*position(2,j)) - R; % Replace with Ro to anchor circle to a point
        end
    for l=1:N
%    
        UkU = 0;
        for ii=1:N
           UkU = UkU + sin(angle(ii)-angle(l)); 
        end
       u(l) = wo*(1+K*real(dot(r_tilda(l),exp(1i*angle(l))))) + (((K-KK)/N)*UkU);  % including the U and partial deriv's 
        
    end 
end