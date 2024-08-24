function gdk.init()
    if SERVER then
        gdk.serverInit()
    end

    println("Loading modules")
    gdk.modules.loadAll("gnomekit/gdk/modules")
end

function gdk.reload()
    println("Reloading modules")
    gdk.modules.list = {}
    gdk.modules.idName = {}
    gdk.modules.loadAll("gnomekit/gdk/modules")
end