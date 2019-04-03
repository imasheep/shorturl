require 'convert'
rc = require 'redisconn'
cjson = require 'cjson'
md5 = require 'md5'



-- 短地址服务域名
shortDomain="ysxa.cn"

-- 链接redis的sock文件
redisSockFile="/data/logs/redis_logs/redis.sock"

-- 短地址服务uri最大长度, 超过后重新计数, 从/1 开始
maxSurlLen=6

-- redis 自增键名
-- 持久
sIndexKeyEver="INDEX:SHORTURL:EVER"
-- 非持久
sIndexKeyTemp="INDEX:SHORTURL:TEMP"

-- redis 自增键最大值
sIndexMax=40000000

-- 默认跳转链接 
defaultUrl="https://www.yunshuxie.com"

-- 签名salt
signSalt="mengmengda"