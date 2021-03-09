function [ pcount, fcount ] = CausalCount( obj, plist, flist )
%CAUSALCOUNT    Counts the events from flist that are in the future of 
%   each event of plist and, vise verca, counts the events from plist 
%   that are in the past of each event of flist.
% 
% Arguments:
% obj                 Causet class object.
% plist               Logical selection vector or list of events. 
% flist               Logical selection vector or list of events. 
% 
% Returns:
% pcount              Vector that has for each event in plist the number 
%                     of events of flist that succeed it. 
% fcount              Vector that has for each event in flist the number 
%                     of events of plist that preceed it.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 3, 3 );
    m = obj.C( plist, flist );
    pcount = sum( m, 2 )';
    fcount = sum( m, 1 );
end

