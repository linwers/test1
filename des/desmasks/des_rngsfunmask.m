function varargout = des_rngsfunmask(block, action, subaction)
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/08/11 15:39:52 $

%*********************************************************************
% --- Action switch -- Determines which of the callback functions is called
%*********************************************************************

switch(action)
%*********************************************************************
% Function Name:     init
% Description:       Main initialization code
% Inputs:            current block and any parameters from the mask 
%                    required for parameter calculation.
% Return Values:     params - Parameter structure
%********************************************************************
case 'init',
    % Pass the MaskParamCheck array of structures to the error checking   
    % --- common initialization
    des_initmask(block, action, subaction);
    des_setConnectedStatus(block);
    
% % --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------
case 'cbDistType',
    cbDistType(block, subaction);
    des_setConnectedStatus(block);

end; % End of switch(action)
return;

% ----------------
% --- Subfunctions
% ----------------

%*********************************************************************
% Function Name:    cbDistType
% Description:      Change mask based on distribution selection.
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbDistType(block, subaction)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
   
    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    idxDistAll = [idxMeanExp idxMinUnif idxMaxUnif idxPOneBern ...
                  idxPSuccessBino idxNumTrialBino idxMeanNorm idxStdNorm ...
                  idxMinTri idxMaxTri idxModeTri idxThresholdLogn ...
                  idxScaleLogn idxShapeLogn idxPSuccessGeo idxMeanPoiss ...
                  idxThresholdLogl idxScaleLogl idxThresholdGam ...
                  idxScaleGam idxShapeGam idxMinBeta idxMaxBeta ...
                  idxShape1Beta idxShape2Beta idxMinUnid idxMaxUnid ...
                  idxNumValueUnid idxThresholdWbl idxScaleWbl idxShapeWbl ...
                  idxValueVecCont idxCdfVecCont idxValueVecDisc ...
                  idxProbVecDisc];
    idxDistExp   = [idxMeanExp];
    idxDistUnif   = [idxMinUnif idxMaxUnif];
    idxDistNorm = [idxMeanNorm, idxStdNorm];
    idxDistWbl = [idxThresholdWbl idxScaleWbl idxShapeWbl];
    idxDistLogl = [idxThresholdLogl idxScaleLogl];
    idxDistLogn = [idxThresholdLogn idxScaleLogn idxShapeLogn];
    idxDistGam = [idxThresholdGam idxScaleGam idxShapeGam];
    idxDistBeta = [idxMinBeta idxMaxBeta idxShape1Beta idxShape2Beta];
    idxDistBern = [idxPOneBern];
    idxDistBino = [idxPSuccessBino, idxNumTrialBino];
    idxDistGeo = [idxPSuccessGeo];
    idxDistPoiss = [idxMeanPoiss];
    idxDistCont = [idxValueVecCont idxCdfVecCont];
    idxDistUnid = [idxMinUnid idxMaxUnid idxNumValueUnid];
    idxDistDisc = [idxValueVecDisc idxProbVecDisc];
    idxDistTri = [idxMinTri idxMaxTri idxModeTri];
    
    [Vis{[idxDistAll]} ] = deal('off');
    DistType = Vals{idxDistribution};
    [Vis{[idxSeed]}]   = deal('on');
    switch DistType,
    case 'Exponential',
    	[Vis{[idxDistExp]}]   = deal('on');
    case 'Uniform',
    	[Vis{[idxDistUnif]} ] = deal('on');
    case 'Gaussian (normal)',
        [Vis{[idxDistNorm]} ] = deal('on');
    case 'Weibull',
        [Vis{[idxDistWbl]} ] = deal('on');        
    case 'Log-logistic',
        [Vis{[idxDistLogl]} ] = deal('on');        
    case 'Lognormal',
        [Vis{[idxDistLogn]} ] = deal('on');        
    case 'Gamma',
        [Vis{[idxDistGam]} ] = deal('on');        
    case 'Beta',
        [Vis{[idxDistBeta]} ] = deal('on');        
    case 'Bernoulli',
        [Vis{[idxDistBern]} ] = deal('on');        
    case 'Binomial',
        [Vis{[idxDistBino]} ] = deal('on');        
    case 'Geometric',
        [Vis{[idxDistGeo]} ] = deal('on');        
    case 'Poisson',
        [Vis{[idxDistPoiss]} ] = deal('on');        
    case 'Arbitrary continuous',
        [Vis{[idxDistCont]} ] = deal('on');        
    case 'Discrete uniform',
        [Vis{[idxDistUnid]} ] = deal('on');                
    case 'Arbitrary discrete',
        [Vis{[idxDistDisc]} ] = deal('on');                        
    case 'Triangular',
        [Vis{[idxDistTri]} ] = deal('on');                                
    otherwise,
        des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for function type' ]);
    end
    [Vis{[idxSeed]}]   = deal('on');
    set_param(block, 'MaskVisibilities', Vis);
return;



% --- end of des_rngsfunmask.m
