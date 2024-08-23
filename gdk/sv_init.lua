function gdk.serverInit()
    gdk.config.load()
    if not gdk.config.data.db then
        error("Make sure config.yml has a db section with MySQL connection settings.")
        return
    end

    mysql:connectTable(gdk.config.data.db)
end
