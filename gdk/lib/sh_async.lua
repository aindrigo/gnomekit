--[[
Copyright 2024 Adam Indrigo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
---------------------
Small async library for GLua.
Requires middleclass library.

Small example:
local fun = async(function(result)
    print(result)
end)
]]--

async = async or {}
async.queue = async.queue or {}
async._funcClass = middleclass("AsyncFunction")

function async._funcClass:initialize(func)
    self._func = func
    self._executeCalled = false
    self._thenFuncs = {}
    self._errorFuncs = {}
end

function async._funcClass:_exec(...)
    if self._executeCalled then
        return error("Already called exec!")
    end

    self._executeCalled = true
    local success, res = pcall(self._func, self._success, self._error, ...)
    if not success and not self._worked then
        self._worked = false
        self:_error(res)
    end
end

function async._funcClass:then(cb)
    table.insert(self._thenFuncs, cb)
end

function async._funcClass:_success(...)
    self.returnValues = { ... }
    self._worked = true
    for _, cb in ipairs(self._thenFuncs) do
        cb(...)
    end
end

function async._funcClass:_error(...)s
    self._errorCause = { ... }
    self._worked = false
    for _, cb in ipairs(self._errorFuncs) do
        cb(...)
    end
end

function async._funcClass:error(cb)
    table.insert(self._errorFuncs, cb)
end

function async._funcClass:queue()
    table.insert(async.queue, self)
end

function async._funcClass:await(...)
    self:_exec(...)
    while self._worked == nil do
        -- nothing
    end

    return tn(self.returnValues, unpack(self.returnValues), self._errorCause)
end

metatable = getmetatable(async)
function metatable:__call(cb)
    return async._funcClass:new(cb)
end
