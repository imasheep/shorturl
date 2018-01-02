require 'convert'
rc = require 'redisconn'


-- 短地址服务域名
shortDomain="davmm.com"

-- 链接redis的sock文件
redisSockFile="/data/logs/redis_logs/redis.sock3"

-- 短地址服务uri最大长度, 超过后重新计数, 从/1 开始
maxSurlLen=2

-- redis 自增键名
sIndexKey="sindex"

-- 默认跳转链接 
defaultUrl="http://www.baidu.com"