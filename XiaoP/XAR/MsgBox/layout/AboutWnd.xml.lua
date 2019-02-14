function OnMinisize(self)
	local hostwnd = self:GetOwner():GetBindHostWnd()
	hostwnd:Min() 
end

function OnClose(self)
	local owner = self:GetOwner()
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local HostWnd = owner:GetBindHostWnd()
	HostWnd:EndDialog(0)
end

function OnInit(self)
	local appClass = XLGetObject("XiaoP.Wnds.App")
	local ver  = appClass:GetVersion()
	
	local version = self:GetObject("tree:version")
	version:SetText(ver)
end
