function LoadModule()
    local pos1, pos2 = string.find(__document, "XAR")
    local root = string.sub(__document, 1, pos2);
    local md = XLLoadModule(root.."/Util/layout/TipsHelper.lua")
	md["RegisterObject"]()
	
	local md1 = XLLoadModule(root.."/Util/libs/json.lua")
    md1["RegisterObject"]()
end

LoadModule()

--[[
local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")

local frameHostWndTemplate = templateMananger:GetTemplate("XiaoP.GroupChat.Wnd","HostWndTemplate")
if frameHostWndTemplate then
	LoadModule()
	local frameHostWnd = frameHostWndTemplate:CreateInstance("XiaoP.GroupChatWnd.D0560")
	if frameHostWnd then
		frameHostWnd:SetUserData("jialike")
		local objectTreeTemplate = templateMananger:GetTemplate("XiaoP.GroupChat.Tree","ObjectTreeTemplate")
		if objectTreeTemplate then
		
			local uiObjectTree = objectTreeTemplate:CreateInstance("XiaoP.GroupChat.Tree.D0560")
			if uiObjectTree then
				frameHostWnd:BindUIObjectTree(uiObjectTree)
				frameHostWnd:Create()
			end
		end
	end
else
	XLMessageBox("!!!!!!")
end]]

--[[
local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")

local frameHostWndTemplate = templateMananger:GetTemplate("XiaoP.Chat.Wnd","HostWndTemplate")
if frameHostWndTemplate then
	LoadModule()
	local frameHostWnd = frameHostWndTemplate:CreateInstance("XiaoP.ChatWnd.jialike")
	if frameHostWnd then
		frameHostWnd:SetUserData("jialike")
		local objectTreeTemplate = templateMananger:GetTemplate("XiaoP.Chat.Tree","ObjectTreeTemplate")
		if objectTreeTemplate then
		
			local uiObjectTree = objectTreeTemplate:CreateInstance("XiaoP.Chat.Tree.jialike")
			if uiObjectTree then
				frameHostWnd:BindUIObjectTree(uiObjectTree)
				frameHostWnd:Create()
			end
		end
	end
else
	XLMessageBox("!!!!!!")
end]]
