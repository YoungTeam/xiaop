function AddRecentUser(self,userData)

	local userList = self:GetObject("recentUserList")
	local attr = userList:GetAttribute()
	
	for i,tData in pairs(attr.data) do
		if tData.userId == userData.userId then
			table.remove(attr.data, i)
			break
		end
	end	
	
	table.insert(attr.data,1,userData)	
	if #attr.data > 20 then
		table.remove(attr.data, #attr.data)
	end
	attr.selectItem = nil
	userList:CreateList(attr.data)
end

function OnInitUser(self)
	UpdateUserItem(self)
end

function UpdateUserItem(userItem)
	local attr = userItem:GetAttribute()
	if attr.data == nil then 
		return 
	end
	
	local name = userItem:GetControlObject("user.name")
	local userFace =  userItem:GetObject("userFace.mask:userFace")
	local userIntro =  userItem:GetObject("user.intro")
	
	local nameStr = attr.data.userName
	if attr.data.miniDeptName ~= null and attr.data.miniDeptName ~= "" then
			nameStr = nameStr.."（"..attr.data.miniDeptName.."）"
	end	
	name:SetText(nameStr)
	userIntro:SetText(attr.data.introduction)
	
	local ImageFactory = XLGetObject("XiaoP.Wnds.XImage.Factory")
	local imageClass = ImageFactory:CreateInstance()
	--XLMessageBox(attr.userId)
	--获取用户头像
	imageClass:AttachImgListener(
    		function(r)
				userFace:SetBitmap(r)
			end
	)
	
	imageClass:GetFace(attr.data.userId,40,40,attr.data.userStatus)
end

function OnUserFaceDbClick(self)
	local userItem = self:GetOwnerControl()
	local attr  = userItem:GetAttribute()

	local recentList = userItem:GetOwnerControl()
	recentList:FireExtEvent("OnItemDbClick",attr.data.userId)
end

function OnUserDbClick(self)
	local attr  = self:GetAttribute()

	local recentList = self:GetOwnerControl()
	recentList:FireExtEvent("OnItemDbClick",attr.data.userId)
end

function OnUserHover(self)
	local attr = self:GetAttribute()
	if attr.selected then
		return
	end
	
	local bkg = self:GetObject("user.bkg")
	bkg:SetSrcColor("RGBA(254,244,237,255)")

end

function OnUserLeave(self)
	local attr = self:GetAttribute()
	if attr.selected then
		return
	end
	
	local bkg = self:GetObject("user.bkg")
	bkg:SetSrcColor("RGBA(255,255,255,0)")
end

function OnUserClick(self)
	local bkg = self:GetObject("user.bkg")
	bkg:SetSrcColor("RGBA(253,238,227,255)")
	
	SetUserSelected(self)
end

function TwinkleUserItem(userItem,twinkle)

	local attr = userItem:GetAttribute()	
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	
	local face = userItem:GetObject("userFace")
	if twinkle == false then
		if attr.twinkleFaceTimer ~= nil then
			face:SetVisible(true)
			timerManager:KillTimer(attr.twinkleFaceTimer)
			attr.twinkleFaceTimer = nil
		end
		return
	else
		if attr.twinkleFaceTimer ~= nil then
			return
		end
	end
	
	
	function twinkleFaceTimer()
		if face:GetVisible() then
			face:SetVisible(false)
		else
			face:SetVisible(true)
		end
	end
	
	attr.twinkleFaceTimer = timerManager:SetTimer( twinkleFaceTimer, 500)
end

function TwinkleUser(self,userId,twinkle)
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostWnd = hostwndManager:GetHostWnd("XiaoP.ChatWnd." .. userId)
		
	if hostWnd then
		twinkle = false
	end

	local userList = self:GetObject("recentUserList")
	local attr = userList:GetAttribute()
	
	for i,item in pairs(attr.items) do
		local iAttr = item:GetAttribute()
		if iAttr.data.userId == userId then
			TwinkleUserItem(item,twinkle)
			break
		end
	end
	
end

function UpdateUser(self,data)
	local userList = self:GetObject("recentUserList")
	local attr = userList:GetAttribute()
	
	for i,item in pairs(attr.items) do
		local iAttr = item:GetAttribute()
		if iAttr.data.userId == data.userId then
			iAttr.data = data
			UpdateUserItem(item)
			break
		end
	end
end


function SetUserSelected(userItem)
	local userAttr = userItem:GetAttribute()
	userAttr.selected = true
	
	local list = userItem:GetOwnerControl()
	local attr = list:GetAttribute()
	
	--pre selected
	local oldSelUser = attr.selectItem
	if oldSelUser ~= nil then	
		if oldSelUser:GetID() == userItem:GetID() then
			return
		end
		oldSelUser:GetAttribute().selected = false
		OnUserLeave(oldSelUser)
	end
	
	attr.selectItem = userItem
	
end

function OnUserFaceEnter(self)
	local ctrl = self:GetOwnerControl()
	local ctrlAttr = ctrl:GetAttribute()
	
	local tree = self:GetOwner()
	local hostwnd = tree:GetBindHostWnd()
	
	local hleft,htop = hostwnd:GetWindowRect()
	local idCardCtrl = tree:GetUIObject("IDCard.Ctrl")
	
	local left,top,right,bottom = self:GetAbsPos()
	local appClass = XLGetObject("XiaoP.Wnds.App")
	local l,t,screenWidth,hbottom = appClass:GetScreenArea()
	
	--XLMessageBox(""..top.."|"..top)
	local attr = idCardCtrl:GetAttribute()
	attr.Left = hleft - 306
	attr.Top = htop+top
	attr.data = ctrlAttr.data
	attr.data.face = self:GetBitmap()
	
	if attr.Top + 320 > hbottom then
		attr.Top = hbottom - 320
	end
	
	idCardCtrl:OnHostMouseHover()
end

function OnUserFaceLeave(self)
	local tree = self:GetOwner()
	local idCardCtrl = tree:GetUIObject("IDCard.Ctrl")
	idCardCtrl:OnHostMouseLeave()
end

function OnUserMouseWheel(self,x,y,distance)
	self:GetOwnerControl():MouseWheel(distance)
end
