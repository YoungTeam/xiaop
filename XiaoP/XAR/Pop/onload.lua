--[[
local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")

local tipsHostWndTemplate = templateMananger:GetTemplate("XiaoP.Pop.Wnd","HostWndTemplate")

local tipsHostWnd = tipsHostWndTemplate:CreateInstance("Bolt.Tips")

tipsHostWnd:SetTipTemplate("xiaop.popwnd.panel")
tipsHostWnd:SetPosition(1100,500)
tipsHostWnd:Popup()]]