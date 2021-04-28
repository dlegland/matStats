function tab = read(fileName, varargin)
% Read a file containing table data.
%
%   TABLE = Table.read(FILENAME);
%   Where FILENAME is the name of the file to read, returns a new data
%   table initialized with the content of the file.
%
%   TABLE = Table.read;
%   Without argument, the function opens a dialog to choose a data file,
%   and return the corresponding data table.
%
%   TABLE = Table.read(NAME)
%   Open one of the sample files packaged with the class. Sample files
%   include:
%   'fisherIris'    classical Fisher's Iris data set (with corrections)
%   'fisherIrisOld' Matlab Iris data set, with errors on samples 35 and 38
%   'fleaBeetles'   a data set included in R software, see:
%       http://rgm2.lab.nig.ac.jp/RGM2/func.php?rd_id=DPpackage:fleabeetles
%   'decathlon'     results of sportive tournament, used as sample file for
%       the 'FactoMineR' R package.
%   'wine'          results of a chemical analysis of wines grown in the
%       same region in Italy but derived from three different cultivars.
%       The dataset is described here:
%       http://archive.ics.uci.edu/ml/datasets/Wine
%
%   TABLE = Table.read(..., PARAM, VALUE);
%   Can specifiy parameters when reading the file. Available parameters
%   are:
%   'header' specifies if an header is present in the file. Can be true
%       (the default) or false.
%   'decimalPoint' a character to use when parsing numbers. Default is '.'.
%       When using a different value, lines will be analysed as text and
%       parsed, making the processing time longer. 
%   'delimiter' the set of characters used to delimitate values. Default
%       are ' \b\t' (space and tabulation).
%   'needParse' is a boolean used to force the parsing of numeric values.
%       If the decimal point is changed, parsing is automatically forced.
%   'rowNames' specifies index of the column containing the name of rows.
%       If set to 0, rows are numbered in natural ordering.
%   'RemoveQuotes' (true or false): if TRUE, forces the parsing of lines,
%       and removes the quotes of the text values. This can be necessary
%       for files containing factor levels.
%   'skipLines' specifies the number of lines to skip between the header
%       and the first line containing data.
%
%
%   Example
%     tab = Table.read('fisherIris');
%     scatterGroup(tab('petalWidth'), tab('petalLength'), tab('class'));
%
%   See also
%     write, concatFiles, textscan
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2010-08-05,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Initialisations

% if no file name is provided, open a dialog to choose a file
if nargin < 1
    [fileName, path] = uigetfile(...
        {...
            '*.txt;*.TXT',  'Text Files (*.txt)'; ...
            '*.*',  'All Files (*.*)'}, ...
        'Choose a data table');
    fileName = fullfile(path, fileName);
end

% parse options and group into data structure
options = parseOptions(varargin{:});

% additional processing of input options
if any(options.delim == options.whiteSpaces)
    % if separator is space or tab, allow multiple separators to be treated
    % as only one
    delimOptions = {...
        'Delimiter', options.delim, ...
        'MultipleDelimsAsOne', true};
else
    % otherwise, two separators correspond to distinct columns
    delimOptions = {...
        'Delimiter', options.delim, ...
        'MultipleDelimsAsOne', false};
end
 

%% Open file for reading

[filePath, baseName, ext] = fileparts(fileName);

% open file
fullFileName = fullfile(filePath, [baseName ext]);

% if file does not exist, try to add the path to the list of sample files
if exist(fullFileName, 'file') == 0 && isempty(filePath)
    % retrieve the path to sample files
    [filePath, ~] = fileparts(mfilename('fullpath'));
    filePath = fullfile(filePath, 'private');
    
    % create newfile path
    fullFileName = fullfile(filePath, [baseName ext]);
    
    % if file still does not exist, try to add default '.txt' extension
    if exist(fullFileName, 'file') == 0 && isempty(ext)
        ext = '.txt';
        fullFileName = fullfile(filePath, [baseName ext]);
    end
end

f = fopen(fullFileName, 'r');
if f == -1
	error('Couldn''t open the file %s', [baseName ext]);
