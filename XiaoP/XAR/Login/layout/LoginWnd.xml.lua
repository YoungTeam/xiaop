
local function ExitWnd(owner)
	local tree = owner
	local wnd = tree:GetBindHostWnd()
	wnd:Destroy()
end

local function CloseWnd(owner)
	local mirrorRoot = owner:GetUIObject("mirrorBkg");
	local root = owner:GetUIObject("bkg_border")
	
	local left, top, right, bottom = root:GetObjPos()
	
	local xlgraphic = XLGetObject("Xunlei.XLGraphic.Factory.Object")
	local render = XLGetObject("Xunlei.UIEngine.RenderFactory")
	local theBitmap = xlgraphic:CreateBitmap("ARGB32",800,600)
	render:RenderObject(root,theBitmap)
	mirrorRoot:SetBitmap(theBitmap)
		
	
	mirrorRoot:SetVisible(true)	
	root:SetVisible(false)
    root:SetChildrenVisible(false)	
						
	local function onAniFinish(self,oldState,newState)
			if newState == 4 then
				os.exit(0)
			end
	end
						
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	if aniFactory then
		local posAnim = aniFactory:CreateAnimation("PosChangeAnimation")
		posAnim:BindObj(mirrorRoot)
		posAnim:SetKeyFrameRect(left, top, right,bottom,right, top,right,bottom)
		posAnim:SetTotalTime(500)
		posAnim:AttachListener(true,onAniFinish)
		owner:AddAnimation(posAnim)
		posAnim:Resume()
	end				
end

function OnMinisize(self)
	local hostwnd = self:GetOwner():GetBindHostWnd()
	hostwnd:Min() 
	hostwnd:SetVisible(false)
end



function OnClose(self)

	--local objTree = self:GetOwner()
	CloseWnd(self:GetOwner())

end

function OnBindHostWnd(self,hostWnd)
	
	local owner = self
	local normalLayout = self:GetUIObject("loginwnd.normal.layout")
	local loginingLayout = self:GetUIObject("loginwnd.logining.layout")
	
	loginingLayout:SetVisible(false)
	loginingLayout:SetChildrenVisible(false)
	
	
	local userFace = self:GetUIObject("userFace")	
	local username = self:GetUIObject("username")
	local password = self:GetUIObject("password")
	local process = loginingLayout:GetObject("loginwnd.progress")
	
	--local loginFactory = XLGetObject("XiaoP.Wnds.LoginWnd.Factory")
	--local loginClass = loginFactory:CreateInstance()
	
	local ImageFactory = XLGetObject("XiaoP.Wnds.XImage.Factory")
	imageClass = ImageFactory:CreateInstance()
	imageClass:AttachImgListener(
		function(r)
			userFace:SetBitmap(r)
			--faceReal:SetWindow(r)
		end
	)
	
	
	
	local json = XLGetGlobal("xunlei.json")
	local appClass = XLGetObject("XiaoP.Wnds.App")	
	appClass:SetTrayIcon()
	appClass:AttachTrayIconListener(
    		function(r)
				if r == "" then
					ShowWnd()
				else
					local ret_table = json.decode(r);
					if ret_table.type == "chat" then
						OpenChatWnd(ret_table.data)				
					elseif ret_table.type == "groupchat" then
						OpenGroupChatWnd(ret_table.data)
					end
				end				
			end
	)
	
	local loginClass = XLGetObject("XiaoP.Wnds.LoginWnd")
					
	
	loginClass:AttachResultListener(
    		function(r)
				local ret = json.decode(r);
				
				if ret.type =="auth" then
					if ret.data == "true" then						
						Logining(owner)
					else
						XLGetGlobal("xunlei.TipsHelper"):AddWindowedTip( password,"账号密码错误" ,nil, 4,false,100,86,0)
					end
				elseif ret.type =="logining" then
					process:SetProgress(ret.data)
					if ret.data == 100 then 
						LoginOK(owner)
					end
				elseif ret.type == "hotkey" then
					if ret.data == "enter" then
						if loginingLayout:GetVisible() == true then 
							OnLoginCancel(username)
						else
							OnClickLogin(username)
						end
					end
				elseif ret.type == "cancel" then
					Normal(owner)
				end
			end
	)
	
	local setStr = appClass:LoadLoginSettings()
	local setting = json.decode(setStr);
	
	if setting.userId ~= nil and setting.userId ~= "" then
		username:SetText(setting.userId);
	end
	imageClass:GetFace(setting.userId)
	
	
		
	local rememberCheck = owner:GetUIObject("remember.check")
	local autoLogin = owner:GetUIObject("autologin.check")
	
	rememberCheck:SetCheck(setting.isRemember)
	autoLogin:SetCheck(setting.autoStart)
	
	if setting.isRemember and setting.userPwd ~= ""then
		password:SetIsPassword(true)
		password:SetText(setting.userPwd)
	end
	
	if setting.autoStart == true then
		if hostWnd:GetUserData() ~=nil and hostWnd:GetUserData() == "logout" then
			return
		end
		OnClickLogin(username)
	end

	
	
