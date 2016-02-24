## Luant
### 1 简介

Luant是一个基于Nginx与Lua的高性能Web开发框架，其内部集成了大量精良的开源Lua库并对部分库进行封装和扩充。基于Luant可以便捷的搭建高并发高性能高扩展的Web服务。

Luant通过汇聚各种设计精良的Nginx模块(主要来自开源社区)，封装实现了路由、缓存、异常、SQL组装、单测、自动构建等通用业务需求，致力于让Nginx成为一个强大好用的web应用平台。

Luant的目标是充分利用Nginx的高并发处理能力和[OpenResty](https://openresty.org/cn/)等开源社区资源，提供一个好用的高性能MVC数据下发框架。


目前，Luant作为[绿茶浏览器](http://browser.lenovo.com/)的数据下发框架，后续会持续改进，欢迎大家共同参与或转载。

### 2 安装

#### 2.1 Nginx

* [Nginx源码安装](http://www.jianshu.com/p/3065c07b69e6)

#### 2.2 Luant

* 下载

  ```
  git clone https://github.com/ilyz/luant.git
  ```

* 添加Nginx配置

 
  ```
  # package path
  lua_package_path '/data/greentea/luant/?.lua;/data/greentea/luant/lib/?.lua';
  lua_package_cpath '/data/greentea/luant/lib/?.so';
 	
  # init luant
  init_by_lua_file '/data/greentea/luant/public/init.lua';
  
  server {
      listen 80;
      server_name  lua.ilyz.me;
      port_in_redirect off;
      index index.lua;
      
      # 跨域
      add_header     'Access-Control-Allow-Origin' '*';
      add_header     'Access-Control-Allow-Headers' 'Content-Type, X-Auth-Token, Origin';
      add_header     'Access-Control-Allow-Methods' 'POST, GET, OPTIONS, PUT, DELETE';

      # gzip
      gzip on;
      gzip_min_length  2000;
      gzip_proxied     any;
      gzip_types       application/json;

      error_page   404              /404.html;
      error_page   500 502 503 504  /50x.html;

      # 日志
      access_log  log/lua_ilyz_me.access.log  main;
      error_log  log/lua_ilyz_me.error.log;
      
      # 单测报告
      location = /test/report.txt {
          root /data/greentea/luant;
          default_type 'text/plain';
          break;
      }

      # 代码覆盖率
      location ~ ^/test/cove/ {
          root /data/greentea/luant;
          default_type 'text/plain';
          break;
      }
        
      location / {
          default_type text/html;
          content_by_lua_file '/data/greentea/luant/public/index.lua';
          # lua_code_cache off;
      }
  }
  ```

* 重启Nginx

  ```
  sudo /data/software/sbin/nginx -s reload
  ```

* 测试

  ```
  http://lua.ilyz.me/luant/test/hello?name=jack
  ```

### 3 上手

#### 3.1 目录结构

* luant
* |----app（项目）
* |--------action
* |------------project1
* |----------------class1.lua
* |--------service
* |------------project1
* |----------------class1.lua
* |--------model
* |------------project1
* |----------------class1.lua
* |--------config
* |------------mysql.lua
* |------------redis.lua
* |----lib（常用库）
* |--------luant（luant库）
* |------------sql（SQL组装）
* |----------------assemble.lua
* |----------------factory.lua
* |----------------statement.lua
* |------------sys（系统工具类）
* |----------------class.lua
* |----------------json.lua
* |----------------string.lua
* |----------------table.lua
* |------------mysql.lua（mysql接口封装）
* |----public
* |--------core（luant核心库）
* |------------cache.lua（缓存）
* |------------exception.lua（常见异常）
* |------------request.lua（Request封装）
* |------------route.lua（路由）
* |--------index.lua（入口）
* |--------init.lua（全局初始化）
* |----test（单元测试）
* |--------code（单测代码，同luant目录结构）
* |------------app
* |------------lib
* |------------public
* |--------script（脚本，用于构建单测自动化）
* |------------build.lua（构建单测）
* |------------test_head.lua（单测环境初始化）
* |--------cove（代码覆盖率，build构建，同luant目录结构）
* |--------report.txt（单测结果，build构建）
* |----README.md

其中，开发者主要需要关注如下目录：

  ```
  app/action：控制层，用于提供http接口
  app/service：服务层，用于提供具体业务的原子操作及组装
  app/model：数据层，用于提供数据的基本操作
  app/config：存放与业务相关的配置，如：mysql.lua、redis.lua
  ```

#### 3.2 全局变量

luant在初始化时，定义了几个常用的工具，可直接使用，无需require。参见如下：

* CLass，类定义。[源码](https://github.com/ilyz/luant/blob/master/lib/luant/sys/class.lua)，[单测](https://github.com/ilyz/luant/blob/master/test/code/lib/luant/sys/class.lua)
  
  ```
  -- 类定义
  local c = Class('path')
  
  -- 继承
  -- 继承于类路径：
  local c = Class('path', 'parent_path')
  -- 继承于类对象：
  local p = require('parent_path')
  local c = Class('path', p)
  ```
  
* table，系统table扩充。[源码](https://github.com/ilyz/luant/blob/master/lib/luant/sys/table.lua)，[单测](https://github.com/ilyz/luant/blob/master/test/code/lib/luant/sys/table.lua)

  ```
  table.method(param)
  ```

* string，系统string扩充。[源码](https://github.com/ilyz/luant/blob/master/lib/luant/sys/string.lua)，[单测](https://github.com/ilyz/luant/blob/master/test/code/lib/luant/sys/string.lua)

  ```
  string.method(param)
  ```

* json，cjson的封装。[源码](https://github.com/ilyz/luant/blob/master/lib/luant/sys/json.lua)，[单测](https://github.com/ilyz/luant/blob/master/test/code/lib/luant/sys/json.lua)

  ```
  -- json encode
  local str = json.json_encode({"a"})
  -- json decode
  local items = json.json_decode('{"a","b"}')
  ```

* lcache，缓存。[源码](https://github.com/ilyz/luant/blob/master/public/core/cache.lua)
  
  ```
  -- lcache创建于nginx启动|重启时，位于nginx工作进程里，每个工作进程一份数据，工作进程之间相互独立，
  -- 缓存文件(route)
  lcache.setC(k, v)
  lcache.getC(k, d_v)
  lcache.delC(k)
  -- 缓存数据
  lcache.setD(k, v)
  lcache.getD(k, d_v)
  lcache.delD(k)
  ```
  
* lroute，路由。[源码](https://github.com/ilyz/luant/blob/master/public/core/route.lua)
  
  ```
  -- lroute实现了从uri到action的路由功能，并提供了luant各种文件的读取方法
  lroute.method(param)
  ```

* lexception，常见异常封装。[源码](https://github.com/ilyz/luant/blob/master/lib/luant/sys/exception.lua)
  
  ```
  lexception.method(param)
  ```
  
#### 3.3 单元测试

1. 环境搭建

   * [luarocks](https://luarocks.org/#quick-start)
   * [busted](http://olivinelabs.com/busted/)
     
     ```
     sudo luarocks install busted
     ```
   * [luacov](http://keplerproject.github.io/luacov/index.html#instructions)
     
     ```
     sudo luarocks install luacov
     ```

2. 构建

   ```
   cd /data/greentea/luant/test/script/
   python build.py
   ```
   
3. 构建结果

	* [单测报告](http://lua.ilyz.me/test/report.txt)
	* [代码覆盖率](http://lua.ilyz.me/test/cove/lib/luant/sys/table.lua)

4. 自动构建

	监听git库push事件，执行python脚本，检测单测结果，实时报警。

#### 3.4 性能测试

1. **阿里云测试**

	| 测试对象           | 最大并发数 | 平均访问时间 | 错误率 |
	| ---------------- |:---------:| ----------:| ----: |
	| Nginx            |   8672    |   84.96    | 0.00% |
	| Lua框架           |   6435    |   77.35    | 0.00% |
	| PHP框架           |   5644    |   117.7    | 0.00% |
	| LUA大图书管数据读取 |   6970    |   93.34    | 0.01% | 
	| PHP大图书管数据读取 |   2441    |   705.63   | 0.00% |


	```
备注：
	服务器：8核、64G
	压测机器：阿里云测试免费版(曾用收费版压测过nginx，最大并发数可以超过6W+)
	压测并不是同时进行的，所以数据会存在系统误差。
	```

### 4 站在巨人的肩膀上

luant在开发过程中借鉴了大量社区资源，在此感谢(排名不分先后)：

* [OpenResty](https://openresty.org/cn/)
* [Busted](http://olivinelabs.com/busted/)
* [LuaCov](http://keplerproject.github.io/luacov/)
* [luarocks](https://luarocks.org/#quick-start)
* [luastar](https://github.com/luastar/luastar/tree/master)
* [lua-crc32](https://github.com/lancelijade/qqwry.lua/blob/master/crc32.lua)

#### 后续计划

* Redis接入
* 自动构建与监控


