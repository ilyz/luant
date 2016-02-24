-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：mysql.lua
-- 简介：mysql访问类
-- 功能：mysql增、删、改、查、SQL

-- Mysql 操作类
local Mysql = Class('lib.luant.mysql')

-- 依赖
local mysql = lroute.require('lib.resty.mysql')
local configs = lroute.require('app.config.mysql')
local assemble = lroute.require('lib.luant.sql.assemble')
local factory = lroute.require('lib.luant.sql.factory')
local type = type

-- 获取resty/mysql连接配置
local function _getConnectConf(config)
	return {
		host = config.host,
		port = config.port,
		path = config.path,
		user = config.user,
		password = config.password,
		database = config.database,
		max_packet_size = 10 * 1024 * 1024, --默认返回结果最大为10M 
	}
end

-- 初始化
function Mysql.init(self)
	self.db = nil
	self.conf = {}
	self:selectConf('default')
end

-- 选择数据库配置信息
function Mysql.selectConf(self, node)
	if configs[node] then
		config = configs[node]
		-- 读取数据库连接配置
		self.conf = _getConnectConf(config)
		-- 读取其他配置
		if config.pool_max_idle_time then
			self.pool_max_idle_time = config.pool_max_idle_time
		else
			self.pool_max_idle_time = 180000
		end
		if config.pool_size then
			self.pool_size = config.pool_size
		else
			self.pool_size = 100
		end
	end
end

-- 设置数据库配置信息
function Mysql.setConf(self, t)
	if type(t) == 'table' then 
		if t.host then
			self.conf.host = t.host
		end
		if t.port then
			self.conf.port = t.port
		end
		if t.user then
			self.conf.user = t.user
		end
		if t.password then
			self.conf.password = t.password
		end
		if t.database then
			self.conf.database = t.database
		end
		if t.path then
			self.conf.path = t.path
		end
		if t.max_packet_size then
			self.conf.max_packet_size = t.max_packet_size
		end
	end
	return self.conf
end

-- 连接
function Mysql.connect(self)
	if not self.db then
		self.db = mysql:new()
		return self.db:connect(self.conf)
	end
end

-- 释放资源到连接池
function Mysql.clear(self)
	if self.db then
		local ok, err = self.db:set_keepalive(self.pool_max_idle_time, self.pool_size)
		self.db = nil
		if not ok then
			ngx.say("set keepalive error: ", err)
			ngx.exit(1)
		end
	end
end

-- 关闭连接
function Mysql.close(self)
	if self.db then
		local ok, err = self.db:close()
		self.db = nil
		if not ok then
			ngx.say("close error: ", err)
			ngx.exit(1)
		end
	end
end

function Mysql.setHost(self, h)
	if string.is_noempty_string(h) then 
		self.conf.host = h
	end
	return self.conf
end

function Mysql.setPort(self, p)
	if type(p) == 'number' then
		self.conf.port = p
	end
	return self.conf
end

function Mysql.setPath(self, p)
	if string.is_noempty_string(p) then
		self.conf.path = p
	end
	return self.conf
end

function Mysql.setUser(self, u)
	if string.is_noempty_string(u) then
		self.conf.user = u
	end
	return self.conf
end

function Mysql.setPassword(self, p)
	if string.is_string(p) then
		self.conf.password = p
	end
	return self.conf
end

function Mysql.setDatabase(self, d)
	if string.is_noempty_string(d) then 
		self.conf.database = d
	end
	return self.conf
end

function Mysql.setTable(self, t)
	if string.is_noempty_string(t) then
		self.conf.table = t
	end
	return self.conf
end

function Mysql.setMaxPacketSize(self, s)
	if type(t) == 'number' then
		self.conf.max_packet_size = s
	end
	return self.conf
end

-- 配置信息抽象，用于分库分表
function Mysql.getTable(self)
	return self.conf.table
end

function Mysql.getDatabase(self)
	return self.conf.database
end

-- insert
function Mysql.insert(self, fields)
	local sql = assemble.insert(self:getDatabase(), self:getTable(), fields)
	return self:execute(sql)
end

-- delete
function Mysql.delete(self, condition)
	local sql = assemble.delete(self:getDatabase(), self:getTable(), condition)
	return self:execute(sql)
end

-- update
function Mysql.update(self, fields, condition, append)
	local sql = assemble.update(self:getDatabase(), self:getTable(), fields, condition, append)
	return self:execute(sql)
end

-- getOne
function Mysql.getOne(self, fields, condition, append)
	if not append then
		append = {[factory.LIMIT] = 1}
	end
	local sql = assemble.select(self:getDatabase(), self:getTable(), fields, condition, append)
	-- ngx.say(sql)
	local res = self:execute(sql)
	if #res >= 1 then
		return res[1]
	else
		return nil
	end
end

-- getList
function Mysql.getList(self, fields, condition, append)
	local sql = assemble.select(self:getDatabase(), self:getTable(), fields, condition, append)
	return self:execute(sql)
end

-- getCount
function Mysql.getCount(self, condition, append)
	local fields = {'count(*) AS num'}
	local sql = assemble.select(self:getDatabase(), self:getTable(), fields, condition)
	local res = self:execute(sql)
	return tonumber(res[1]['num'])
end

-- 执行SQL
function Mysql.query(self, sql)
	return self:execute(sql)
end

-- 执行SQL
function Mysql.execute(self, sql)
	self:connect()
	local res, err = self.db:query(sql)
	if res then
		return res
	else
		lexception.throw_sql_error(sql, err)
	end
end

-- keep alive
function Mysql.set_keepalive(self, ...)
	return self.db:set_keepalive(...)
end

-- timeout
function Mysql.set_timeout(self, t)
	return self.db:set_timeout(t)
end

return Mysql 