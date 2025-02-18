%Script to try every possible set of modeling training parameters
%DEPENDS ON WORKSPACE GENERATED BY analyze.m

%initialize cell for holding all of the parameters
%dimensions correspond to the order of the nested loops:
% embryo, set of input parameters, stripe, training time-point, GFP/noGFP
parameters = cell(3,6,5,5,2);

H = waitbar(0);
for embryo = 1:3
    for inputs = 1:6
        waitbar(embryo*inputs/18,H);
        %Single stripe enhancers
        s=0;
        for stripe = [1 2 5];
            s = s+1;
            t = 0;
            %loop over training start points
            for startTime = 25:5:45
                t = t+1;
                try
                    %Run logReg on GFP
                    [parameters{embryo,inputs,s,t,1}, ~, h] = ...
                        logReg(Gap(inputs),...
                        miniGFPbyStripe{embryo}{stripe},...
                        startTime);
                    %Save figure
                    figSave(h,'GFP',inputs,embryo,stripe,startTime);
                catch
                end
                
                
                try
                    %Run logReg on noGFP
                    [parameters{embryo,inputs,s,t,2}, ~, h] = ...
                        logReg(Gap(inputs),...
                        mininoGFPbyStripe{embryo}{stripe},...
                        startTime);
                    %Save figure
                    figSave(h,'noGFP',inputs,embryo,stripe,startTime);
                catch
                end
                
            end
        end
        
        %----Double stripe enhancers----
        s = s+1;
        %add miniCP's together
        try
            g = addMiniCP(miniGFPbyStripe{embryo}{3},...
                miniGFPbyStripe{embryo}{7});
            ng = addMiniCP(mininoGFPbyStripe{embryo}{3},...
                mininoGFPbyStripe{embryo}{7});
            stripe = 37;
            %loop over training start points
            t = 0;
            for startTime = 25:5:45
                t = t+1;
                %Run logReg
                [parameters{embryo,inputs,s,t,1}, ~, h] = ...
                    logReg(Gap(inputs), g, startTime);
                %Save figure
                figSave(h,'GFP',inputs,embryo,stripe,startTime);
                %Run logReg
                [parameters{embryo,inputs,s,t,2}, ~, h] = ...
                    logReg(Gap(inputs), ng, startTime);
                %Save figure
                figSave(h,'noGFP',inputs,embryo,stripe,startTime);
            end
        catch
        end
        
        s = s+1;
        try
            %add miniCP's together
            g = addMiniCP(miniGFPbyStripe{embryo}{4},...
                miniGFPbyStripe{embryo}{6});
            ng = addMiniCP(mininoGFPbyStripe{embryo}{4},...
                mininoGFPbyStripe{embryo}{6});
            stripe = 46;
            %loop over training start points
            t = 0;
            for startTime = 25:5:45
                t = t+1;
                %Run logReg
                [parameters{embryo,inputs,s,t,1}, ~, h] = ...
                    logReg(Gap(inputs), g, startTime);
                %Save figure
                figSave(h,'GFP',inputs,embryo,stripe,startTime);
                %Run logReg
                [parameters{embryo,inputs,s,t,2}, ~, h] = ...
                    logReg(Gap(inputs), ng, startTime);
                %Save figure
                figSave(h,'noGFP',inputs,embryo,stripe,startTime);
            end
        catch
        end
    end
end
close(H)
