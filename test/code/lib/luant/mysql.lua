-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：mysql.lua
-- 简介：lib.luant.mysql单元测试

describe("test.code.lib.luant.mysql", function()

  -- 测试数据库
  -- 数据表：`test`.`mysql_unittest`
  -- 字段：s1、n1

  -- 数据库配置信息
  local conf = {
    db = {
      host = '127.0.0.1',
      port = 3306,
      user = 'root',
      password = '',
      database = 'test',
      table = 'mysql_unittest',
    }
  }

  local create_sql = string.format([[
    CREATE TABLE IF NOT EXISTS `%s`.`%s` (
      `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
      `s1` varchar(63) NOT NULL DEFAULT '', 
      `n1` varchar(63) NOT NULL DEFAULT '',
      `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
      `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
  ]], conf.db.database, conf.db.table)

  local drop_sql = string.format('DROP TABLE IF EXISTS`%s`.`%s`;', conf.db.database, conf.db.table)

  local Mysql = require('lib.luant.mysql')
  local db = Mysql:new()

  -- 测试初始化功能
  describe('init', function()
    -- 重置配置信息
    it("setConf", function()
      res = db.setConf(conf.db)
      assert.are.same(res.host, conf.db.host)
      assert.are.same(res.port, conf.db.port)
      assert.are.same(res.user, conf.db.user)
      assert.are.same(res.password, conf.db.password)
      assert.are.same(res.database, conf.db.database)
    end)
  end)

end)