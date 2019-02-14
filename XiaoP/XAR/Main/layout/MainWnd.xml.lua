

local attached = nil
local cacheWidth = 0
local cacheHeight = 0

function OnCreateWnd(self)
	local mainClass = XLGetObject("XiaoP.Wnds.MainWnd")
	mainClass:SetIcon(self:GetWndHandle())
end

function OnMainWndMove(self)

	local left,top,right,bottom = self:GetWindowRect()
	local width = right-left 
	local height =bottom-top
	
	local appClass = XLGetObject("XiaoP.Wnds.App")
	local l,t,screenWidth,screenHeight = appClass:GetScreenArea()
	
	if top <= 0 then
		attached = "t"
	elseif left <=0 then
		attached = "l"
	elseif left >= (screenWidth - width) then	
		attached = "r"
	else
		attached = nil
	end
	
	if attached == "r" then
		self:Move(screenWidth-width,top,width,height)
	elseif attached == "l" then
		self:Move(0,top,width,height)
	elseif attached == "t" then
		self:Move(left,0,width,height)
	else
		self:Move(left,top,width,height)
	end
	
end

function OnMainWndSize(self,type_, width, height)

	if Type == "min" then
		---最小化时w h 为0 不要用这个重设obj pos 否则各种异常
		return
	elseif Type == "max" then
		local tree = self:GetBindUIObjectTree()
		if tree ~= nil then
			local sysButton = tree:GetUIObject( "SystemBtn" )
			if sysButton ~= nil then
				sysButton:SetMaxState( false )
			end
		end
	elseif Type == "restored" then
		local tree = self:GetBindUIObjectTree()
		if tree ~= nil then
			local sysButton = tree:GetUIObject( "SystemBtn" )
			if sysButton ~= nil then
				sysButton:SetMaxState( true )
			end
		end
	end

	local objectTree = self:GetBindUIObjectTree()
	local rootObject = objectTree:GetRootObject()
	
	rootObject:SetObjPos(0, 0, width, height)
end

function OnMinisize(self)
	local hostwnd = self:GetOwner():GetBindHostWnd()
	hostwnd:Min() 
	hostwnd:SetVisible(false)
	
end

function OnMaxSize(self)
	local hostwnd = self:GetOwner():GetBindHostWnd()
	hostwnd:SetVisible(true)
	hostwnd:Max()
	self:SetMaxState( false )
end

function OnReStore(self)
	local hostwnd = self:GetOwner():GetBindHostWnd()
	hostwnd:SetVisible(true)
	hostwnd:Restore()
	self:SetMaxState( true )
end

function OnClose(self)
	local appClass = XLGetObject("XiaoP.Wnds.App")
	local minOrExit = appClass:GetMinOrExit()
	local hostwnd = self:GetOwner():GetBindHostWnd()
	
	if minOrExit == "Mini" then
		
		hostwnd:Min() 
		hostwnd:SetVisible(false)		
	else
		appClass:Quit()
	end

end
--[[
function OnClickClose(self)

	local mainClass = XLGetObject("XiaoP.Wnds.MainWnd")
	mainClass:Destroy()
	os.exit(0)
end]]

function OnBodyLButtonDown(self)
	self:SetFocus(true)
end

function OnClickMainMenu(self)
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local parent = hostwndManager:GetHostWnd("XiaoP.Main.Wnd.Instance")
	local parentHandle = parent:GetWndHandle()
	
	local left,top,right,bottom = parent:GetWindowRect()
	
	local obj = XLGetGlobal("xunlei.MenuHelper")
	
	--self:SetButtonStatus(3)	
	obj:ShowMenu("XiaoP.MainMenu.Wnd", "XiaoP.MainWnd.MainMenu", "XiaoP.ManiMenu", parentHandle,left+12,bottom-200)
	
end