end

% keep filename into data structure
[path, name] = fileparts(fileName); %#ok<ASGLU>


%% Read header

% default column names
colNames = {};

% Read the first line, which contains the name of each column
if options.header
    names = textscan(fgetl(f), '%s', delimOptions{:});
    colNames = names{1}(:)';
end


%% Prepare reading data

% eventually skip some lines
for i = 1:options.skipLines
    fgetl(f);
end

% read the first data line
line = fgetl(f);

% count the number of strings in the first line
C1  = textscan(line, '%s', delimOptions{:});
C1  = C1{1};

% number of columns, and of data column
n   = length(C1);
nc  = n;

% name cleanup
if options.removeQuotes
    colNames = removeEndQuotes(colNames);
end

% Try to automatically detect the column containing row names
if options.header && options.rowNamesIndex == -1
    % if first variable is explicitely called 'name', use it for row names
    if strcmp(colNames{1}, 'name') || strcmp(colNames{1}, 'nom')
        options.rowNamesIndex = 1;
    end
end

% if column containing row names is given as string, identifies its index
if ischar(options.rowNamesIndex)
    ind = find(strcmp(options.rowNamesIndex, colNames));
    if isempty(ind)
        error(['Could not identify row names column from label: ' options.rowNamesIndex]);
    end
    if length(ind) > 1
        error(['Multiple column names with label: ' options.rowNamesIndex]);
    end
    options.rowNamesIndex = ind;
end

if options.rowNamesIndex > 0
    % number of data columns (remove one as first column contains row names)
    nc  = n - 1;

    % check column names have appropriate number
    if length(colNames) > nc
        colNames(options.rowNamesIndex) = [];
    end
    
else
    % no colum is secified for row names, but row names may still be
    % present. So we check number of columns in header and in first line
    if options.header && n > length(colNames)
        options.rowNamesIndex = 1;
        nc = n - 1;
    end
end


