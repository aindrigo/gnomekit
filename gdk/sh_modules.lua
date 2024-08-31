gdk.modules = gdk.modules or {}
gdk.modules.idName = gdk.modules.idName or {}
gdk.modules.list = gdk.modules.list or {}
function gdk.modules.loadAll(directory, filter)
    filter = filter or "*"

    for _, fPath in ipairs(gdk.fs.find(directory, filter)) do
        if not file.IsDir(fPath, "LUA") then continue end

        local infoFile = gdk.fs.add(fPath, "module-info.lua")
        INFO = {}

        gdk.fs.include(REALM_SHARED, infoFile)
        local moduleInfo = INFO

        INFO = nil
        
        local fName = gdk.fs.fileNameFromPath(fPath)
        moduleInfo.ID = moduleInfo.ID or fName
        moduleInfo.Name = moduleInfo.Name or fName
        moduleInfo.Path = fPath

        gdk.modules.idName[moduleInfo.ID] = table.insert(gdk.modules.list, { info = moduleInfo })
    end

    -- account for dependencies and move in list if dependencies are below
    for i, mod in ipairs(gdk.modules.list) do
        if istable(mod.info.DependsOn) and not mod._alreadySorted and #mod.info.DependsOn > 0 then
            local deps = {}
            for i, depID in ipairs(mod.info.DependsOn) do
                local depmodID = gdk.modules.idName[depID]
                if not depmodID then
                    warnln("Warning: Module", mod.ID, "depends on an invalid module", depID)
                    continue
                end

                local depmod = gdk.modules.list[depmodID]
                if depmod.info.DependsOn and table.HasValue(depmod.info.DependsOn, mod.info.id) then
                    warnln("Warning: Modules", mod.ID, "and", depmodID, "depend on eachother. Continuing")
                    continue
                end

                table.insert(deps, depmodID)
            end

            local newID = math.max(unpack(deps)) + 1
            if i >= newID then
                mod._alreadySorted = true
                continue
            end

            table.remove(gdk.modules.list, i)
            table.insert(gdk.modules.list, newID, mod)
        end
    end

    -- iterate one last time to actually execute the code
    for i, mod in ipairs(gdk.modules.list) do
        local luaPath = gdk.fs.add(mod.info.Path, "lua")
        local libPath = gdk.fs.add(mod.info.Path, "lib")

        _G["MODULE"] = mod
        gdk.fs.includeDirectory(libPath, nil, true)
        gdk.fs.includeDirectory(luaPath, nil, true)
        local modData = _G["MODULE"] or {}

        gdk.modules.list[i] = _G["MODULE"]
        local mod = gdk.modules.list[i]
        _G["MODULE"] = nil

        gdk.hookTable(mod.info.Name, mod)

        if isfunction(mod.Init) then
            mod:Init()
        end

        println("Loaded module", mod.info.Name)
    end
end

function gdk.modules.unloadAll()
    for i, mod in ipairs(gdk.modules.list) do
        local name = mod.info.Name

        for eventName, hooks in pairs(hook.GetTable()) do
            for hookName, _ in pairs(hooks) do
                if isstring(hookName) and string.StartsWith(hookName, name .. ".") then
                    hook.Remove(eventName, hookName)
                end
            end
        end
    end

    gdk.modules.list = {}
    gdk.modules.idName = {}
end

function gdk.modules.get(name)
    local id = gdk.modules.idName[name]
    if not id then return end

    return gdk.modules.list[id] 
end
