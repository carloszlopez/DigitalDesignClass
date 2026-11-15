function import_labels(dictionary_file)
%IMPORT_LABELS Import 10_Media/labels.txt as glyph indices in Design Data.
%   Write one label per line, for example: score_text = "score "
%   import_labels uses the dictionary linked to hopping_daisy.slx.
%   import_labels('Z:\path\to\data.sldd') selects a dictionary explicitly.
%   Run this tool in MATLAB before simulation or HDL generation.

project_dir = fileparts(fileparts(mfilename('fullpath')));
labels_file = fullfile(project_dir, '10_Media', 'labels.txt');
assert(isfile(labels_file), 'labels:MissingFile', 'File not found: %s', labels_file);

% One character per cell in font.png, left to right.
font_order = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ ';
file_text = fileread(labels_file);
if ~isempty(file_text) && file_text(1) == char(65279)
    file_text = file_text(2:end);
end
lines = regexp(file_text, '\r\n|\n|\r', 'split');
names = {};
values = {};

% Validate all definitions before editing the dictionary.
for k = 1:numel(lines)
    line = lines{k};
    if isempty(strtrim(line))
        continue
    end
    tokens = regexp(line, '^\s*([A-Za-z][A-Za-z0-9_]*)\s*=\s*"([^"]+)"\s*$', ...
        'tokens', 'once');
    assert(~isempty(tokens), 'labels:InvalidLine', ...
        'Invalid line %d in labels.txt. Expected name = "nonempty text".', k);
    name = tokens{1};
    content = tokens{2};
    assert(isvarname(name), 'labels:InvalidName', ...
        'Invalid MATLAB variable name on line %d: "%s".', k, name);

    % Preserve spaces, including intentional trailing spaces.
    [supported, index] = ismember(upper(content), font_order);
    if ~all(supported)
        pos = find(~supported, 1);
        error('labels:UnsupportedGlyph', ...
            'Label "%s": character U+%04X at position %d is not in font.png.', ...
            name, double(content(pos)), pos);
    end
    names{end + 1} = name; %#ok<AGROW>
    values{end + 1} = uint8(index - 1); %#ok<AGROW>
end
n = numel(names);
assert(numel(unique(names)) == n, 'labels:DuplicateName', ...
    'Two or more labels use the same name.');
if n == 0
    fprintf('No label definitions found in %s.\n', labels_file);
    return
end

if nargin < 1 || isempty(dictionary_file)
    model_name = 'hopping_daisy';
    if ~bdIsLoaded(model_name)
        models = dir(fullfile(project_dir, '**', [model_name '.slx']));
        assert(numel(models) == 1, 'labels:ModelLocation', ...
            ['Could not locate exactly one hopping_daisy.slx. Open the ' ...
             'model or pass the full .sldd path to import_labels.']);
        load_system(fullfile(models(1).folder, models(1).name));
    end
    dictionary_file = get_param(model_name, 'DataDictionary');
    assert(~isempty(dictionary_file), 'labels:NoDictionary', ...
        'The model has no linked data dictionary. Pass its full .sldd path.');
    model_dir = fileparts(get_param(model_name, 'FileName'));
    model_relative_file = fullfile(model_dir, dictionary_file);
    if isfile(model_relative_file)
        dictionary_file = model_relative_file;
    end
end

dictionary = Simulink.data.dictionary.open(dictionary_file);
section = getSection(dictionary, 'Design Data');
entries = cell(1, n);
for k = 1:n
    if exist(section, names{k})
        entries{k} = getEntry(section, names{k});
        assert(isscalar(entries{k}), 'labels:AmbiguousEntry', ...
            'Multiple dictionaries define "%s".', names{k});
    end
end
for k = 1:n
    if isempty(entries{k})
        addEntry(section, names{k}, values{k});
    else
        setValue(entries{k}, values{k});
    end
end
saveChanges(dictionary);

for k = 1:n
    fprintf('%s = uint8(%s)\n', names{k}, mat2str(values{k}));
end
fprintf('Saved %d label(s) to %s.\n', n, dictionary_file);
end
