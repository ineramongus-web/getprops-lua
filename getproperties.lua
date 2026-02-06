
local function safeToString(v)
    local t = typeof(v)
    if t == "Instance" then
        return v:GetFullName()
    elseif t == "Vector3" or t == "Vector2" or t == "CFrame" or t == "Color3" or t == "UDim2" then
        return tostring(v)
    elseif t == "table" then
        return "[table]"
    else
        return tostring(v)
    end
end

local function GetAllProperties(obj)
    assert(typeof(obj) == "Instance", "GetAllProperties: expected Instance")

    local result = {
        ClassName = obj.ClassName,
        FullName = obj:GetFullName(),
        Properties = {}
    }

    local props = {}

    
    if typeof(getproperties) == "function" then
        local ok, list = pcall(getproperties, obj)
        if ok and typeof(list) == "table" then
            for _, propName in ipairs(list) do
                props[propName] = true
            end
        end
    end

    
    
    local common = {
        "Name","Parent","Archivable","ClassName",
        "Position","Size","CFrame","Orientation","Rotation",
        "Transparency","Color","BrickColor","Material","Reflectance",
        "Anchored","CanCollide","CanTouch","CanQuery","Massless",
        "Locked","CastShadow",
        "Text","TextSize","TextColor3","Font","BackgroundColor3","BackgroundTransparency",
        "Image","ImageColor3","ImageTransparency",
        "Value"
    }

    for _, p in ipairs(common) do
        props[p] = true
    end

    
    for propName in pairs(props) do
        local entry = {
            Name = propName,
            Type = "unknown",
            Value = nil,
            ReadOnly = false,
            Hidden = false,
            Error = nil
        }

        
        local ok, value = pcall(function()
            return obj[propName]
        end)

        if ok then
            entry.Type = typeof(value)
            entry.Value = safeToString(value)
        else
            
            if typeof(gethiddenproperty) == "function" then
                local ok2, hiddenValue = pcall(gethiddenproperty, obj, propName)
                if ok2 then
                    entry.Type = typeof(hiddenValue)
                    entry.Value = safeToString(hiddenValue)
                    entry.Hidden = true
                else
                    entry.Error = "Cannot read property"
                end
            else
                entry.Error = "Cannot read property"
            end
        end

        
        if entry.Error == nil then
            local okWrite = pcall(function()
                obj[propName] = obj[propName]
            end)
            if not okWrite then
                entry.ReadOnly = true
            end
        end

        table.insert(result.Properties, entry)
    end

    
    table.sort(result.Properties, function(a, b)
        return a.Name < b.Name
    end)

    return result
end

--=====================================================

--=====================================================
--[[
local part = workspace:FindFirstChildWhichIsA("BasePart", true)
if part then
    local info = GetAllProperties(part)

    print("ClassName:", info.ClassName)
    print("FullName:", info.FullName)
    print("Properties count:", #info.Properties)

    for _, prop in ipairs(info.Properties) do
        print(string.format(
            "[%s] %s = %s | ReadOnly=%s | Hidden=%s",
            prop.Type,
            prop.Name,
            tostring(prop.Value),
            tostring(prop.ReadOnly),
            tostring(prop.Hidden)
        ))
    end
end
]]
--=====================================================
 return GetAllProperties
--=====================================================
