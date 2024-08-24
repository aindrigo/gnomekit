gdk.modules = gdk.modules or {}
gdk.modules.idName = gdk.modules.idName or {}
gdk.modules.list = gdk.modules.list or {}
function gdk.modules.loadAll(directory, filter)
    filter = filter or "*"

    for _, fPath in ipairs(gdk.fs.find(directory, filter)) do
        if not file.IsDir(fPath, "LUA") then continue end

        local contents = file.Read(gdk.fs.add(fPath, "module-info.json"), "LUA")
        if not contents then
            warnln("Module", fPath, "does not contain module-info.json or is invalid. Continuing")
            continue
        end

        local moduleInfo = util.JSONToTable(contents)
        
        local fName = gdk.fs.fileNameFromPath(fPath)
        moduleInfo.id = moduleInfo.id or fName
        moduleInfo.name = moduleInfo.name or fName
        moduleInfo.path = fPath

        gdk.modules.idName[moduleInfo.id] = table.insert(gdk.modules.list, { info = moduleInfo })
    end

    -- account for dependencies and move in list if dependencies are below
    for i, mod in ipairs(gdk.modules.list) do
        if istable(mod.info.dependsOn) and not mod._alreadySorted then
            local deps = {}
            for i, depID in ipairs(mod.info.dependsOn) do
                local depmodID = gdk.modules.idName[depID]
                if not depmodID then
                    warnln("Warning: Module", mod.id, "depends on an invalid module", depID)
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
        local luaPath = gdk.fs.add(mod.info.path, "lua")
        local libPath = gdk.fs.add(mod.info.path, "lib")

        _G["MODULE"] = mod
        gdk.fs.includeDirectory(libPath, nil, true)
        gdk.fs.includeDirectory(luaPath, nil, true)
        local modData = _G["MODULE"] or {}

        gdk.modules.list[i] = _G["MODULE"]
        local mod = gdk.modules.list[i]
        _G["MODULE"] = nil

        if isfunction(mod.Init) then
            mod:Init()
        end

        println("Loaded module", mod.info.name)
    end
end

