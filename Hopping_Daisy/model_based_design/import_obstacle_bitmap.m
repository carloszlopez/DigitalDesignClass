function import_obstacle_bitmap(dictionaryFile)
%IMPORT_OBSTACLE_BITMAP Import a PNG into the model's data dictionary.
% Run import_obstacle_bitmap to use the dictionary linked to hopping_daisy.
% Alternatively: import_obstacle_bitmap('Z:\path\dictionary.sldd').
%
% obstacle_bitmap is an H-by-W uint32 matrix indexed as (y+1,x+1).
% Each element contains 0xAARRGGBB: alpha, red, green, blue.
% This function runs in MATLAB before simulation or HDL generation.

    projectDir = 'Z:\Hopping_Daisy';
    imageFile = fullfile(projectDir, 'media', 'obstacle.png');
    modelFile = fullfile(projectDir, 'model_based_design', ...
        'model', 'hopping_daisy.slx');
    modelName = 'hopping_daisy';

    assert(isfile(imageFile), 'sprite:MissingImage', ...
        'PNG not found: %s', imageFile);

    % Read color and transparency separately.
    [img, colorMap, alpha] = imread(imageFile);

    if ~isempty(colorMap)
        img = uint8(round(255 * ind2rgb(img, colorMap)));
    elseif ismatrix(img)
        img = repmat(img, 1, 1, 3);
    end

    assert(isa(img, 'uint8') && size(img, 3) == 3, ...
        'sprite:ImageFormat', 'Use an 8-bit RGB, grayscale, or indexed PNG.');

    if isempty(alpha)
        alpha = repmat(uint8(255), size(img, 1), size(img, 2));
    end
    assert(isa(alpha, 'uint8'), 'sprite:AlphaFormat', ...
        'Use a PNG with 8-bit transparency.');

    % Preserve exact PNG alpha values; no resizing or color reduction.
    obstacle_bitmap = bitor(bitshift(uint32(alpha), 24), ...
        bitor(bitshift(uint32(img(:, :, 1)), 16), ...
        bitor(bitshift(uint32(img(:, :, 2)), 8), ...
              uint32(img(:, :, 3)))));

    % Locate the dictionary through the existing model configuration.
    if nargin < 1 || isempty(dictionaryFile)
        assert(isfile(modelFile), 'sprite:MissingModel', ...
            'Model not found: %s', modelFile);

        if ~bdIsLoaded(modelName)
            load_system(modelFile);
        end

        dictionaryFile = get_param(modelName, 'DataDictionary');
        assert(~isempty(dictionaryFile), 'sprite:NoDictionary', ...
            ['The model has no linked data dictionary. Link one or pass ' ...
             'its full .sldd path to this function.']);

        % Resolve relative paths from the actual model location.
        originalDir = pwd;
        restoreDir = onCleanup(@() cd(originalDir)); %#ok<NASGU>
        cd(fileparts(get_param(modelName, 'FileName')));
    end

    dictionary = Simulink.data.dictionary.open(dictionaryFile);
    data = getSection(dictionary, 'Design Data');

    if exist(data, 'obstacle_bitmap')
        entry = getEntry(data, 'obstacle_bitmap');
        assert(isscalar(entry), 'sprite:AmbiguousEntry', ...
            'Multiple dictionaries define obstacle_bitmap. Resolve this first.');
        currentValue = getValue(entry);

        % Preserve parameter metadata if the existing entry is a parameter.
        if isa(currentValue, 'Simulink.Parameter')
            currentValue.Value = obstacle_bitmap;
            currentValue.DataType = 'uint32';
            setValue(entry, currentValue);
        else
            setValue(entry, obstacle_bitmap);
        end
    else
        addEntry(data, 'obstacle_bitmap', obstacle_bitmap);
    end

    saveChanges(dictionary);

    fprintf('Saved obstacle_bitmap: %d rows x %d columns, uint32 AARRGGBB.\n', ...
        size(obstacle_bitmap, 1), size(obstacle_bitmap, 2));
    fprintf('Dictionary: %s\n', dictionaryFile);
end
