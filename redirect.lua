local red = rc.newRedisConn(redisSockFile)

-- 获取长url
url , err = red:get(ngx.var.uri)
if url == ngx.null or not url then
	url = defaultUrl
end

-- 跳转
ngx.redirect(url , 302)

