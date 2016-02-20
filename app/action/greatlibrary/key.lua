-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：mysql.lua
-- 简介：大图书馆Key

local Key = Class('app.action.greatlibrary.key')
local self = nil

-- 依赖
local Service = lroute.require('app.service.greatlibrary.key')

function Key.init(this)
    self = this
    self.s = Service:new()
end

function Key.exist(request)
    t = request.args.type
    k = request.args.key
    return self.s.exist(t, k)
end

function Key.get(request)
    param = table.select(request.args, {'id', 'type', 'key'})
    return self.s.get(param)
end

function Key.add(request)
    t = request.args.type
    k = request.args.key
    return self.s.add(t, k)
end

function Key.del(request)
    param = table.select(request.args, {'id', 'type', 'key'})
    return self.s.del(param)
end

function Key.clear()
    -- if self.s then
    --     if type(self.s.clear) == 'function' then
    --         self.s.clear()
    --     end
    -- end
end

return Key