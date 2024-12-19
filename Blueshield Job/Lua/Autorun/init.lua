if (Game.IsMultiplayer and SERVER) or not Game.IsMultiplayer then
    BSJob = {}
    BSJob.Path = ...
    dofile(BSJob.Path .. "/Lua/Modules/main.lua")
    dofile(BSJob.Path .. "/Lua/Modules/utils.lua")
    -- dofile(BSJob.Path .. "/Lua/Modules/debug.lua")
end