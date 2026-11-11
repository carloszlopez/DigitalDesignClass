function import_bitmap(dictionaryFile)
%IMPORT_BITMAP Import PNGs from 10_Media and its subfolders into Design Data.
% Defaults to 20_DataDictionary/hopping_daisy_dd.sldd in this project.
% Optionally pass the full path of a different existing .sldd file.
% Each <filename>_bitmap is an H-by-W uint32 matrix containing 0xAARRGGBB.
% Access a zero-based local coordinate with bitmap(y+1, x+1).

    projectDir = fileparts(fileparts(mfilename('fullpath')));
    mediaDir = fullfile(projectDir, '10_Media');

    assert(isfolder(mediaDir), 'bitmap:MissingFolder', ...
        'Media folder not found: %s', mediaDir);

    % Include .png and .PNG files at every directory level.
    files = dir(fullfile(mediaDir, '**', '*'));
    files = files(~[files.isdir]);
    keep = false(size(files));
    for k = 1:numel(files)
        [~, ~, extension] = fileparts(files(k).name);
        keep(k) = strcmpi(extension, '.png');
    end
    files = files(keep);
    if isempty(files)
        fprintf('No PNG files found in %s. Nothing was changed.\n', mediaDir);
        return;
    end

    % Read all images and validate names before modifying the dictionary.
    names = cell(numel(files), 1);
    bitmaps = cell(numel(files), 1);
    for k = 1:numel(files)
        [~, baseName] = fileparts(files(k).name);
        names{k} = matlab.lang.makeValidName([baseName '_bitmap']);
        assert(isvarname(names{k}) && endsWith(names{k}, '_bitmap'), ...
            'bitmap:InvalidName', 'Rename PNG with invalid/long name: %s', ...
            files(k).name);
        bitmaps{k} = readBitmap(fullfile(files(k).folder, files(k).name));
    end
    assert(numel(unique(names)) == numel(names), 'bitmap:DuplicateNames', ...
        ['Multiple PNG files produce the same dictionary variable name. ' ...
         'Rename them before importing. Nothing was changed.']);

    % Use the project dictionary unless an explicit path is given.
    if nargin < 1 || isempty(dictionaryFile)
        dictionaryFile = fullfile(projectDir, '20_DataDictionary', ...
            'hopping_daisy_dd.sldd');
    end
    assert(isfile(dictionaryFile), 'bitmap:MissingDictionary', ...
        'Dictionary not found: %s', dictionaryFile);

    dictionary = Simulink.data.dictionary.open(dictionaryFile);
    data = getSection(dictionary, 'Design Data');

    % Check existing entries before applying any updates.
    entries = cell(numel(files), 1);
    values = bitmaps;
    for k = 1:numel(files)
        if exist(data, names{k})
            entries{k} = getEntry(data, names{k});
            assert(isscalar(entries{k}), 'bitmap:AmbiguousEntry', ...
                'Multiple dictionaries define %s. Resolve this first.', names{k});
            current = getValue(entries{k});
            if isa(current, 'Simulink.Parameter')
                current.Value = bitmaps{k};
                current.DataType = 'uint32';
                values{k} = current;
            end
        end
    end

    for k = 1:numel(files)
        if isempty(entries{k})
            addEntry(data, names{k}, values{k});
        else
            setValue(entries{k}, values{k});
        end
    end
    saveChanges(dictionary);

    for k = 1:numel(files)
        fprintf('%s -> %s [%d rows x %d columns]\n', ...
            fullfile(files(k).folder, files(k).name), names{k}, ...
            size(bitmaps{k}, 1), size(bitmaps{k}, 2));
    end
    fprintf('Saved %d bitmap(s) to %s.\n', numel(files), dictionaryFile);
end

function bitmap = readBitmap(imageFile)
%READBITMAP Preserve PNG dimensions and pack alpha and RGB into uint32 words.
    [img, colorMap, alpha] = imread(imageFile);
    if ~isempty(colorMap)
        img = uint8(round(255 * ind2rgb(img, colorMap)));
    elseif islogical(img)
        img = uint8(img) * uint8(255);
    elseif isa(img, 'uint16')
        img = uint8(bitshift(img, -8));
    end
    if ismatrix(img)
        img = repmat(img, 1, 1, 3);
    end
    assert(isa(img, 'uint8') && size(img, 3) == 3, ...
        'bitmap:ImageFormat', 'Unsupported PNG color format: %s', imageFile);

    if isempty(alpha)
        alpha = repmat(uint8(255), size(img, 1), size(img, 2));
    elseif isa(alpha, 'uint16')
        alpha = uint8(bitshift(alpha, -8));
    elseif islogical(alpha)
        alpha = uint8(alpha) * uint8(255);
    end
    assert(isa(alpha, 'uint8'), 'bitmap:AlphaFormat', ...
        'Unsupported PNG alpha format: %s', imageFile);

    bitmap = bitor(bitshift(uint32(alpha), 24), ...
        bitor(bitshift(uint32(img(:, :, 1)), 16), ...
        bitor(bitshift(uint32(img(:, :, 2)), 8), uint32(img(:, :, 3)))));
end
