function gdk.init()
    if engine.ActiveGamemode() == "gnomekit" then
        error("You cannot use the Gnome Dev Kit on its own. Use a schema!")
        return
    end

    gdk.schema.init()

    if SERVER then
        gdk.serverInit()
    end
end

function gdk.reload()
    gdk.modules.unloadAll()

    gdk.schema.reload()
end

function gdk.hookTable(name, tbl)
    local hookI = 0

    for key, value in pairs(tbl) do
        if isfunction(value) then
            hook.Add(key, name .. "." .. key .. "." .. hookI, value)
            hookI = hookI + 1
        end
    end
end
