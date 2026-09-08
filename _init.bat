@echo off
setlocal

rem Guardar la ruta absoluta desde la que se ejecuto el script.
set "TARGET=%CD%"

rem Eliminar una asignacion SUBST anterior de Z:, si existe.
subst Z: /D >nul 2>&1

rem Si Z: sigue existiendo, probablemente es una unidad real o de red.
if exist Z:\ (
    echo Error: Z: ya existe y no es una asignacion SUBST que pueda eliminarse.
    exit /b 1
)

rem Montar la carpeta actual como Z:.
subst Z: "%TARGET%"
if errorlevel 1 (
    echo Error: no se pudo montar "%TARGET%" como Z:.
    exit /b 1
)

rem Crear el archivo sin extension "dir" con la ruta que se monto.
>"%TARGET%\dir" echo %TARGET%

echo Z: apunta a "%TARGET%".
echo Ruta guardada en "%TARGET%\dir".

endlocal