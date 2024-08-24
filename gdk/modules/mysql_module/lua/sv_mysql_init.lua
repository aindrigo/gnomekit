function MODULE:Init()
    if not gdk.config.data.db then
        error("Make sure config.yml has a db section with MySQL connection settings.")
        return
    end

    mysql:connectTable(gdk.config.data.db)
end

local query = mysql:select("players")
query:where("steamid", "penis")
query:callback(function(data)
    print("e")
end)

query:error(function(err)
    print(err)
end)

query:exec()