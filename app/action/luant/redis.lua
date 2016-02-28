-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：redis.lua
-- 简介：redis测试类

local _M = Class('app.action.luant.test')

--依赖
local Redis = lroute.require('lib.resty.redis')
local strfromat = string.format
local tostring = tostring

function _M.init(self)
    self.r = Redis:new()
end

function _M.connect(self)
    if not self.r then
        self.r = Redis:new()
    end
    self.r:set_timeout(1000)
    local ok, err = self.r:connect("127.0.0.1", 19000)
    if not ok then
        err_msg = strfromat("failed to connect: err_msg[%s]", tostring(err))
        lexception.throw(err_msg)
    end
end

function _M.get(self, request)
    self:connect()
    local key = request:assert_get('key')
    local res, err = self.r:get(key)
    if not res then
        err_msg = strfromat("failed to get key[%s]: err_msg[%s]", tostring(key), tostring(err))
        lexception.throw(err_msg)
    end
    return res    
end

function _M.set(self, request)
    self:connect()
    local key = request:assert_get('key')
    local val = request:assert_get('val')
    local res, err = self.r:set(key, val)
    if not res then
        err_msg = strfromat("failed to set key[%s] val[%s]: err_msg[%s]", tostring(key), tostring(val), tostring(err))
        lexception.throw(err_msg)
    end
end

function _M.del(self, request)
    self:connect()
    local key = request:assert_get('key')
    local res, err = self.r:del(key)
    if not res then
        err_msg = strfromat("failed to del key[%s]: err_msg[%s]", tostring(key), tostring(err))
        lexception.throw(err_msg)
    end
    return res
end

function _M.clear(self)
    if not self.r then
        self.r:set_keepalive(180000, 100)
        self.r = nil
    end
end

return _M