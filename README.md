## 短地址服务

* Tengine v2.1.2 ( Openresty , Nginx 亦可) 
* Redis v3.2.5
* Centos 6.5

## 关键配置. 

* Redis

```
unixsocket /data/logs/redis_logs/redis.sock
port 0
```

* Tengine

``` 
vhostdomain.conf :

    location / {
        rewrite_by_lua_file  /path_to_basedir_of_shorturl/redirect.lua;
    }
    location /shorturl {
        content_by_lua_file /path_to_basedir_of_shorturl/create_shorturl.lua;
    }

```

```
nginx.conf : 
    lua_package_path "/path_to_basedir_of_shorturl/lualibs/?.lua;;";
    init_by_lua_file /path_to_basedir_of_shorturl/init.lua ;	
```
	
