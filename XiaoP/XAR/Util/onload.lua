local pos1, pos2 = string.find(__document, "XAR")
local root = string.sub(__document, 1, pos2);
local md = XLLoadModule(root.."/Util/layout/TipsHelper.lua")
md["RegisterObject"]()

local md1 = XLLoadModule(root.."/Util/libs/json.lua")
md1["RegisterObject"]()
