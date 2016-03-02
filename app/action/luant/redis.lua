-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：redis.lua
-- 简介：redis测试类

local _M = Class('app.action.luant.test')

--依赖
local Redis = lroute.require('lib.luant.cache.redis')

function _M.init(self)
    self.r = Redis:new()
    self.r:set_save_keys(true)
end

function _M.get(self, request)
    local key = request:assert_get('key')
    return self.r:get(key)
end

function _M.set(self, request)
    local key = request:assert_get('key')
    local val = request:assert_get('val')
    local seconds = request:get_arg('life_time')
    return self.r:set(key, val, seconds)
end

function _M.del(self, request)
    local key = request:assert_get('key')
    return self.r:del(key)
end

function _M.clear(self)
    self.r:clear()
end

function _M.keys(self, request)
    return self.r:keys()
end

function _M.flushdb(self)
    return self.r:flushdb()
end

function _M.flushall(self)
    return self.r:flushall()
end

function _M.flushtable(self)
    return self.r:flushtable()
end

function _M.tkeys(self)
    return self.r:tkeys()
end

return _M