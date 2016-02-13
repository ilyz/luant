-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：mysql.lua
-- 简介：mysql访问类
-- 功能：mysql增、删、改、查、SQL

-- Mysql 操作类
local Mysql = Class('lib.luant.mysql')
local self = nil

-- 依赖
local mysql = lroute.require('lib.resty.mysql')
local configs = lroute.require('app.config.mysql')
local assemble = lroute.require('lib.luant.sql.assemble')
local factory = lroute.require('lib.luant.sql.factory')

-- 获取resty/mysql连接配置
local function _getConnectConf(config)
	return {
		host = config.host,
		port = config.port,
		path = config.path,
		user = config.user,
		password = config.password,
		database = config.database,
		max_packet_size = 100000000,
	}
end

local function _connect(db, conf)
	return db:connect(conf)
end

local function _close(db)
	return db:close()
end

local function _query(db, sql)
	return db:query(sql)
end

-- 初始化
function Mysql.init(this)
	self = this
	self.configs = configs
	self.db = nil
	self.conf = {}
	self.selectConf('default')
end

-- 选择数据库配置信息
function Mysql.selectConf(node)
	if self.configs[node] then
		config = self.configs[node]
		self.conf = _getConnectConf(config)
	end
	return self.conf
end

-- 设置数据库配置信息
function Mysql.setConf(t)
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
		self.clear()
	end
	return self.conf
end

-- 连接
function Mysql.connect()
	if not self.db then
		self.db = mysql:new()
		return self.db:connect(self.conf)
	end
end

-- 清理
function Mysql.clear()
	if self.db then
		self.db:close()
		self.db = nil
	end
end

function Mysql.setHost(h)
	if string.is_noempty_string(h) then 
		self.conf.host = h
		self.clear()
	end
	return self.conf
end

function Mysql.setPort(p)
	if type(p) == 'number' then
		self.conf.port = p
		self.clear()
	end
	return self.conf
end

function Mysql.setPath(p)
	if string.is_noempty_string(p) then
		self.conf.path = p
	end
	return self.conf
end

function Mysql.setUser(u)
	if string.is_noempty_string(u) then
		self.conf.user = u
		self.clear()
	end
	return self.conf
end

function Mysql.setPassword(p)
	if string.is_string(p) then
		self.conf.password = p
		self.clear()
	end
	return self.conf
end

function Mysql.setDatabase(d)
	if string.is_noempty_string(d) then 
		self.conf.database = d
		self.clear()
	end
	return self.conf
end

function Mysql.setTable(t)
	if string.is_noempty_string(t) then
		self.conf.table = t
	end
	return self.conf
end

-- 配置信息抽象，用于分库分表
function Mysql.getTable()
	return self.conf.table
end

function Mysql.getDatabase()
	return self.conf.database
end

-- insert
function Mysql.insert(fields)
	sql = assemble.insert(self.getDatabase(), self.getTable(), fields)
	return self.execute(sql)
end

-- delete
function Mysql.delete(condition)
	sql = assemble.delete(self.getDatabase(), self.getTable(), condition)
	return self.execute(sql)
end

-- update
function Mysql.update(fields, condition, append)
	sql = assemble.update(self.getDatabase(), self.getTable(), fields, condition, append)
	return self.execute(sql)
end

-- getOne
function Mysql.getOne(fields, condition, append)
	if not append then
		append = {[factory.LIMIT] = 1}
	end
	sql = assemble.select(self.getDatabase(), self.getTable(), fields, condition, append)
	-- ngx.say(sql)
	res = self.execute(sql)
	if #res >= 1 then
		return res[1]
	else
		return nil
	end
end

-- getList
function Mysql.getList(fields, condition, append)
	sql = assemble.select(self.getDatabase(), self.getTable(), fields, condition, append)
	return self.execute(sql)
end

-- getCount
function Mysql.getCount(condition, append)
	fields = {'count(*) AS num'}
	sql = assemble.select(self.getDatabase(), self.getTable(), fields, condition)
	res = self.execute(sql)
	if res then
		return tonumber(res[1]['num'])
	end
end

-- 执行SQL
function Mysql.query(sql)
	return self.execute(sql)
end

-- 执行SQL
function Mysql.execute(sql)
	self.connect()
	res, err = self.db:query(sql)
	if res then
		return res
	else
		lexception.throw_sql_error(sql, err)
	end
end

return Mysql 