--=====================================================
-- ExplorerDump_ExploitPro_Players.lua
--=====================================================

local ROOT_SERVICES = {
    "Workspace",
    "Players",
    "ReplicatedStorage",
    "ReplicatedFirst",
    "StarterGui",
    "StarterPlayer",
    "Lighting",
    "SoundService",
    "Teams",
    "Team",
    "StarterPack",
    "Chat"
}

local INTERESTING_CLASSES = {
    Folder = true,
    Model = true,

    Part = true,
    MeshPart = true,
    UnionOperation = true,
    Player = true,
    StarterGear = true,
    Backpack = true,
    TouchTransmitter = true,
    SpecialMesh = true,
    Sound = true,
    PlayerGui = true,
    PlayerScripts = true,

    Tool = true,

    RemoteEvent = true,
    RemoteFunction = true,
    BindableEvent = true,
    BindableFunction = true,

    Script = true,
    LocalScript = true,
    ModuleScript = true,

    ScreenGui = true,
    Frame = true,
    TextButton = true,
    TextLabel = true,
    ImageButton = true,
    ImageLabel = true,
    ScrollingFrame = true,
    UICorner = true,

    BoolValue = true,
    IntValue = true,
    NumberValue = true,
    StringValue = true,
    ObjectValue = true,
    Vector3Value = true,
    CFrameValue = true,
    Color3Value = true,
    BrickColorValue = true
}

local MAX_PARTS_PER_NODE = 100

local function safeGetService(name)
    local ok, svc = pcall(function()
        return game:GetService(name)
    end)
    if ok then return svc end
    return nil
end

local function isInteresting(obj)
    return INTERESTING_CLASSES[obj.ClassName] == true
end

local function formatValue(obj)
    if obj:IsA("ValueBase") then
        local ok, val = pcall(function()
            return obj.Value
        end)
        if ok then
            return " = " .. tostring(val)
        end
    end
    return ""
end

local function DumpExplorer()
    local lines = {}

    local function scan(obj, prefix, isLast)
        local connector = prefix ~= "" and (isLast and "└── " or "├── ") or ""
        table.insert(lines, prefix .. connector .. obj.Name .. " [" .. obj.ClassName .. "]" .. formatValue(obj))

        local ok, children = pcall(function()
            return obj:GetChildren()
        end)
        if not ok or not children or #children == 0 then
            return
        end

        local filtered = {}
        local partCount = 0

        for _, child in ipairs(children) do
            if isInteresting(child) then
                if child:IsA("BasePart") then
                    partCount += 1
                    if partCount <= MAX_PARTS_PER_NODE then
                        table.insert(filtered, child)
                    end
                else
                    table.insert(filtered, child)
                end
            end
        end

        table.sort(filtered, function(a, b)
            return a.Name < b.Name
        end)

        local newPrefix = prefix .. (isLast and "    " or "│   ")

        for i, child in ipairs(filtered) do
            scan(child, newPrefix, i == #filtered)
        end
    end

    table.insert(lines, "game [DataModel]")

    for i, svcName in ipairs(ROOT_SERVICES) do
        local svc = safeGetService(svcName)
        if svc then
            scan(svc, "", i == #ROOT_SERVICES)
        end
    end

    return table.concat(lines, "\n")
end

--========================

--========================

--local dump = DumpExplorer()
--print(dump)
-- writefile("explorer_exploit_pro_players.txt", dump)

return DumpExplorer
