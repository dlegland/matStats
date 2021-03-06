function indCol = columnIndex(obj, colName)
% Index of a column from its name.
%
%   IND = columnIndex(TAB, COLNAME)
%   Returns the index of the column whose name is COLNAME. If COLNAME is a
%   cell array of strings, returns an array of indices.
%   An error is raised when the column name (or one of the column names in
%   the array) is not found.
%
%   If COLNAME is numeric, it is assumed to be the column index, and is
%   returned directly. Hence, the two lines return the same result:
%       IND = columnIndex(TAB, NAME);
%       IND = columnIndex(TAB, columnIndex(TAB, columnIndex(TAB, NAME)));
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-08-06,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

errorMsg = 'Input table does not contain column named "%s"';

% check index of column
if isnumeric(colName)
    % input argument is already an index
    indCol = colName;
    
elseif ischar(colName)
    % parse column name
    if strcmp(colName, ':')
        indCol = 1:length(obj.ColNames);
    else
        indCol = find(strcmp(colName, obj.ColNames));
    end
    
    if isempty(indCol)
        error(errorMsg, colName);
    end
    
elseif iscell(colName)
    % parse a cell array of column names
    N = length(colName);
    indCol = zeros(N, 1);
    names = obj.ColNames; 
    for i = 1:N
        ind = find(strcmp(colName{i}, names));
        if isempty(ind)
            error(errorMsg, colName{i});
        end
        indCol(i) = ind;
    end
    
else
    error('Second argument should be a column name or a column index');
end
