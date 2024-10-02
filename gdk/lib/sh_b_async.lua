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

Small note: You cannot use timers and await as they depend on ticks and using await freezes ALL Lua execution until the execution has finished.
]]--

async = async or {}
async.queue = async.queue or {}
async._futureClass = class("AsyncFuture")

function async._futureClass:constructor(func)
    self._func = func
    self._executeCalled = false
    self._thenFuncs = {}
    self._errorFuncs = {}
    self.timeout = 5

    local mt = getmetatable(self)
    function mt:__call(...)
        self:exec(...)
    end

    setmetatable(self, mt)
end

function async._futureClass:_exec(...)
    if self._executeCalled then
        return error("Already called exec!")
    end
    self._executeCalled = true

    local me = self
    local va = ...
    local success, res = pcall(function(f)
        f(function(...)
            me:_success(...)
        end, function(...)
            me:_error(...)
        end, va)
    end, self._func)

    if not success and not self._worked then
        self._worked = false
        self:_error(res)
    end
end

function async._futureClass:exec(...)
    local thr = coroutine.create(self._exec)
    coroutine.resume(thr, self, ...)
end

function async._futureClass:callback(cb)
    table.insert(self._thenFuncs, cb)
end

function async._futureClass:_success(...)
    self.returnValues = { ... }
    self._worked = true
    for _, cb in ipairs(self._thenFuncs) do
        cb(...)
    end
end

function async._futureClass:_error(...)
    self._errorCause = { ... }
    self._worked = false
    for _, cb in ipairs(self._errorFuncs) do
        cb(...)
    end
end

function async._futureClass:error(cb)
    table.insert(self._errorFuncs, cb)
end

function async._futureClass:queue()
    table.insert(async.queue, self)
end

function async._futureClass:await(...)
    self:exec(...)
    local startTime = os.time()
    local timeoutTime = startTime + self.timeout
    while self._worked == nil do
        local ct = os.time()
        if timeoutTime <= ct then
            return "Function did not return in time"
        end
    end

    if self.returnValues then
        return unpack(self.returnValues)
    end
    return self._errorCause
end

function async.timer(seconds)
    return async(function(success, err)
        timer.Simple(seconds, function()
            success()
        end)
    end)
end

local metatable = getmetatable(async) or {}
function metatable:__call(cb)
    return async._futureClass(cb)
end

setmetatable(async, metatable)
