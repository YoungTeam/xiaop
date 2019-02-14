--[[
local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")

function LoadModule()
    local pos1, pos2 = string.find(__document, "XAR")
    local root = string.sub(__document, 1, pos2);
    
    local Json = XLLoadModule(root.."/Util/libs/json.lua")
    Json["RegisterObject"]()
end


local idCardHostWndTemplate = templateMananger:GetTemplate("XiaoP.IDCard.Wnd","HostWndTemplate")
if idCardHostWndTemplate then
	LoadModule()
	local idCardHostWnd = idCardHostWndTemplate:CreateInstance("XiaoP.IDCard.Instance")
	if idCardHostWnd then
		idCardHostWnd:SetTipTemplate("XiaoP.IDCard.Panel")
		idCardHostWnd:SetPosition(600,300)
		idCardHostWnd:DelayPopup(0)
		--idCardHostWnd:Popup()
	end
end]]

