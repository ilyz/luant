-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：mysql.lua
-- 简介：luant 数据库配置

local _M = {}

-- 单元测试环境
_M.test = {
	host = '127.0.0.1',
	port = 3306,
	user = 'root',
	password = '',
	database = 'unit_test',
}

-- 默认环境
_M.default = {
	host = '127.0.0.1',
	port = 3306,
	user = 'root',
	password = '',
	database = 'gt_data',
	-- 连接超时时间，3分钟
	pool_max_idle_time = 180000,
	-- 连接池大小，每个工作进程100个
	pool_size = 100,
}

-- 结点
_M.node2 = {
	host = '127.0.0.1',
	port = 3306,
	user = 'root',
	password = '',
	database = 'gt_data',
}

return _M