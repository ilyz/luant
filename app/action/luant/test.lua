-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：test.lua
-- 简介：luant测试类

local Test = Class('app.action.luant.test')

function Test.hello(self, request)
    local name = request.get_arg('name')
    if not name then
       name = 'luant'
    end
    return 'hello ' .. name
end

return Test