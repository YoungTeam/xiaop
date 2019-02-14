function OnPopupMenu(self)
    local menuTree = self:GetBindUIObjectTree()
	local bkg = menuTree:GetUIObject("bkg")
	
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")	
	local aniAlpha = aniFactory:CreateAnimation("AlphaChangeAnimation")
	aniAlpha:BindRenderObj(bkg)
	aniAlpha:SetTotalTime(250)
	aniAlpha:SetKeyFrameAlpha(0,255)
	menuTree:AddAnimation(aniAlpha)
	aniAlpha:Resume()
end

function OnFeedBackSelect(self)
	local appClass = XLGetObject("XiaoP.Wnds.App")	
	appClass:Feedback()
end

function OnAboutSelect(self)
	local XARManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local loaded = XARManager:IsXARLoaded("MsgBox")
	if not loaded then
		loaded = XARManager:LoadXAR("MsgBox")
	end
	
	if loaded then
		local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
		local hostWnd = nil
		local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
		local frameHostWndTemplate = templateMananger:GetTemplate("XiaoP.About.Wnd","HostWndTemplate")
		if frameHostWndTemplate then
			hostWnd = frameHostWndTemplate:CreateInstance("XiaoP.About.Wnd.Instance")
			if hostWnd then
				local objectTreeTemplate = templateMananger:GetTemplate("XiaoP.About.Tree","ObjectTreeTemplate")
				if objectTreeTemplate then
					local uiObjectTree = objectTreeTemplate:CreateInstance("XiaoP.About.Tree.UIObject")
					if uiObjectTree then
						hostWnd:BindUIObjectTree(uiObjectTree)							
					end
				end
				
				hostWnd:DoModal()
				local objtreemanager = XLGetObject("Xunlei.UIEngine.TreeManager")
				objtreemanager:DestroyTree("XiaoP.About.Tree.UIObject")
				hostwndManager:RemoveHostWnd("XiaoP.About.Wnd.Instance") 
			end
		end

		
	end
end

function OnUpgradeSelect(self)
	local appClass = XLGetObject("XiaoP.Wnds.App")	
	appClass:LoadUpgrade()
end

function OnSettingsSelect(self)
	
	local XARManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local loaded = XARManager:IsXARLoaded("Settings")
	if not loaded then
		loaded = XARManager:LoadXAR("Settings")
	end
	
	if loaded then
		local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
		local hostWnd = hostwndManager:GetHostWnd("XiaoP.Settings.Wnd.Instance")
		
		if not hostWnd then
			local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
			local frameHostWndTemplate = templateMananger:GetTemplate("XiaoP.Settings.Wnd","HostWndTemplate")
			if frameHostWndTemplate then
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
			end
		else
			local state = hostWnd:GetWindowState()
			if state == "min" then
				hostWnd:Restore()
			end
			hostWnd:SetFocus(true)
		end
	end
	
end

function OnLogoutSelect(self)
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local mainWnd = hostwndManager:GetHostWnd("XiaoP.Main.Wnd.Instance")
	if mainWnd~=nil then 
		local left,top,right,bottom = mainWnd:GetWindowRect()
		hostwndManager:RemoveHostWnd("XiaoP.Main.Wnd.Instance")
		local treeMananger = XLGetObject("Xunlei.UIEngine.TreeManager")
		treeMananger:DestroyTree("XiaoP.Main.Tree.UIObject")
		
		local idHostWnd = hostwndManager:GetHostWnd("XiaoP.IDCard.Wnd.Instance")
		if idHostWnd ~= nil then
			hostwndManager:RemoveHostWnd("XiaoP.IDCard.Wnd.Instance")
		end
		
		
		local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
		local frameHostWndTemplate = templateMananger:GetTemplate("XiaoP.Login.Wnd","HostWndTemplate")
		if frameHostWndTemplate then
			local loginWnd = frameHostWndTemplate:CreateInstance("XiaoP.LoginWnd.Instance")
			if loginWnd then
				local objectTreeTemplate = templateMananger:GetTemplate("XiaoP.Login.Tree","ObjectTreeTemplate")
				if objectTreeTemplate then
					local uiObjectTree = objectTreeTemplate:CreateInstance("XiaoP.Login.Tree.UIObject")
					if uiObjectTree then
						loginWnd:SetUserData("logout")
						loginWnd:BindUIObjectTree(uiObjectTree)
						
						loginWnd:Create()
						loginWnd:Move(left,top,286,614)
					end
				end
			end
		else
			--XLMessageBox("!!!!!!")
		end
		
 		
	end
	--
		
end
function OnExitSelect(self)
	local appClass = XLGetObject("XiaoP.Wnds.App")	
	appClass:Quit()
end
