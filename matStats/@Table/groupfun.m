function res = groupfun(obj, name, op, rowNames)
% Aggregate table values according to levels of a group.
%
%   WARNING: groupfun function is deprecated, use 'aggregate' instead.
%
%   TAB2 = groupfun(TAB, GROUP, OP)
%   GROUP is a column vector with as many elements as the number of rows
%   in the table, and OP is a mathematical operation which computes a value
%   from an array, like 'min', 'max', 'mean'...
%
%   For each unique value in GROUP, the function selects row indices such
%   that values(i)==value, and applies the operation OP to each column of
%   the selected rows. This results is a new row for each unique value in
%   GROUP.
%
%   The resulting table has as many columns as the original table, and a
%   number of rows equal to the number of unique values in GROUP. Rows are
%   labeled with the unique values in GROUP.
%   
%   TAB2 = groupfun(TAB, COLNAME, OP)
%   TAB2 = groupfun(TAB, COLINDEX, OP)
%   Uses one of the columns in the table as a basis for VALUES. In obj
%   case, the resulting table has one column left as the original table,
%   and rows are labeled using a composition of COLNAME and the unique
%   values in the column.
%
%
%   TAB2 = groupfun(..., ROWNAMES)
%   Specifies the names of the rows in the new table.
%
%   Example
%     % Display mean values of each feature, grouped by Species
%     iris = Table.read('fisherIris');
%     groupfun(iris(:,1:4), iris('Species'), @mean)
%     ans = 
%                               SepalLength    SepalWidth    PetalLength    PetalWidth
%     Species=Setosa                  5.006         3.428          1.462         0.246
%     Species=Versicolor              5.936          2.77           4.26         1.326
%     Species=Virginica               6.588         2.974          5.552         2.026
%
%     % The same, but choose different row names
%     newNames = {'Setosa-mean', 'Versicolor-mean', 'Virginica-mean'};
%     groupfun(iris(:,1:4), iris('Species'), @mean, newNames)
%     ans = 
%                            SepalLength    SepalWidth    PetalLength    PetalWidth
%     Setosa-mean                  5.006         3.428          1.462         0.246
%     Versicolor-mean              5.936          2.77           4.26         1.326
%     Virginica-mean               6.588         2.974          5.552         2.026
%
%   See also
%     aggregate
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2008-02-11,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA

warning('matStat:table:deprecated', ...
    'groupfun function is deprecated, use "aggregate" instead');

%% Process input arguments

% if operation is not specified, use 'mean' by default
if nargin < 3
    op = @mean;
end

if nargin < 4
    rowNames = {};
end

% the name of each unique value
valueNames = {};

if isnumeric(name) && length(name) == rowNumber(obj)
    % Second argument is a list of values with same length as the number of
    % rows in the input table
    values  = name;
    cols    = 1:columnNumber(obj);
    colName = '';
    
elseif isa(name, 'Table')
    % Second argument is a table containing factor levels
    values = name.Data(:, 1);
    colName = name.ColNames{1};
    cols    = 1:columnNumber(obj);
    
    if isFactor(name, 1)
        valueNames = name.Levels{1};
    end
    
else
    % Second argument is either column index or a column name
    % 1 extract group values
    % 2 remove group column from original table
    
    % find index of the column, keep only the first one
    ind = columnIndex(obj, name);
    ind = ind(1);
    
    % extract column to process
    values = obj.Data(:, ind);
    colName = obj.ColNames{ind};
    
    % indices of other columns
    cols = 1:columnNumber(obj);
    cols(ind) = [];
end


%% Performs grouping 

% number of selectedcolumns
nCols = length(cols);

% extract unique values
if ischar(values)
    uniVals = unique(values, 'rows');
    nValues = size(uniVals, 1);
else
    uniVals = unique(values);
    nValues = length(uniVals);
end

% create empty data array
res = zeros(length(uniVals), nCols);

% apply operation on each column
for i = 1:nValues
    inds = values == uniVals(i);
    for j = 1:nCols
        res(i, j) = feval(op, obj.data(inds, cols(j)));
    end    
end

% if value names are not initialized, create string array of numeric vector 
if isempty(valueNames)
    if isnumeric(uniVals)
        valueNames = strtrim(cellstr(num2str(uniVals, '%d')));
    elseif ischar(uniVals)
        valueNames = strtrim(cellstr(uniVals));
    end
end

% extract names of rows, or create them if necessary
if isempty(rowNames)
    rowNames = strcat([colName '='], valueNames);
end

% create result dataTable
res = Table(res, 'colNames', obj.colNames(cols), 'rowNames', rowNames);

