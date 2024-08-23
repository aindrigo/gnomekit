--[[
Copyright 2024 Adam Indrigo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---------------------
Wrapper for MySQLOO, designed to make development easier.
]]--

require("mysqloo")

mysql = mysql or {}
mysql.connected = mysql.connected or  false

function mysql:connect(host, port, username, password, database)
    return mysql:connectTable({
        ["host"] = host,
        ["port"] = port,
        ["username"] = username,
        ["password"] = password,
        ["database"] = database
    })
end

local green = Color(0, 255, 0)
local red = Color(255, 0, 0)
function mysql:connectTable(connectionData)
    mysql.database = mysqloo.connect(connectionData.host, connectionData.username, connectionData.password, connectionData.database, connectionData.port)
    mysql.database.onConnected = function( db )
        MsgC(green, "[MySQL] ", color_white, "Successfully connected to the database!\n")
    end
    mysql.database.onConnectionFailed = function( db, err )
        MsgC(red, "[MySQL] ", color_white, "Could not connect to the database!\n" .. err .. "\n")
    end
    mysql.database:connect()
end

