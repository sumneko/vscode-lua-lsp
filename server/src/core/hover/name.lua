return function (source)
    local value = source:bindValue()
    if not value then
        return ''
    end
    local func = value:getFunction()
    local declarat
    if func and func.source then
        declarat = func.source.name
    else
        declarat = source
    end
    if not declarat then
        -- 如果声明者没有给名字，则找一个合适的名字
        local name = value:eachInfo(function (info)
            if info.type == 'local' or info.type == 'set' or info.type == 'return' then
                if info.source.type == 'name' and info.source.uri == value.uri then
                    return info.source[1]
                end
            end
        end)
        return name or ''
    end

    local key
    if declarat:get 'simple' then
        local simple = declarat:get 'simple'
        local chars = {}
        for i, obj in ipairs(simple) do
            if obj.type == 'name' then
                chars[i] = obj[1]
            elseif obj.type == 'index' then
                chars[i] = '[?]'
            elseif obj.type == 'call' then
                chars[i] = '(?)'
            elseif obj.type == ':' then
                chars[i] = ':'
            elseif obj.type == '.' then
                chars[i] = '.'
            else
                chars[i] = '*' .. obj.type
            end
            if obj == declarat then
                break
            end
        end
        key = table.concat(chars)
    elseif declarat.type == 'name' then
        key = declarat[1]
    elseif declarat.type == 'string' then
        key = ('%q'):format(declarat[1])
    elseif declarat.type == 'number' or declarat.type == 'boolean' then
        key = tostring(declarat[1])
    elseif declarat.type == 'simple' then
        local chars = {}
        for i, obj in ipairs(declarat) do
            if obj.type == 'name' then
                chars[i] = obj[1]
            elseif obj.type == 'index' then
                chars[i] = '[?]'
            elseif obj.type == 'call' then
                chars[i] = '(?)'
            elseif obj.type == ':' then
                chars[i] = ':'
            elseif obj.type == '.' then
                chars[i] = '.'
            else
                chars[i] = '*' .. obj.type
            end
        end
        -- 这里有个特殊处理
        -- function mt:func() 以 mt.func 的形式调用时
        -- hover 显示为 mt.func(self)
        if chars[#chars-1] == ':' then
            if not source:get 'object' then
                chars[#chars-1] = '.'
            end
        elseif chars[#chars-1] == '.' then
            if source:get 'object' then
                chars[#chars-1] = ':'
            end
        end
        key = table.concat(chars)
    else
        key = ''
    end
    return key
end