end


function OpenGroupChatWnd(groupId)
	if groupId == nil then
		return
	end

	local XARManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local loaded = XARManager:IsXARLoaded("Chat")
	if not loaded then
		loaded = XARManager:LoadXAR("Chat")
	end
	
	if loaded then
		local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
		local hostWnd = hostwndManager:GetHostWnd("XiaoP.GroupChatWnd." .. groupId)
		
		if not hostWnd then
			local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
			local frameHostWndTemplate = templateMananger:GetTemplate("XiaoP.GroupChat.Wnd","HostWndTemplate")
			if frameHostWndTemplate then  
				hostWnd = frameHostWndTemplate:CreateInstance("XiaoP.GroupChatWnd." .. groupId)
				if hostWnd then
					local objectTreeTemplate = templateMananger:GetTemplate("XiaoP.GroupChat.Tree","ObjectTreeTemplate")
					if objectTreeTemplate then
						local uiObjectTree = objectTreeTemplate:CreateInstance("XiaoP.GroupChat.Tree." .. groupId)
						if uiObjectTree then
							hostWnd:SetUserData(groupId)
							hostWnd:BindUIObjectTree(uiObjectTree)
							hostWnd:Create()
						end
					end
				end
			end
		else
			local state = hostWnd:GetWindowState()
			if state == "min" then
				hostWnd:Restore()
			end
		end
		hostWnd:BringWindowToTop(true)
		hostWnd:SetFocus(true)
	
	end
	
end

function OpenChatWnd(userId)
	local XARManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local loaded = XARManager:IsXARLoaded("Chat")
	if not loaded then
		loaded = XARManager:LoadXAR("Chat")
	end
	
	if loaded then
		local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
		local hostWnd = hostwndManager:GetHostWnd("XiaoP.ChatWnd." .. userId)
		
		if not hostWnd then
			local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
			local frameHostWndTemplate = templateMananger:GetTemplate("XiaoP.Chat.Wnd","HostWndTemplate")
			if frameHostWndTemplate then  
				hostWnd = frameHostWndTemplate:CreateInstance("XiaoP.ChatWnd." .. userId)
				if hostWnd then
					local objectTreeTemplate = templateMananger:GetTemplate("XiaoP.Chat.Tree","ObjectTreeTemplate")
					if objectTreeTemplate then
						local uiObjectTree = objectTreeTemplate:CreateInstance("XiaoP.Chat.Tree." .. userId)
						if uiObjectTree then
							hostWnd:SetUserData(userId)
							hostWnd:BindUIObjectTree(uiObjectTree)							
							hostWnd:Create()
							
							
						end
					end
				end
			end
		else
			local state = hostWnd:GetWindowState()
			if state == "min" then
				hostWnd:Restore()
			end
		end
		hostWnd:BringWindowToTop(true)
		--hostWnd:SetFocus(true)
	end
end

function OnClickLogin(self)

	local loginClass = XLGetObject("XiaoP.Wnds.LoginWnd")
	
	local owner = self:GetOwner()

	local username = self:GetObject("tree:username")
	local password = self:GetObject("tree:password")
	
	if username:GetText()=="" or username:GetText() == "请输入邮箱ID" then 
		XLGetGlobal("xunlei.TipsHelper"):AddWindowedTip( password,"用户名不能为空" ,nil, 4,false,100,86,0)
		return
	elseif  password:GetText()=="" or password:GetText()=="请输入密码" then
		XLGetGlobal("xunlei.TipsHelper"):AddWindowedTip( password,"密码不能为空" ,nil, 4,false,100,86,0)
		return
	end
	
	loginClass:Authentication(username:GetText(),password:GetText())
	
	
	local rememberCheck = owner:GetUIObject("remember.check")
	local autoLogin = owner:GetUIObject("autologin.check")
	
	local appClass = XLGetObject("XiaoP.Wnds.App")	
	appClass:SaveLoginSettings(username:GetText(),rememberCheck:GetCheck(),autoLogin:GetCheck())
	
end

function OnEditFocusChange(self,event,focus)
	
	local userFace = self:GetObject("tree:userFace")	
	local ImageFactory = XLGetObject("XiaoP.Wnds.XImage.Factory")
	imageClass = ImageFactory:CreateInstance()
	imageClass:AttachImgListener(
		function(r)
			userFace:SetBitmap(r)
			--faceReal:SetWindow(r)
		end
	)
	
	
	if self:GetID() == "username" then
		if focus then
			if self:GetText()=="请输入邮箱ID" then 
				self:SetText("")
				self:SetTextColor("loginwnd.black.color")
			end
			
		else
			if self:GetText()=="" then 
				self:SetText("请输入邮箱ID")
				self:SetTextColor("loginwnd.green.color")
			end
			imageClass:GetFace(self:GetText())
		end
	elseif self:GetID() == "password" then
		if focus then
			if self:GetText()=="请输入密码" then 
				self:SetText("")
				self:SetIsPassword(true)
				self:SetTextColor("loginwnd.black.color")
			end
			
		else
			if self:GetText()=="" then 
				self:SetText("请输入密码")
				self:SetIsPassword(false)
				self:SetTextColor("loginwnd.green.color")
			end
		end		
	end

	local password = self:GetObject("tree:password")
	XLGetGlobal("xunlei.TipsHelper"):RemoveWindowedTip( password)
