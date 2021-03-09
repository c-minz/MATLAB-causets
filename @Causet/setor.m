function s = setor( varargin )
%SETOR    Returns the union of the inputs. If the first input is logical, 
%   the return is a logical selection vector.
%
% Arguments:
% ...                 Lists of events or logical selections vectors.
%
% Returns:
% s                   Union of the inputs.
%                     If the first input is logical, the return is a 
%                     logical selection vector otherwise it is a list of
%                     events.
%                     If there are no inputs, it returns an empty vector.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    if nargin == 0
        s = zeros( 1, 0 );
        return
    end
    s = varargin{ 1 };
    if islogical( s )
        for i = 2 : nargin
            arg = varargin{ i };
            if islogical( arg )
                s = s | arg;
            else
                s( arg ) = true;
            end
        end
    else
        for i = 2 : nargin
            arg = varargin{ i };
            if islogical( arg )
                s = union( s, find( arg ) );
            else
                s = union( s, arg );
            end
        end
    end
end