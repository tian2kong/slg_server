local redis = require "redis"

--连接redis
local db = redis.connect{
	host = "", --地址
	port = , --端口
	auth = , --密码
}

--通用命令 更多接口请查看redis文档
db:[command](...)

--例如 以下常用接口：

--断开连接
db:disconnect()

--redis管道使用例子
local ops = {
    {"set", "abc", 1111},
    {"get", "abc"},
}
local resp = {}
db:pipeline(ops, resp)
--调用成功后：
resp = {
    [1] = {
        ["ok"] = true
        ["out"] = "OK"
    }
    [2] = {
        ["ok"] = true
        ["out"] = "1111"
    }
}

--------------------------事务命令---------------------------------------------
--标记一个事务块的开始
db:multi()

--执行所有事务块内的命令
db:exec()

--取消事务，放弃执行事务块内的所有命令
db:discard()


--------------------------key操作---------------------------------------------
--该命令用于在 key 存在时删除 key
db:del(key)

--检查给定 key 是否存在
db:exists(key)


--------------------------字符串操作---------------------------------------------
--设置指定 key 的值
db:set(key, value)

--获取指定 key 的值。
db:get(key)


--------------------------哈希表操作---------------------------------------------
--同时将多个 field-value (域-值)对设置到哈希表 key 中。
db:hmset(key, field1, value1, ...)

--获取所有给定字段的值
db:hmget(key, field1, ...)

--将哈希表 key 中的字段 field 的值设为 value 。
db:hset(key, field1, value1)

--获取存储在哈希表中指定字段的值。
db:hget(key, field1)

--获取在哈希表中指定 key 的所有字段和值
db:hgetall(key)


--------------------------列表操作---------------------------------------------
--将一个或多个值插入到列表头部
db:lpush(key, value1, ...)

--移出并获取列表的第一个元素
db:lpop(key)

--获取列表指定范围内的元素
db:lrange(key, start, stop)


--------------------------集合操作---------------------------------------------
--向集合添加一个或多个成员
db:sadd(key, member1, ...)

--返回集合中的所有成员
db:smembers(key)

--判断 member 元素是否是集合 key 的成员
db:sismembers(key, member)


--------------------------有序集合操作---------------------------------------------
--向有序集合添加一个或多个成员，或者更新已存在成员的分数
db:zadd(key, score1, member1, ...)

--通过索引区间返回有序集合成指定区间内的成员
db:zrange(key, start, stop, [WITHSCORES])

--返回有序集中指定区间内的成员，通过索引，分数从高到底
db:zrevrange(key, start, stop, [WITHSCORES])

--返回有序集合中指定成员的索引
db:zrank(key, member)

--返回有序集合中指定成员的排名，有序集成员按分数值递减(从大到小)排序
db:zrevrank(key, member)

--返回有序集中，成员的分数值
db:zscore(key, member)

--计算在有序集合中指定区间分数的成员数
db:zcount(key, min, max)

--获取有序集合的成员数
db:zcard(key)


--------------------------订阅操作---------------------------------------------
local watcher = redis.watch{
	host = "", --地址
	port = , --端口
	auth = , --密码
}

--订阅给定的一个或多个频道的信息
watcher:subscribe(channel1, ...)

--退订给定的频道
watcher:unsubscribe(channel1, ...)

--订阅一个或多个符合给定模式的频道
watcher:psubscribe(pattern1, ...)

--退订所有给定模式的频道
watcher:punsubscribe(pattern1, ...)

--断开连接
watcher:disconnect()

--监听ai 返回订阅消息
watcher:message()
