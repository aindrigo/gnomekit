gdk.config = gdk.config or {}
gdk.config.data = gdk.config.data or {}

function gdk.config.load()
    gdk.config.data = gdk.fs.readYaml("gamemodes/gnomekit/config.yml") or {}
end