% ensure table has valid column names
if isempty(colNames)
     colNames = strtrim(cellstr(num2str((1:nc)'))');
end

% determines which columns are numeric
numeric = isfinite(str2double(C1));

% forces the column containing row names to be read as string
if options.rowNamesIndex > 0
    numeric(options.rowNamesIndex) = false;
end

% compute appropriate format for reading all lines
formats = cell(1, n);
if options.needParse
    formats(:) = {' %s'};
else
    formats(numeric)    = {' %f'};
    formats(~numeric)   = {' %s'};
end
format = strtrim(strcat(formats{:}));


%% Read data

% read the rest of the file, in a Cell array (each cell is a column)
C = textscan(f, format, delimOptions{:});

% if a problem occured without parsing, try again by forcing parse
if ~feof(f) && ~options.needParse
    warning('Table:UnexpectedEndOfFile', ...
        'Could not read the whole file, possibly due to NaN or text values.\nRetry by forcing parse.');
    
    % restart from beginning of file
    fseek(f, 0, 'bof');
    
    % re-compute necessary options
    options.needParse = true;
    formats = cell(1, n);
    formats(:) = {' %s'};
    format = strtrim(strcat(formats{:}));
    
    % eventually skip some lines
    for i = 1:options.skipLines
        fgetl(f);
    end
    
    % read again the header and the first data line
    if options.header
        fgetl(f);
    end
    fgetl(f);
    
    % read the rest of the file in a cell array
    C = textscan(f, format, delimOptions{:});
end

% check if end of file was reached.
if ~feof(f)
    error('Table:UnexpectedEndOfFile', ...
        'Could not read the whole file, possibly due to NaN or text values.');
end

% close file
fclose(f);


%% Format data

% convert values of first line to numeric
if ~options.needParse
    C1(numeric) = num2cell(str2double(C1(numeric)));
end

% concatenate first line with the rest 
for i = 1:length(C)
    if numeric(i)
        C{i} = [C1{i} ; C{i}];
    else
        C{i} = [C1(i) ; C{i}];
    end
end

% number of rows
nr  = length(C{1});

% determination of row name labels
if options.rowNamesIndex > 0
    % row names are given in one of the columns
    rowNames = C{options.rowNamesIndex};
    
    % update remaining data
    C(options.rowNamesIndex) = [];
    numeric(options.rowNamesIndex) = [];
    
elseif ~isempty(options.rowNames)
    % row names are given by the user 
    rowNames = options.rowNames;
    
else
    % default row names are indices converted to cell array of chars
    rowNames = strtrim(cellstr(num2str((1:nr)')));
    
end


%% Create table

% create data table with adequate size
tab = Table(zeros(nr, nc), colNames, rowNames);

% setup names
tab.Name = name;
tab.FileName = fileName;


%% Format data

% fill up each column
for i = 1:nc
    
    if numeric(i) && ~options.needParse
        tab.Data(:, i) = C{i};
        
    else
        % current column
        col = C{i};

        % replace decimal separator by a dot
        col = strrep(col, options.decimalPoint, '.');

        % convert to numeric
        num = str2double(col);

        indNan = strcmpi(col, 'na') | strcmpi(col, 'nan');
        
        % choose to store data as numeric values or as factors levels
        if sum(isnan(num(~indNan))) == 0
            % all data are numeric
            tab.Data(:, i)  = num;
        else
            % if there are unconverted values, changes to factor levels
            [levels, I, num]  = unique(col); %#ok<ASGLU>
            
            % optionnally remove quotes
            if options.removeQuotes
                levels = removeEndQuotes(levels);
            end
            
            % check NaN values
            indNA = find(strcmp(levels, 'NA'));
            if ~isempty(indNA)
                num(num == indNA) = 0;
                num(num > indNA) = num(num > indNA) - 1;
                levels(indNA) = [];
            end
            
            % store in Table
            tab.Data(:, i)  = num;
            tab.Levels{i}   = levels;
        end
    end
end



function options = parseOptions(varargin)

% default values
options.rowNames        = {};   % row names specified by user
options.rowNamesIndex   = -1;   % -1 for auto, 0 for no name, >=1 for index
options.decimalPoint    = '.';
options.whiteSpaces     = ' \b\t';
options.delim           = options.whiteSpaces;
options.header          = true; % true if the file contains a header
options.needParse       = false;% true if each line need to be explicitely parsed
options.skipLines       = 0;    % the number of lines to skip before reading
options.removeQuotes    = true;

% process each couple of argument, identifies the options, and set up the
% corresponding value in the result structure
while length(varargin) > 1
    pname = varargin{1};
    value = varargin{2};
    
    if strcmpi(pname, 'RowNames')
        % Specify either row names, or index of column containing row names
        if iscell(value)
            % row names are directly specified with cell array of names
            options.rowNames = value;
        else
            % row names are given either as index or column name
            options.rowNamesIndex = value;
        end
        
    elseif strcmpi(pname, 'Header')
        options.header = value;
        
    elseif strcmpi(pname, 'DecimalPoint')
        options.decimalPoint = value;
        % if not '.' character, we need to parse each item
        if ~strcmp(options.decimalPoint, '.')
            options.needParse = true;
        end
        
    elseif any(strcmpi(pname, {'delim', 'Delimiter'}))
        options.delim = value;
        
    elseif strcmpi(pname, 'NeedParse')
        options.needParse = value;
        
    elseif strcmpi(pname, 'SkipLines')
        options.skipLines = value;
        
    elseif strcmpi(pname, 'RemoveQuotes')
        options.removeQuotes = value;
        
    else
        error('Table:read', ['unknown parameter: ' pname]);
    end
    
    % remove processed parameter pair
    varargin(1:2) = [];
end


function str = removeEndQuotes(str)
% Local function that removes end quotes in a string, or a string array.

if ischar(str)
    % removes quotes in a string
    if ~isempty(str)
        if str([1 end]) == '"'
            str = str(2:end-1);
        end
    end
    
elseif iscell(str)
    % in the case of a cell array of strings, process each element
    for i = 1:length(str)
        str{i} = removeEndQuotes(str{i});
    end
end
