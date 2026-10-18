function build()
%BUILD Generate Verilog, collect source files, and remove hdlsrc on success.
% Place this file in Hopping_Daisy/model_based_design and run build.

    buildDir = fileparts(mfilename('fullpath'));
    projectDir = fileparts(buildDir);
    modelName = 'hopping_daisy';
    modelFile = fullfile(buildDir, 'model', [modelName '.slx']);
    generatedDir = fullfile(projectDir, 'hdlsrc');
    sourceDir = fullfile(buildDir, 'source');

    assert(isfile(modelFile), 'build:MissingModel', ...
        'Model not found: %s', modelFile);
    assert(exist('makehdl', 'file') ~= 0, 'build:MissingHDLCoder', ...
        'HDL Coder is required to run this function.');

    % Resolve relative model dependencies from the model folder.
    originalDir = pwd;
    restoreDir = onCleanup(@() cd(originalDir)); %#ok<NASGU>
    cd(fileparts(modelFile));
    load_system(modelFile);

    % Preserve the configured DUT; fall back to the complete model.
    dut = hdlget_param(modelName, 'HDLSubsystem');
    if isempty(dut)
        dut = modelName;
    end

    fprintf('Generating Verilog for %s...\n', dut);
    makehdl(dut, 'TargetLanguage', 'Verilog', ...
        'TargetDirectory', generatedDir);

    % Find all Verilog files, including files in nested folders.
    files = dir(fullfile(generatedDir, '**', '*.v'));
    assert(~isempty(files), 'build:NoVerilog', ...
        'No .v files were found in %s. The folder was preserved.', ...
        generatedDir);

    % Flattening must not silently overwrite files with duplicate names.
    names = lower(string({files.name}));
    assert(numel(unique(names)) == numel(names), ...
        'build:DuplicateNames', ...
        ['Duplicate .v filenames were found in different subfolders. ' ...
         'Nothing was copied and hdlsrc was preserved.']);

    if ~isfolder(sourceDir)
        mkdir(sourceDir);
    end

    % Copy first so a failure never removes the generated originals.
    for k = 1:numel(files)
        sourceFile = fullfile(files(k).folder, files(k).name);
        destinationFile = fullfile(sourceDir, files(k).name);
        [ok, message] = copyfile(sourceFile, destinationFile, 'f');
        assert(ok, 'build:CopyFailed', ...
            'Could not copy %s: %s. hdlsrc was preserved.', ...
            sourceFile, message);
    end

    % Verify every copy before deleting the generation folder.
    for k = 1:numel(files)
        sourceFile = fullfile(files(k).folder, files(k).name);
        destinationFile = fullfile(sourceDir, files(k).name);
        assert(isequal(readBytes(sourceFile), readBytes(destinationFile)), ...
            'build:VerificationFailed', ...
            'Copy verification failed for %s. hdlsrc was preserved.', ...
            files(k).name);
    end

    % Leave the generated folder available if any earlier operation fails.
    [ok, message] = rmdir(generatedDir, 's');
    assert(ok, 'build:CleanupFailed', ...
        'Verilog was copied, but hdlsrc could not be removed: %s', message);

    fprintf('Done: %d Verilog files copied to:\n%s\n', ...
        numel(files), sourceDir);
    fprintf('Removed: %s\n', generatedDir);
end

function bytes = readBytes(filePath)
%READBYTES Read a file without text or newline conversion.
    fid = fopen(filePath, 'rb');
    assert(fid ~= -1, 'build:ReadFailed', ...
        'Cannot open file for verification: %s', filePath);
    closeFile = onCleanup(@() fclose(fid)); %#ok<NASGU>
    bytes = fread(fid, Inf, '*uint8');
end
