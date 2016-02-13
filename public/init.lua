-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：init.lua
-- 简介：全局初始化
-- 功能：初始化luant框架常用模块
-- 使用：在nginx http中添加：init_by_lua_file '${luant_PATH}/public/init.lua';

-- 文件全局缓存
LUANT_C = {}

-- 数据全局缓存
LUANT_D = {}

-- 环境相关
-- 开发环境
DEBUG = true
-- 单元测试环境
-- UNIT_TEST = false

-- 系统功能
Class = require("lib.luant.sys.class")
string = require('lib.luant.sys.string')
table = require('lib.luant.sys.table')
json = require('lib.luant.sys.json')

-- luant核心库
lcache = require("public.core.cache")
lroute = require("public.core.route")
lexception = require("public.core.exception")