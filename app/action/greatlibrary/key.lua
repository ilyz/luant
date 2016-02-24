-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：mysql.lua
-- 简介：大图书馆Key

local Key = Class('app.action.greatlibrary.key')

-- 依赖
local Service = lroute.require('app.service.greatlibrary.key')
local type = type

function Key.init(self)
    self.s = Service:new()
end

function Key.exist(self, request)
    t = request:assert_get_str('type')
    k = request:assert_get_str('key')
    return self.s:exist(t, k)
end

function Key.get(self, request)
    param = request:get_args({'id', 'type', 'key'})
    return self.s:get(param)
end

function Key.add(self, request)
    t = request:assert_get_str('type')
    k = request:assert_get_str('key')
    return self.s:add(t, k)
end

function Key.del(self, request)
    param = request:get_args({'id', 'type', 'key'})
    return self.s:del(param)
end

function Key.clear(self)
    if type(self.s.clear) == 'function' then
        self.s:clear()
    end
end

return Key