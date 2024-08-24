
local green = Color(0, 255, 0)
local red = Color(255, 0, 0)
function MODULE:Init()
    if not gdk.config.data.db then
        error("Make sure config.yml has a db section with MySQL connection settings.")
        return
    end

    local future = mysql:connectTable(gdk.config.data.db)
    future:callback(function()
        println("Connected to the MySQL database!")
        hook.Run("GDKMySQLConnected")
    end)

    future:error(function(err)
        println("Could not connect to the MySQL database!\n" .. err)
        hook.Run("GDKMySQLConnectionError", err)
    end)

    future()
end
