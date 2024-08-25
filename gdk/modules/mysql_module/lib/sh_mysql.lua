--[[
Copyright 2024 Adam Indrigo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---------------------
Wrapper for MySQLOO, designed to make development easier and uses the async library.
Requires middleclass and async library.

Example:
local query = mysql:select("players")
query:where("steamid", ply:SteamID())
local data = query:await() -- array of rows
]]--

require("mysqloo")

mysql = mysql or {}
mysql.queue = mysql.queue or {}
mysql.connected = mysql.connected or  false

mysql._queryClass = middleclass("Query", async._futureClass)
function mysql._queryClass:initialize(dbTable)
    local me = self
    async._futureClass.initialize(self, function(success, error)
        local queryStr = me:build()
        if queryStr == "" then 
            table.remove(mysql.queue, i)
            return
        end

        local query = mysql.database:query(queryStr)
        query:setOption(mysqloo.OPTION_NAMED_FIELDS)
        function query.onSuccess(q, data)
            success(data)
        end

        function query.onError(q, err)
            error(err)
        end

        function query.onAborted(q)
            error(query:error())
        end

        query:start()
    end)

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

function mysql:connectTable(connectionData)
    return async(function(success, err)
        mysql.database = mysqloo.connect(connectionData.host, connectionData.username, connectionData.password, connectionData.database, connectionData.port)

        mysql.database.onConnected = function( db )
            success()
        end

        mysql.database.onConnectionFailed = function( db, errMsg )
            err(errMsg)
        end

        mysql.database:connect()
    end)
end

mysql._selectClass = middleclass("SelectQuery", mysql._queryClass)
function mysql._selectClass:initialize(dbTable)
    mysql._queryClass.initialize(self, dbTable)
    self._where = {}
    self._limit = "*"
end

function mysql._selectClass:where(key, value)
    self._where[key] = value
end

function mysql._selectClass:limit(value)
    self._limit = tostring(value)
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
