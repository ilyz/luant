-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：redis.lua
-- 简介：redis工具类

local _M = Class('lib.luant.cache.redis')

--依赖
local redis = lroute.require('lib.resty.redis')
local random = lroute.require('lib.resty.random')
local rannum = random.number
local configs = lroute.require('app.config.redis')

local strfromat = string.format
local tostring = tostring

function _M.init(self)
    -- 是否需要保留key信息
    self.save_keys = false

    -- 默认超时
    self.timeout = 1000
    
    -- 配置信息
    self.confs = configs

    -- 数据库信息
    self.database = 'test'
    self.table = 'test'
end

local function _gkey(self, key)
    local k = self.database .. ':' .. self.table
    if key then 
        k = k .. ':' .. key
    end
    return k
end

local function _add_table_key(self, key)
    if self.save_keys then
        self.r:sadd(_gkey(self), key)
    end
end

local function _rem_table_key(self, key)
    if self.save_keys then
        self.r:srem(_gkey(self), key)
    end
end

local function _connect(self)
    if not self.r then
        self.r = redis:new()

        -- redis连接：随机轮询
        self.r:set_timeout(self.timeout)
        local size = #self.confs
        local start = rannum(1, size)
        for i = start, size + start - 1, 1 do
            local pos = (i % size) + 1
            local conf = self.confs[pos]
            local ok, err = self.r:connect(conf.host, conf.port)
            if ok then
                return ok
            end
        end
    end
end

function _M.connect(self)
    if not self.r then
        self.r = redis:new()

        -- redis连接：随机轮询
        self.r:set_timeout(self.timeout)
        local size = #self.confs
        local start = rannum(1, size)
        for i = start, size + start - 1, 1 do
            local pos = (i % size) + 1
            local conf = self.confs[pos]
            local ok, err = self.r:connect(conf.host, conf.port)
            if ok then
                return ok
            end
        end
    end
end

-- API
function _M.get(self, key)
    _connect(self)
    return self.r:get(_gkey(self, key))
end

function _M.set(self, key, val, seconds)
    _connect(self)
    _add_table_key(self, key)
    if seconds then
        return self.r:setex(_gkey(self, key), seconds, val)
    else
        return self.r:set(_gkey(self, key), val)
    end 
end

function _M.del(self, key)
    _connect(self)
    _rem_table_key(self, key)
    return self.r:del(_gkey(self, key))
end

function _M.tkeys(self)
    _connect(self)
    return self.r:smembers(_gkey(self))
end

-- 其它控制接口
function _M.clear(self)
    if not self.r then
        self.r:set_keepalive(180000, 100)
        self.r = nil
    end
end

function _M.flushtable(self)
    if self.save_keys then
        local t_keys = self:tkeys()
        for k, v in pairs(t_keys) do
            self:del(v)
        end
        self:del(nil)
    end
end

-- 状态设置
function _M.set_database(self, database)
    self.database = database
end

function _M.set_table(self, table)
    self.table = table
end

function _M.set_save_keys(self, is_save_keys)
    self.save_keys = is_save_keys
end

-- 测试时用的接口
-- codis不支持以下接口
function _M.keys(self)
    self:connect()
    return self.r:keys('*')
end

function _M.flushdb(self)
    self:connect()
    return self.r:flushdb()
end

function _M.flushall(self)
    self:connect()
    return self.r:flushall()
end

return _M