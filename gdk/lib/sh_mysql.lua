--[[
Copyright 2024 Adam Indrigo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---------------------
Wrapper for MySQLOO, designed to make development easier.
Requires middleclass and async library.
]]--

require("mysqloo")

mysql = mysql or {}
mysql.queue = mysql.queue or {}
mysql.connected = mysql.connected or  false

mysql._queryClass = mysql._queryClass or middleclass("Query")
function mysql._queryClass:initialize(dbTable)
    self.dbTable = dbTable
end

function mysql._queryClass:build()
    return ""
end

function mysql._queryClass:execute()
    table.insert(mysql.queue, self)
end

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

mysql._selectClass = middleclass("SelectQuery", mysql._queryClass)
function mysql._selectClass:initialize(dbTable)
    mysql._queryClass.initialize(self, dbTable)
    self._where = {}
    self._callbacks = {}
    self._limit = "*"
end

function mysql._selectClass:where(key, value)
    self._where[key] = value
end

function mysql._selectClass:limit(value)
    self._limit = tostring(value)
end

function mysql._selectClass:then(cb)
    table.insert(self._callbacks, cb)
end

function mysql._selectClass:build()
    local query = "SELECT " .. self._limit .. " FROM " .. self.dbTable
    if #self._where > 0 then
        local i = 1
        for key, value in pairs(self._where) do
            query = query .. tn(i == 1, " WHERE ", " AND ") .. key .. "=" .. tn(isnumber(value), value, mysql.database:escape(value))
            i = i + 1
        end
    end

    return query
end

function mysql:select(dbTable)
    return mysql._selectClass:new(dbTable)
end

--- Should be called once per tick
function mysql:update()
    for i, queryClass in ipairs(mysql.queue) do
        local queryStr = queryClass:build()
        if queryStr == "" then 
            table.remove(mysql.queue, i)
            continue
        end

        local query = mysql.database:query(queryStr)


        table.remove(mysql.queue, i)
    end
end