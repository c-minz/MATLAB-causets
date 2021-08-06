function [ P, varargout ] = DAlembertian( obj, PrefPast, method )
%DALEMBERTIAN    Returns the d'Alembertian determined by the given
%   preferred past structure PrefPast that has to be lower triangular.
% 
% Arguments:
% PrefPast            Preferred past structure either as lower triangular
%                     matrix as a vector of preferred past indices.
%                     For causet with 6 events, for example:
%                     [0 0 0 1 1 4], meaning that the preferred past of 
%                     events 1--3 is none, 4 and 5 have event 1, 6 has
%                     event 4.
% 
% Optional arguments:
% method              Computation method. Default: '2D'
%    '2D'             P = 1 + PrefPast - 2 * W * Omega,
%                     where W and Omega are computed from PrefPast and the
%                     causal structure.
%    '2D lattice'     P = 1 - L + PrefPast
% 
% Returns:
% P                   d'Alembertian matrix.
    narginchk( 2, 3 );
    if nargin < 3
        method = '2D';
    end
    
    %% check if the given preferred past structure is valid
    s = size( PrefPast );
    if ( s(1) == 1 && s(2) == obj.Card ) || ...
       ( s(2) == obj.Card && s(2) == 1 )
        Lambda = zeros( obj.Card );
        for i = 1 : obj.Card
            if PrefPast( i ) > obj.Card
                error( [ 'The indices in the vector for the preferred ', ...
                         'past structure must be between 0 and %d.' ], obj.Card );
            elseif PrefPast( i ) > 0
                Lambda( i, PrefPast( i ) ) = 1;
            end
        end
        PrefPast = Lambda;
    elseif s(1) ~= obj.Card || s(2) ~= obj.Card
        error( [ 'The preferred past structure has to be a %dx%d ', ...
                 'matrix or a %d vector.' ], obj.Card, obj.Card, obj.Card );
    end
    if ~istril( PrefPast )
        error( 'The preferred past structure has to be lower triangular.' );
    end
    PrefPast = double( PrefPast );
    
    %% compute the d'Alembertian
    P = eye( obj.Card );
    varargout = {}; % holds optional additional outputs
    if strcmp( method, '2D lattice' )
        P = P + PrefPast - double( transpose( obj.L ) );
    elseif strcmp( method, '2D' )
        Omega = zeros( obj.Card );
        for p = 1 : obj.Card
            p_pp = find( PrefPast( p, : ) );
            if isempty( p_pp )
                continue % element does not have a preferred past
            end
            p_pp = p_pp( 1 );
            for q = 1 : obj.Card
                if obj.C( p_pp, q ) && obj.C( q, p )
                    Omega( p, q ) = 1;
                end
            end
        end
        W = 1 ./ sum( Omega, 2 );
        W( W == Inf ) = 0;
        W = diag( W );
        P = P + PrefPast - 2 * W * Omega;
        varargout{1} = Omega; % first optional output
        varargout{2} = W; % second optional output
    else
        error( 'Unknown method: %s', method );
    end
end
