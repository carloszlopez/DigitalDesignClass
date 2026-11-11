function init
%INIT Add the project folders to the MATLAB path and open the model.
    projectDir = fileparts(fileparts(mfilename('fullpath')));
    modelFile = fullfile(projectDir, '30_Model', 'hopping_daisy.slx');
    assert(isfile(modelFile), 'hopping_daisy:MissingModel', ...
        'Model not found: %s', modelFile);

    addpath(genpath(projectDir));
    open_system(modelFile);
end
