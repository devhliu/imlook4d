function y = SRTM_function(p,t,model,Cref,dt)
%     global model;
%     global Cref;
%     global dt;
    
    format compact
    format long
    % calculates y from x=Cref
         R1 = p(1);
         k2 = p(2);
         P0 = p(3);  % = k2/(1+BP)
         
         
         
    disp(model)     
    switch model
    case 'Zhou' 

        % based on Zhou et al, NeuroImage 33 (2006) 550-563
        % Zhou (goes to infinity -- what is wrong ?)
           countsY = exp( P0.*t).*dt;             % integral over duration of each frame
           integral = cumsum(countsY);    % integeral{Cref} 
            y = R1*Cref + ( k2 - R1*P0 ) .* Cref .* exp( -P0*t ) .* integral;

    case {'Lammertsma'}
        %based on Lammertsma    
        % y = R1*Cref + ( k2 - R1*P0 ) * Cref (*) exp( -P0*t ) ; % (*) means convolution
            y = R1*Cref + conv( ...
                ( k2 - R1*P0 ) .* Cref , ...
                exp( -P0*t ), ...
                'same');
            
           y = R1*Cref ...
               + conv( ...
                  ( k2 - R1*P0 ) .* Cref , ...
                  exp( -P0*t ), ...
                  'same'...
                );
            
    case {'Turku'}
       % based on Turku http://www.turkupetcentre.net/reports/tpcmod0002.pdf eq 20

            Ct = zeros( size(Cref) );
            Ct(1) = Cref(1);
            
            
            for i=2:length(Cref)

                % Eq 20
                Ct(i) = R1 * Cref(i) ...
                    + k2 * sum( Cref(1:i).*dt(1:i) ) ...
                    - P0 * (  sum( Ct(1:i-1) .* dt(1:i-1) ) + 0.5 * dt(i) .* Ct(i-1) );
                Ct(i) = Ct(i) / ( 1 + 0.5*dt(i)*P0 );

            end
            y = Ct;        
        
    otherwise
        warning('Unexpected model type.')
    end     


        

end
