function finish
%FINISH Close the project model and remove the project folders from the path.
    projectDir = fileparts(fileparts(mfilename('fullpath')));
    modelName = 'hopping_daisy';

    if bdIsLoaded(modelName)
        % Let Simulink ask to save any unsaved model changes.
        close_system(modelName);
        if bdIsLoaded(modelName)
            return;
        end
    end

    projectPaths = strsplit(genpath(projectDir), pathsep);
    currentPaths = strsplit(path, pathsep);
    pathsToRemove = projectPaths(~cellfun('isempty', projectPaths) & ...
        ismember(projectPaths, currentPaths));
    if ~isempty(pathsToRemove)
        rmpath(pathsToRemove{:});
    end
end
