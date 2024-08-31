gdk.schema = gdk.schema or {}

function gdk.schema.init()
    println("Initializing schema")
    local mode = engine.ActiveGamemode()

    if mode == "gnomekit" then return end

    gdk.schema.name = mode

    if SERVER then
        gdk.config.load(gdk.fs.add("gamemodes", mode, "config.yml"))
    end

    SCHEMA = {}
    gdk.fs.includeDirectory(gdk.fs.add(mode, "lib"))
    gdk.fs.include(REALM_SHARED, gdk.fs.add(mode, "gdk", "init.lua"))
    gdk.modules.loadAll(gdk.fs.add(mode, "gdk", "modules"))

    local schemaTable = SCHEMA
    SCHEMA = nil

    gdk.hookTable(gdk.schema.name, schemaTable)
end

function gdk.schema.reload()
    local root = gdk.fs.add(gdk.schema.name, "gdk")

    SCHEMA = {}
    gdk.fs.includeDirectory(gdk.fs.add(root, "lib"))
    gdk.fs.include(REALM_SHARED, gdk.fs.add(root, "init.lua"))

    local modDir = gdk.fs.add(root, "modules")

    gdk.modules.loadAll(modDir)
    
    gdk.fs.includeDirectory(gdk.fs.add(root, "lua"), nil, true)

    local schemaTable = SCHEMA
    SCHEMA = nil

    gdk.hookTable(gdk.schema.name, schemaTable)
end
