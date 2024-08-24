DeriveGamemode("sandbox")

gdk = gdk or {}

REALM_CLIENT = 0
REALM_SERVER = 1
REALM_SHARED = 2

--- Returns value if condition is truthy, otherwise notValue if it is falsy.
-- @param condition Value, can be anything.
-- @param value Return value if condition is truthy.
-- @param notValue Return value if condition is falsy.
-- @return Value if condition is truthy, otherwise notValue.
function tn(condition, value, notValue)
    if condition then return value end
    return notValue
end

gdk.consoleColor = Color(17, 185, 17)

--- Prints something to the console
-- @vararg Multiple values, space seperated then printed to the developer console
function println(...)
    MsgC(gdk.consoleColor, "[gdk] ", color_white, table.concat({ ... }, " "), "\n")
end

gdk.fs = gdk.fs or {}

--- Adds 2 filesystem paths together.
-- @param original The original path
-- @vararg The paths to add to it (in order)
-- @return The original path with the values added to it.
function gdk.fs.add(original, ...)
    return string.TrimRight(original, "/") .. "/" .. table.concat({ ... }, "/")
end

--- Retrieves the filename from the path (may be incorrect if not using forward slashes).
-- @param path The path to look for the filename/dirname
-- @return The retrieved filename
function gdk.fs.fileNameFromPath(path)
    local split = string.Explode("/", path)
    local len = #split

    return split[tn(len < 1, 0, len)]
end

--- Tries to detect a file's realm (REALM_CLIENT/SERVER/SHARED) by looking at its filename.
-- @param path The file path
-- @return The file realm, can be REALM_CLIENT, REALM_SERVER or REALM_SHARED.
function gdk.fs.detectRealm(path)
    local fileName = gdk.fs.fileNameFromPath(path)
    return tn(string.StartsWith(fileName, "cl_"), REALM_CLIENT, tn(string.StartsWith(fileName, "sv_"), REALM_SERVER, REALM_SHARED))
end

--- Includes a file by a given realm and path.
-- @param realm The realm, should be either an REALM_CLIENT/SERVER/SHARED or an integer value between 0-2.
-- @param path The path of the file to include.
-- @see gdk.fs.detectRealm
function gdk.fs.include(realm, path)
    if realm == REALM_CLIENT then
        AddCSLuaFile(path)
        if CLIENT then
            include(path)
        end
    elseif realm == REALM_SERVER and SERVER then
        include(path)
    elseif realm == REALM_SHARED then
        AddCSLuaFile(path)
        include(path)
    end
end

--- Reads a YAML file.
-- @param path The path to the YAML file
-- @return The table of the YAML file retrieved, or nil if an error was caught
function gdk.fs.readYaml(path)
    return yaml.Read(path)
end

--- Tries to find all files within a given directory.
-- @param path The path of the directory
-- @param filter The filter, for example "*.lua" or just "*" for all files
-- @param recursive If the directories should be iterated over recursively (any directories within path are also included in the return value, also filter must be * and not *.lua or anything like that)
-- @return A table containing the paths of all files found
function gdk.fs.find(path, filter, recursive)
    local result = {}
    path = string.TrimRight(path, "/")

    local files, dirs = file.Find(path .. "/" .. filter, "LUA")

    
    for _, name in ipairs(dirs) do
        local fPath = gdk.fs.add(path, name)
        table.Add(result, gdk.fs.find(fPath, filter, true))
    end

    for _, name in ipairs(files) do
        local fPath = gdk.fs.add(path, name)
        table.insert(result, fPath)
    end

    return result
end

--- Tries to include all *.lua using gdk.fs.include and gdk.fs.detectRealm files from a given directory path.
-- @param path The path to the directory
-- @param excludeFilter A function which is given a file path and should return a truthy value if it should be excluded.
-- @param recursive If the directory should be looked over recursively.
function gdk.fs.includeDirectory(path, excludeFilter, recursive)
    path = string.TrimRight(path, "/")
    local files = gdk.fs.find(path, tn(recursive, "*", "*.lua"), recursive)
    for _, filePath in pairs(files) do
        if excludeFilter and excludeFilter(filePath) then continue end
        if recursive and not string.EndsWith(filePath, ".lua") then continue end

        gdk.fs.include(gdk.fs.detectRealm(filePath), filePath)
    end
end

gdk.fs.include(REALM_SHARED, "gnomekit/gdk/init.lua")
gdk.fs.includeDirectory("gnomekit/gdk/lib")
gdk.fs.includeDirectory("gnomekit/gdk", function(path)
    local name = gdk.fs.fileNameFromPath(path)
    return name == "init.lua"
end, true)