function OnInitTabHeader(self)
	local tabbkg = self:GetOwner():GetUIObject("tabbkg")
	--self:AddTabItem("DeptUsersPage","","常用联系人","tab.detp.icon.normal","tab.detp.icon.hover","tab.detp.icon.down",true)
	--self:AddTabItem("GroupPage","","部门/邮件组","tab.group.icon.normal","tab.group.icon.hover","tab.group.icon.down")
	--self:AddTabItem("RecentPage","","最近联系人","tab.recent.icon.normal","tab.recent.icon.hover","tab.recent.icon.down")
	self:AddTabItem("DeptUsersPage","","常用联系人","tab.detp.icon.normal","tab.detp.icon.hover","tab.detp.icon.down",true)
	self:AddTabItem("GroupPage","","部门/邮件组","tab.group.icon.normal","tab.group.icon.hover","tab.group.icon.down")
	self:AddTabItem("RecentPage","","最近联系人","tab.recent.icon.normal","tab.recent.icon.hover","tab.recent.icon.down")

	
	tabbkg:AddPage("XiaoP.TabPage.DeptUsersPage","DeptUsersPage")
	tabbkg:AddPage("XiaoP.TabPage.GroupsPage","GroupPage")
	tabbkg:AddPage("XiaoP.TabPage.RecentUsersPage","RecentPage")	
	AsynCall(function (x) tabbkg:ActivePage("DeptUsersPage") end)

end