end

function OnLoginCancel(self)
	local owner = self:GetOwner()
	local loginClass = XLGetObject("XiaoP.Wnds.LoginWnd")
		
	loginClass:Cancel()
end

function Normal(owner)
	local normalLayout = owner:GetUIObject("loginwnd.normal.layout")
	local loginingLayout = owner:GetUIObject("loginwnd.logining.layout")
	local process = loginingLayout:GetObject("loginwnd.progress")
	
	normalLayout:SetVisible(true)
	normalLayout:SetChildrenVisible(true)
	
	loginingLayout:SetVisible(false)
	loginingLayout:SetChildrenVisible(false)
	
	process:SetProgress(0)
end

function Logining(owner)

	local normalLayout = owner:GetUIObject("loginwnd.normal.layout")
	local loginingLayout = owner:GetUIObject("loginwnd.logining.layout")
	
	
	normalLayout:SetVisible(false)
	normalLayout:SetChildrenVisible(false)
	
	loginingLayout:SetVisible(true)
	loginingLayout:SetChildrenVisible(true)
	
	local userClass = XLGetObject("XiaoP.Wnds.LoginWnd")
	
	--[[
	local json = XLGetGlobal("xunlei.json")
	userClass:AttachResultListener(
    		function(r)
			
				local ret_table = json.decode(r);
				if ret_table.ret == true then		
					
					process:SetProgress(ret_table.value)
					if ret_table.value == 100 then 
						LoginOK(owner,userId)
					end
				else
					process:SetProgress(0)
					Normal(owner)
				end
			end
	)]]

	userClass:Logining()
	
end

function LoginOK(owner)
	
	--ExitWnd(owner)
	local HostWnd = owner:GetBindHostWnd()
	local left,top,right,bottom = HostWnd:GetWindowRect()
	
	
	local XARManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local loaded = XARManager:IsXARLoaded("Main")
	
	if not loaded then
		loaded = XARManager:LoadXAR("Main")
	end
	
	if loaded then
		local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
		hostwndManager:RemoveHostWnd("XiaoP.LoginWnd.Instance")
		local treeMananger = XLGetObject("Xunlei.UIEngine.TreeManager")
		treeMananger:DestroyTree(owner:GetID())
		
		
		local mainWnd = hostwndManager:GetHostWnd("XiaoP.Main.Wnd.Instance")
		if mainWnd == nil then 		
			local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
			local frameHostWndTemplate = templateMananger:GetTemplate("XiaoP.Main.Wnd","HostWndTemplate")
			if frameHostWndTemplate then
				local mainWnd = frameHostWndTemplate:CreateInstance("XiaoP.Main.Wnd.Instance")
				if mainWnd then
					local objectTreeTemplate = templateMananger:GetTemplate("XiaoP.Main.Tree","ObjectTreeTemplate")
					if objectTreeTemplate then
						local uiObjectTree = objectTreeTemplate:CreateInstance("XiaoP.Main.Tree.UIObject")
						if uiObjectTree then
							mainWnd:BindUIObjectTree(uiObjectTree)
							mainWnd:Create()
							mainWnd:Move(left,top,right-left,bottom-top)
						end
					end
				end
			end
		end
		
		
	else
		--local uiHelper = XLGetGlobal("V6ChatUIHelper")
		--uiHelper:V6MessageBox("无法导入Main XAR包！", 250, 130)
		--local app = XLGetObject("V6Chat3App")
		--app:Quit()
	end	

end


function OnClickClose(self)

	CloseWnd(self:GetOwner())	
	--os.exit(0)
end

function ShowWnd()

	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	
	local hostWnd = nil
	hostWnd = hostwndManager:GetHostWnd("XiaoP.LoginWnd.Instance")
	
	if hostWnd == nil then
		hostWnd = hostwndManager:GetHostWnd("XiaoP.Main.Wnd.Instance")
	end
	
	if hostWnd == nil then
		return
	end
	
	local state= hostWnd:GetWindowState() 
	if state == "min" or state == "hide" then
		hostWnd:SetVisible(true)
		hostWnd:Restore()
	end
	hostWnd:SetFocus(true)
	hostWnd:BringWindowToTop(true)
	
end

function OnLoginWndDestroy(self)
	local loginClass = XLGetObject("XiaoP.Wnds.LoginWnd")	
	loginClass:Destroy()
	loginClass = nil
end

