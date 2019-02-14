--[[
function LoadModule()
    local pos1, pos2 = string.find(__document, "XAR")
    local root = string.sub(__document, 1, pos2);

	local Menu = XLLoadModule(root.."/Util/layout/MenuHelper.lua")
    Menu["RegisterObject"]()
	
	local Tips = XLLoadModule(root.."/Util/layout/TipsHelper.lua")
	Tips["RegisterObject"]()
	
	local Json = XLLoadModule(root.."/Util/libs/json.lua")
    Json["RegisterObject"]()
end

local frameHostWndTemplate = templateMananger:GetTemplate("XiaoP.Settings.Wnd","HostWndTemplate")
if frameHostWndTemplate then
	--LoadModule()
	local frameHostWnd = frameHostWndTemplate:CreateInstance("XiaoP.Settings.Instance")
	if frameHostWnd then
		local objectTreeTemplate = templateMananger:GetTemplate("XiaoP.Settings.Tree","ObjectTreeTemplate")
		if objectTreeTemplate then
			local uiObjectTree = objectTreeTemplate:CreateInstance("XiaoP.Settings.Tree.UIObject")
			if uiObjectTree then
				frameHostWnd:BindUIObjectTree(uiObjectTree)
				frameHostWnd:Create()
			end
		end
	end
else
	XLMessageBox("!!!!!!")
end
]]