function OnInit(self)
	--初始化用户个人信息卡
	local XARManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local XarFactory = XARManager:GetXARFactory()
	
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local mainHostWnd = hostWndManager:GetHostWnd("XiaoP.Main.Wnd.Instance")

	
	local success1 = XARManager:LoadXAR("IDCard")
	local success2 = XARManager:LoadXAR("Pop")
	
    
	local tipObj = XarFactory:CreateUIObject("IDCard.Ctrl","XiaoP.IDCard.Control")
	local popObj = XarFactory:CreateUIObject("PopWnd.Ctrl","XiaoP.PopWnd.Control")
	
	local tree = self:GetOwner()
	local root = tree:GetRootObject()
	root:AddChild(tipObj)
	root:AddChild(popObj)
	
	--加载用户信息
	local mainClass = XLGetObject("XiaoP.Wnds.MainWnd")
	
	local userName =  self:GetObject("userName")
	local userIntro =  self:GetObject("userIntro")
	local userFace =  self:GetObject("userFace.mask:userFace")
	local novaTodo = self:GetObject("nova.todo.txt")
	local novaMine = self:GetObject("nova.mine.txt")
	

	local ImageFactory = XLGetObject("XiaoP.Wnds.XImage.Factory")
	imageClass = ImageFactory:CreateInstance()
	imageClass:AttachImgListener(
		function(r)
			userFace:SetBitmap(r)
		end
	)

	local contactList = nil
	local groupList = nil
	local recentList = nil
	local deptUsersPage = self:GetObject("tabCtrl:tabbkg"):GetPage("DeptUsersPage")
	if deptUsersPage ~= nil then 
		contactList = deptUsersPage.obj:GetObject("contactList")
	end
	
	local groupPage = self:GetObject("tabCtrl:tabbkg"):GetPage("GroupPage")
	if groupPage ~= nil then 
		--XLMessageBox(recentUsersPage.obj:GetID())
		groupList = groupPage.obj:GetObject("groupList")
	end
	
	local recentUsersPage = self:GetObject("tabCtrl:tabbkg"):GetPage("RecentPage")
	if recentUsersPage ~= nil then 
		--XLMessageBox(recentUsersPage.obj:GetID())
		recentList = recentUsersPage.obj:GetObject("recentUserList")
	end
	
	mainClass:AttachResultListener(
    		function(r)
				
				local json = XLGetGlobal("xunlei.json")
				local retData = json.decode(r);
				
				if retData.type == "info" then
					userName:SetText(retData.data.userName)
					userIntro:SetText(retData.data.introduction)
					mainHostWnd:SetUserData(retData.data)			
					imageClass:GetFace(retData.data.userId,68,68,1)
				elseif retData.type == "auth" then
					if retData.data == "conflict" then
						Logout()
					end
				elseif retData.type == "dept" then	
					if contactList ~= nil then 
						contactList:CreateDeptList(retData.data)
					end
				elseif retData.type == "groups" then
					if groupList ~= nil then
						groupList:CreateGroupList(retData.data)
					end
				elseif retData.type == "recent" then	
					if recentList ~= nil then 
						recentList:CreateList(retData.data)
					end
				elseif retData.type == "addRecent" then
					if recentUsersPage.obj ~= nil then
						recentUsersPage.obj:AddRecentUser(retData.data)
					end
				elseif retData.type == "nova.todo" then
					
					novaTodo:SetText("("..retData.data..")")
				
				elseif retData.type == "nova.mine" then
				
					novaMine:SetText("("..retData.data..")")
					
				elseif retData.type == "task" then		
					popObj:Popup(retData.data,"nova")
				
				elseif retData.type == "txt" then	
					popObj:Popup(retData.data,"txt")
				
				elseif retData.type == "imgtxt" then	
					popObj:Popup(retData.data,"imgTxt")
				elseif retData.type == "chat" then
					if contactList ~= nil then 
						contactList:TwinkleUser(retData.data,true)
					end
					if recentUsersPage.obj ~= nil then
						recentUsersPage.obj:TwinkleUser(retData.data,true)
					end
				elseif retData.type == "groupchat" then
					if groupList ~= nil then
						
						local groupId = retData.data
						if string.find(retData.data, "group-") ~= nil then
							groupId =  string.gsub(retData.data, "group%-","")
						end
						groupList:TwinkleGroup(groupId,true)
					end
				
				elseif retData.type == "cancelChatSignal" then
					if contactList ~= nil then 
						contactList:TwinkleUser(retData.data,false)
					end
					if recentUsersPage.obj ~= nil then
						recentUsersPage.obj:TwinkleUser(retData.data,false)
					end
				elseif retData.type == "cancelGroupChatSignal" then
					if groupList ~= nil then
						groupList:TwinkleGroup(retData.data,false)
					end
				elseif retData.type == "userInfo" then
					if contactList ~= nil then 
						contactList:UpdateUserInfo(retData.data)
					end	
					if recentUsersPage.obj ~= nil then
						recentUsersPage.obj:UpdateUser(retData.data)
					end
				elseif retData.type == "addContact" then
					if contactList ~= nil then
						retData.data.isInContact = true
						contactList:InsertUser(retData.data)
						self:SetFocus(true)
						contactList:SetFocus(true)
					end
				elseif retData.type == "removeContact" then
					if contactList ~= nil then
						contactList:RemoveUser(retData.data)
						contactList:SetFocus(true)
					end
				elseif retData.type == "toChat" then
					OpenChatWnd(retData.data)				
				elseif retData.type == "mainMenu" then
					local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
					local parent = hostwndManager:GetHostWnd("XiaoP.Main.Wnd.Instance")
					local parentHandle = parent:GetWndHandle()
					
					local left,top,right,bottom = parent:GetWindowRect()
					
					local obj = XLGetGlobal("xunlei.MenuHelper")
									
					obj:ShowMenu("XiaoP.MainMenu.Wnd", "XiaoP.MainWnd.MainMenu", "XiaoP.ManiMenu", nil,retData.data.X,retData.data.Y)
				end
			end
	)
	
	
	mainClass:Init()
	--[[
	local attr = popObj:GetAttribute()
	local data ={}
	data.id = "aaa"
	attr.data = data
	popObj:Popup(data)]]
	--popObj:Popup(nil)
end

function OnUserIntroDbClick(self)
	self:SetNoCaret(false)
	self:SetReadOnly(false)
end

function OnMouseEnterFace(self)
	local tree = self:GetOwner()
	local hostwnd = tree:GetBindHostWnd()
	local hleft,htop,hright,hbottom = hostwnd:GetWindowRect()
	
	local idCardCtrl = tree:GetUIObject("IDCard.Ctrl")
	
	local left,top,right,bottom = self:GetAbsPos()
	local attr = idCardCtrl:GetAttribute()
	attr.Left = hleft - 306
	attr.Top = htop+top
	
	
	attr.data = hostwnd:GetUserData()
	--XLMessageBox(attr.data.userId)
	attr.data.face = self:GetBitmap()
	
	idCardCtrl:OnHostMouseHover()
end

