gdk.config = gdk.config or {}
gdk.config.data = gdk.config.data or {}

function gdk.config.load(path)
    gdk.config.data = gdk.fs.readYaml(path) or {}
end
