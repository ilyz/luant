-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：mysql.lua
-- 简介：大图书馆Key

local Model = Class('app.model.greatlibrary.key', 'lib.luant.mysql')

function Model.init(self)
    self.super:init()
    self:setDatabase('great_library')
    self:setTable('gl_keys')
end

return Model