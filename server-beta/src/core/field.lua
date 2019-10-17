local guide    = require 'parser.guide'
local checkSMT = require 'core.setmetatable'

local m = {}

function m:def(source, callback)
    local parent = source.parent
    local key = guide.getKeyName(source)
    self:eachField(parent, key, function (src, mode)
        if mode == 'set' then
            callback(src, mode)
        end
    end)
end

function m:ref(source, callback)
    local parent = source.parent
    local key = guide.getKeyName(source)
    self:eachField(parent, key, function (src, mode)
        if mode == 'set' or mode == 'set' then
            callback(src, mode)
        end
    end)
end

function m:field(source, key, callback)
    self:eachField(source.parent, key, callback)
end

function m:value(source, callback)
    local parent = source.parent
    if parent.type == 'setfield'
    or parent.type == 'tablefield' then
        if parent.value then
            self:eachValue(parent.value, callback)
        end
    end
end

return m