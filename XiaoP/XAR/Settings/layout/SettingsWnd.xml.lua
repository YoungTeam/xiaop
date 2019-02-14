function OnMinisize(self)
	local hostwnd = self:GetOwner():GetBindHostWnd()
	hostwnd:Min() 
end

function OnClose(self)
	local owner = self:GetOwner()
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local HostWnd = owner:GetBindHostWnd()
	hostwndManager:RemoveHostWnd(HostWnd:GetID())
	local treeMananger = XLGetObject("Xunlei.UIEngine.TreeManager")
	treeMananger:DestroyTree(owner:GetID())
end

function OnAutoStartCheck(self)
	SaveSettings(self:GetOwner())
end

function OnHideCheck(self)
	local exitCheck = self:GetObject("tree:exit.check")
	if self:GetCheck() then
		exitCheck:SetCheck(false)
	end
	SaveSettings(self:GetOwner())
end

function OnExitCheck(self)
	local hideCheck = self:GetObject("tree:hide.check")
	if self:GetCheck() then
		hideCheck:SetCheck(false)
	end
	SaveSettings(self:GetOwner())

end

function OnAlwaysPopCheck(self)
	local twoMinPopCheck = self:GetObject("tree:twominpop.check")
	local noPopCheck = self:GetObject("tree:nopop.check")
	if self:GetCheck() then
		twoMinPopCheck:SetCheck(false)
		noPopCheck:SetCheck(false)
	end
	SaveSettings(self:GetOwner())
end

function OnTwoMinPopCheck(self)
	local alwaysPopCheck = self:GetObject("tree:alwayspop.check")
	local noPopCheck = self:GetObject("tree:nopop.check")
	if self:GetCheck() then
		alwaysPopCheck:SetCheck(false)
		noPopCheck:SetCheck(false)
	end
	
	SaveSettings(self:GetOwner())
end

function OnNoPopCheck(self)
	local alwaysPopCheck = self:GetObject("tree:alwayspop.check")
	local twoMinPopCheck = self:GetObject("tree:twominpop.check")
	if self:GetCheck() then
		alwaysPopCheck:SetCheck(false)
		twoMinPopCheck:SetCheck(false)
	end
	
	SaveSettings(self:GetOwner())
end

function OnMobileCheck(self)
	SaveSettings(self:GetOwner())
end

function SaveSettings(owner)
	local autoStartCheck = owner:GetUIObject("autostart.check")
	local autoStart = autoStartCheck:GetCheck()
	
	local hideCheck = owner:GetUIObject("hide.check")
	local exitCheck = owner:GetUIObject("exit.check")
	local miniOrExit = "exit"
	if hideCheck:GetCheck() then 
		miniOrExit = "mini"
	elseif exitCheck:GetCheck() then
		miniOrExit = "exit"
	end
	
	
	
	local alwaysCheck = owner:GetUIObject("alwayspop.check")
	local twoMinCheck = owner:GetUIObject("twominpop.check")
	local noCheck = owner:GetUIObject("nopop.check")
	local popType = "Always"
	if alwaysCheck:GetCheck() then
		popType = "Always"
	elseif twoMinCheck:GetCheck() then
		popType = "2minutes"
	elseif noCheck:GetCheck() then
		popType = "Never"
	end
	
	local mobileCheck = owner:GetUIObject("mobile.check")
	local showMobile = mobileCheck:GetCheck()
	
	local appClass = XLGetObject("XiaoP.Wnds.App")	
	appClass:SaveSettings(miniOrExit,autoStart,popType,showMobile)

end


function OnInit(self)
	local appClass = XLGetObject("XiaoP.Wnds.App")
	local setStr = appClass:LoadSettgings()
	if setStr == nil then
		return
	end
	
	local json = XLGetGlobal("xunlei.json")
	local settings = json.decode(setStr)

	local autoStartCheck = self:GetObject("tree:autostart.check")
	local hideCheck = self:GetObject("tree:hide.check")
	local exitCheck = self:GetObject("tree:exit.check")
	local alwaysCheck = self:GetObject("tree:alwayspop.check")
	local twoMinCheck = self:GetObject("tree:twominpop.check")
	local noCheck = self:GetObject("tree:nopop.check")
	local mobileCheck = self:GetObject("tree:mobile.check")

	
	autoStartCheck:SetCheck(settings.autoStart)
	if settings.minOrExit == "Exit" then
		exitCheck:SetCheck(true)
	elseif settings.minOrExit == "Mini"  then
		hideCheck:SetCheck(true)
	end
	
	if settings.popType == "Always" then
		alwaysCheck:SetCheck(true)
	elseif settings.popType == "2minutes" then
		twoMinCheck:SetCheck(true)
	elseif settings.popType == "Never" then
		noCheck:SetCheck(true)	
	end
	
	mobileCheck:SetCheck(settings.showMobile)

end