if CLIENT then
    Autoreload = {}
    Autoreload.Path = table.pack(...)[1]

    dofile(Autoreload.Path .. "/Lua/Scripts/autoreload.lua")
end