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

		
		
	local MessageBox = XLLoadModule(root.."/MsgBox/layout/MsgBox.xml.lua")
    MessageBox["RegisterObject"]()
end
LoadModule()

local MsgBox = XLGetGlobal("xiaop.messagebox")

local data = {}

function callback(ret)
	if ret then
		--XLMessageBox("t")
	else
		--XLMessageBox("f")
	end
end
data.callback = callback

MsgBox.ConfirmBox(data)
]]

--[[
local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
local frameHostWndTemplate = templateMananger:GetTemplate("XiaoP.About.Wnd","HostWndTemplate")
if frameHostWndTemplate then
	--LoadModule()
	local frameHostWnd = frameHostWndTemplate:CreateInstance("XiaoP.About.Instance")
	if frameHostWnd then
		local objectTreeTemplate = templateMananger:GetTemplate("XiaoP.About.Tree","ObjectTreeTemplate")
		if objectTreeTemplate then
			local uiObjectTree = objectTreeTemplate:CreateInstance("XiaoP.About.Tree.UIObject")
			if uiObjectTree then
				frameHostWnd:BindUIObjectTree(uiObjectTree)
				frameHostWnd:Create()
			end
		end
	end
else
	XLMessageBox("!!!!!!")
end]]