function OnMouseLeaveFace(self)
	local tree = self:GetOwner()
	local idCardCtrl = tree:GetUIObject("IDCard.Ctrl")
	idCardCtrl:OnHostMouseLeave()
	--OnHostMouseLeave
end

function OnTodoClick(self)
	local mainClass = XLGetObject("XiaoP.Wnds.MainWnd")
	mainClass:OpenNovaTodo()
end

function OnMineClick(self)
	local mainClass = XLGetObject("XiaoP.Wnds.MainWnd")
	mainClass:OpenNovaMine()
end

function OnPopupWnd(data)
	
	
	local timeStr = os.time()
	
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local tipsHostWndTemplate = templateMananger:GetTemplate("XiaoP.Pop.Wnd","HostWndTemplate")
	local tipsHostWnd = tipsHostWndTemplate:CreateInstance("XiaoP.PopWnd."..timeStr)

	--加载用户信息
	local appClass = XLGetObject("XiaoP.Wnds.App")
	local left,top,right,bottom = appClass:GetWorkArea()
	
	tipsHostWnd:SetTipTemplate("xiaop.popwnd.panel")
	tipsHostWnd:SetPosition(right-312-50,bottom-206)
	tipsHostWnd:Popup()
	
end

function OnUserItemDbClick(self,event,userId)
	OpenChatWnd(userId)
end

function OnUserItemDelete(self,event,userId)

	local MsgBox = XLGetGlobal("xiaop.messagebox")
	local data = {}
	data.title = "删除联系人"
	data.content = "确定要删除这位常用联系人？"
	function callback(ret)
		if ret then
			self:RemoveUser(userId)
			local mainClass = XLGetObject("XiaoP.Wnds.MainWnd")
			mainClass:RemoveContact(userId)
		end
	end
	
	data.callback = callback
	MsgBox.ConfirmBox(data)
	
end


function OnSuggUserItemClick(self,event,userId)
	OpenChatWnd(userId)
end

function OnGroupItemDbClick(self,event,groupId)
	OpenGroupChatWnd(groupId)	
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
			hostWnd:SetFocus(true)
		end
		hostWnd:BringWindowToTop(true)
	end
	
end

function OpenChatWnd(userId)
	
	if userId == nil then
		return
	end
	
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local mainWnd = hostwndManager:GetHostWnd("XiaoP.Main.Wnd.Instance")
	local userData = mainWnd:GetUserData()
	if userData == nil or userData.userId == userId then
		return
	end

	local XARManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local loaded = XARManager:IsXARLoaded("Chat")
	if not loaded then
		loaded = XARManager:LoadXAR("Chat")
	end
	
	if loaded then
		
		local hostWnd = hostwndManager:GetHostWnd("XiaoP.ChatWnd." .. userId)
		local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")

		if not hostWnd then
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
			hostWnd:SetFocus(true)
		end
		
		hostWnd:BringWindowToTop(true)
	end
end

function OnSuggEditChange(self,event,text)

	local mainClass = XLGetObject("XiaoP.Wnds.MainWnd")
	--[[
	mainClass:AttachResultListener(
    		function(r)
				
				if r == "" then 
					return 
				end
				
				local suggEdit = self:GetObject("sugg.edit")
				local json = XLGetGlobal("xunlei.json")
				local data = json.decode(r)
				if data.query == suggEdit:GetText() then 
					suggUsers:CreateList(data.list)
				end
			end
	)]]

	mainClass:GetSuggUserList(text)
	
end

function OnMainBodyFocusChange(self,isFocus)
	local suggCtrl = self:GetObject("tree:suggCtrl")
	
	suggCtrl:SetSuggUserCtrlFocus(false)
	--local suggList = suggCtrl:GetObject("sugg.list")
	--suggList:SetVisible(false)
	--suggList:SetChildrenVisible(false)
	
	
end


function OnActiveTabChanged(self,eventName,newID,oldID)
	local tabbkg = self:GetOwner():GetUIObject("tabbkg")
	tabbkg:ActivePage(newID)   
end

function OnMainWndDestroy(self)
	local mainClass = XLGetObject("XiaoP.Wnds.MainWnd")
	mainClass:Destroy()
end


function Logout()
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
end

