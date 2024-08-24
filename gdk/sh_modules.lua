gdk.modules = gdk.modules or {}
gdk.modules.idName = gdk.modules.idName or {}
gdk.modules.list = gdk.modules.list or {}
gdk.modules.directory = gdk.modules.directory or "gdk/modules"

function gdk.modules.loadAll(directory, filter)
    directory = directory or gdk.modules.directory
    filter = filter or "*"

    for _, fPath in ipairs(gdk.fs.find(directory, filter)) do
        if not file.IsDir(fPath, "LUA") then continue end

        local moduleInfo = util.JSONToTable(file.Read(gdk.fs.add(fPath, "module-info.json"), "LUA"))
        if not moduleInfo then
            warnln("Module", fPath, "does not contain module-info.json or is invalid. Continuing")
            continue
        end

        local fName = gdk.fs.fileNameFromPath(fPath)
        moduleInfo.id = moduleInfo.id or fName
        moduleInfo.name = moduleInfo.name or fName

        gdk.modules.idName[moduleInfo.id] = table.insert(gdk.modules.list, moduleInfo)
    end

    for i, mod in ipairs(gdk.modules.list) do
        if istable(mod.dependsOn) then
            local deps = {}
            for i, depID in ipairs(mod.dependsOn) do
                local depmodID = gdk.modules.idName[depID]
                if not depmodID then
                    warnln("Warning: Module", mod.id, "depends on an invalid module", depID)
                    continue
                end

                table.insert(deps, depmodID)
            end

            local newID = math.max(unpack(deps)) + 1
            table.remove(gdk.modules.list, i)
            table.insert(gdk.modules.list, newID, mod)
        end
    end
end