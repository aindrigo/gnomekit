--[[
Copyright 2024 Adam Indrigo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
---------------------
Small one-indexed array class for lua, essentially just a wrapper for tables.
Requires gnomekit version of middleclass.

Small example:
local array = Array("object1", "object2")
print(array:len()) -- prints 2
PrintTable(array:toTable()) -- ["object1", "object2"]
print(array:first()) -- first object
print(array:last()) -- last object
print(array:get(3, "default")) -- returns default because there is no third object
print(array:push("object3")) -- puts "object3" in the array
print(array:pop(2)) -- makes table now only "object1" and "object3" and returns "object2"
for i, obj in array:iter(5) do -- array iterator, only allows the first 5 objects (defaults to 1)
    print(i, obj) -- 1, object1
end

indexing set/get works too
]]--

Array = class("Array")

function Array:constructor(...)
    self._tbl = { ... }
end

function Array:len()
    return #self._tbl
end

function Array:toTable()
    return table.Copy(self._tbl)
end

function Array:first()
    return self._tbl[1]
end

function Array:last()
    return self._tbl[self:len()]
end

function Array:get(index, default)
    local val = self._tbl[index]
    return tn(val == nil, default, val)
end

function Array:push(data)
    table.insert(self._tbl, data)
end

function Array:pop(index)
    return table.remove(self._tbl, index)
end

function Array:iter(limit)
    limit = limit or self:len()
    limit = math.Clamp(limit, 1, self:len())
    local i = 1
    return function()
        i = i + 1

        if i <= limit then return i, self:get(i) end
    end
end