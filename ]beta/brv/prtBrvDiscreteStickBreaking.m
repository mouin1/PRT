classdef prtBrvDiscreteStickBreaking < prtBrvDiscrete
    methods
        function obj = prtBrvDiscreteStickBreaking(varargin)
            if nargin < 1
                return
            end
            obj.model = prtBrvDiscreteStickBreakingHierarchy(varargin{1});
            
            %obj.name = 'Discrete Stick Breaking Bayesian Random Variable';
            %obj.nameAbbreviation = 'BRVSB';
        end
        
        function y = conjugateVariationalAverageLogLikelihood(obj, x)
            
            error('Not done yet');
            
            % y = sum(bsxfun(@times,x,psi(obj.model.lambda)-psi(sum(obj.model.lambda))),2);
        end
        
        function val = expectedLogMean(obj)
            val = obj.model.expectedValueLogProbabilities(:)';
            
            % val = psi(obj.model.lambda) - psi(sum(obj.model.lambda));
        end
        
        function [phiMat, priorObjs] = mixtureInitialize(objs, priorObjs, x)
            
            error('Not done yet');
            
            nStates = length(objs);
            
            minFrames = nStates*10;
            minFrameLength = 10;
            frameLength = floor(mean([floor(size(x,1)./minFrames),minFrameLength]));
            frameInds = buffer((1:size(x,1))',frameLength);
            
            nFrames = size(frameInds,2);
            frameClusteringX = zeros(nFrames,length(priorObjs(1).model.lambda));
            for iFrame = 1:nFrames
                cFrameInds = frameInds(frameInds(:,iFrame)>0,iFrame);
                frameClusteringX(iFrame,:) =  mean(x(cFrameInds,:),1);
            end
            
            prune = any(isnan(frameClusteringX),2);
            frameClusteringX(prune,:) = repmat(mean(frameClusteringX(~prune,:)),sum(prune),1);
            
            [classMeans, Yout] = prtUtilKmeans(frameClusteringX,nStates,'handleEmptyClusters','random'); %#ok<ASGLU>
            
            [unwanted, sortedInds] = sort(hist(Yout,1:nStates),'descend'); %#ok<ASGLU>
            dsMat = bsxfun(@eq,Yout,sortedInds);
            
            phiMat = kron(dsMat,ones(frameLength,1));
            phiMat = phiMat(1:size(x,1),:);

        end
        
        function obj = weightedConjugateUpdate(obj, priorObj, x, weights)
            obj.model = obj.model.conjugateUpdate(priorObj.model,bsxfun(@times,x,weights));
        end
        
        function kld = conjugateKld(obj, priorObj)
            kld = obj.model.kld(priorObj.model);
        end
        
        function x = posteriorMeanDraw(obj, n, varargin)
            if nargin < 2
                n = 1;
            end

            probs = exp(obj.model.expectedValueLogProbabilities);
            x = prtRvUtilRandomSample(probs, n);
        end
        
        function s = posteriorMeanStruct(obj)
            s.probabilities = exp(obj.model.expectedValueLogProbabilities);
        end
        
        function model = modelDraw(obj)
            model.probabilities = draw(obj.model);
        end
        
        function plot(objs, colors)
            
            error('Not done yet');

        end
        
        function [obj, training] = vbOnlineWeightedUpdate(obj, priorObj, x, weights, lambda, D, prevObj)
            if ~isempty(weights)
                x = bsxfun(@times,x,weights);
            end
            
            [obj.model, training] = obj.model.vbOnlineWeightedUpdate(priorObj.model, sum(x,1), [], lambda, D, prevObj.model);
        end
    end
end