-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：mysql.lua
-- 简介：大图书馆Key

local Service = Class('app.service.greatlibrary.key')
local self = nil

-- 依赖
local Model = lroute.require('app.model.greatlibrary.key')
local factory = lroute.require('lib.luant.sql.factory')
local crc32 = lroute.require('lib.crc32')

-- gl_keys
-- id h_type h_key type key created_at updated_at

function Service.init(this)
    self = this
    self.m = Model:new()
end

local function _getFields()
    return {'id', 'type', 'key'}
end

local function _getCondition(t, k)
    condition = {}
    if t then
        condition.h_type = string.crc32(t)
        condition.type = t
    end
    if k then
        condition.h_key = string.crc32(k)
        condition.key = k
    end
    return condition
end

function Service.exist(t, k)
    condition = _getCondition(t, k)
    if self.m.getOne(_getFields(), condition) then
        return true
    else
        return false
    end
end

function Service.add(t, k)
    if not self.exist(t, k) then
        fields = {
            ['h_type'] = string.crc32(t),
            ['h_key'] = string.crc32(k),
            ['type'] = t,
            ['key'] = k,
        }
        return self.m.insert(fields)
    else
        lexception.throw_add_error('纪录已存在')
    end
end

function Service.del(param)
    -- 删除单条
    if param.id then
        condition = {['id']=param.id}
        return self.m.delete(condition)
    end

    -- 删除多条
    condition = _getCondition(param.type, param.key)
    return self.m.delete(condition)
end

function Service.getOne(id)
    fields = _getFields()
    condition = {['id'] = id}
    return self.m.getOne(fields, condition)
end

function Service.get(param)
    -- 单条
    if param.id then
        return self.getOne(param.id)
    end

    -- fields
    local fields = _getFields()
    -- condition
    local condition = _getCondition(param.type, param.key)
    -- append
    local offset = 0
    if param.offset then
        offset = param.offset
    end
    local limit = 1000
    if param.limit then
        limit = param.limit
    end
    local append = {[factory.LIMIT]={offset, limit}}
    
    -- result
    local total = self.m.getCount(condition)
    local res = self.m.getList(fields, condition, append)
    return {
        err_no = 0,
        total = total,
        offset = offset,
        count = #res,
        result = res,
    }
end

function Service.clear()
    if type(self.m.clear) == 'function' then
        self.m.clear()
    end
end

return Service