require "luaext"
require "log"
require "commonbase"
require "globalcode"
require "class"

--该文件为所有服务预加载文件

--
DEBUG = true
do
    --非DEBUG版去掉打印
    if not DEBUG then
        printf = function() end
        print = function() end

        --去掉warning
        LOG_WARNING = function() end
    end
end

