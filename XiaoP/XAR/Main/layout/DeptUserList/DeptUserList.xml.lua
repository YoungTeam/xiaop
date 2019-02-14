function OnBind(self)
	local attr = self:GetAttribute()
	attr.top = 0
end

function InsertUser(self,data)
	
	if data == nil then
		return 
	end

	local attr = self:GetAttribute()

	if attr.allDeptItemIndexer[data.deptId]==nil then
		
		local deptData = {}
		deptData.deptId = data.deptId
		deptData.deptName = data.deptName
		deptData.expand = true
		local users={}
		users[1] = data
		deptData.users = users
		CreateDept(self,deptData)
		
	else
		
		local deptItem = attr.allDeptItemIndexer[data.deptId]
		deptItem:AddDeptUser(data)
		
	end

end

function RemoveUser(self,userId)
	if userId == nil then
		return 
	end
	local ownControl = self
	local listAttr = ownControl:GetAttribute()
	
	function RemoveUserItem(deptItem,userItem) 
		local deptAttr = deptItem:GetAttribute()
		local deptData = deptAttr.data
		
		local count = #deptData.users
		local offset,index = 0,deptAttr.index
		if count > 1 then
			local userAttr = userItem:GetAttribute()		
			table.remove(deptData.users, userAttr.index)
			DrawDeptUsers(deptItem,deptData)
			offset = 56
			index = deptAttr.index+1
		else
			offset = 56 + 30
			ownControl:GetObject("bkg"):RemoveChild(deptItem)	
			table.remove(listAttr.allDeptItem, deptAttr.index)
			listAttr.allDeptItemIndexer[deptAttr.deptId] = nil		
		end
		
		local total = table.getn(listAttr.allDeptItem)
		if index <= total then 
			for i=index,total do
				local thisDept = listAttr.allDeptItem[i]
				local thisAttr = thisDept:GetAttribute()
				thisAttr.index = i
				local a,b,c,d = thisDept:GetObjPos()				
				thisDept:SetObjPos(a,b-offset,"father.width",d-offset)
			end
		end
		
		listAttr.selectUserItem = nil
		ownControl:UpdateScroll()
	end
	
	local attr = self:GetAttribute()
	for k,deptItem in pairs(attr.allDeptItem) do
		local deptAttr = deptItem:GetAttribute()
		if deptAttr.allUserItemIndexer[userId] ~= nil then
			local userItem = deptAttr.allUserItemIndexer[userId]
			RemoveUserItem(deptItem,userItem)
			--TwinkleUserItem(deptAttr.allUserItemIndexer[userId],twinkle)
			return
		end
	end
end
--DeptUser
	
function comps(a,b)
	local aWeight,bWeight = 0,0
	if a.userStatus > 0 then
		aWeight = aWeight - 10
	end
	
	if b.userStatus > 0 then
		bWeight = bWeight - 10
	end
	
	if a.userNamePinyin ~= nil and b.userNamePinyin ~= nil then
		if a.userNamePinyin < b.userNamePinyin then
			aWeight = aWeight -1
		else
			bWeight = bWeight -1		
		end
	else
		if a.userId < b.userId then
			aWeight = aWeight -1
		else
			bWeight = bWeight -1		
		end
	end

	return aWeight < bWeight
end

function DrawDeptUsers(deptItem,deptData)
	
	local deptItemAttr = deptItem:GetAttribute()
	deptItemAttr.data = deptData
	
	table.sort(deptData.users,comps)
	
	--users
	deptItemAttr.allUserItem = {}
	deptItemAttr.allUserItemIndexer = {}
	deptItemAttr.usersHeight = 56 * #deptData.users
	
	--更新dept信息
	local status = deptItem:GetControlObject("dept.status")
	local name = deptItem:GetControlObject("dept.name")
	local users = deptItem:GetObject("dept.users")
	local info = deptItem:GetObject("dept.info")
	name:SetText(deptItemAttr.deptName)
	
	
	
	if deptItemAttr.expand == true then
		status:SetResID("userlist.expand")
		deptItemAttr.height = 30+deptItemAttr.usersHeight
	else
		status:SetResID("userlist.collapse")
		deptItemAttr.height = 30
	end	
		
	local listCtrl = deptItem:GetOwnerControl()
	--XLMessageBox(deptItem:GetID())
	local listAttr = listCtrl:GetAttribute()
	
	
	local oldSelUser = listAttr.selectUserItem
	local selUserId = nil
	
	if oldSelUser ~= nil then
		selUserId = oldSelUser:GetAttribute().data.userId
	end
	
	--添加users
	users:RemoveAllChild()
	
	local newTopUser = 0
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local total,online = #deptData.users,0
	for k,v in pairs(deptData.users) do
		
		local newUserItem = objFactory:CreateUIObject("deptUserList.userItem."..v.userId,"XiaoP.DeptUserList.UserItem")	
	
		local userItemAttr = newUserItem:GetAttribute()
		
				
		userItemAttr.index = k
		userItemAttr.userId = v.userId
		userItemAttr.userName = v.userName
		userItemAttr.data = v
		
		if v.userId == selUserId then 
			userItemAttr.selected = true
			listAttr.selectUserItem = newUserItem
		else
			userItemAttr.selected = false
		end
		
		if v.userStatus == 1 then
			online = online+1
		end
		
		newUserItem:UpdateUser()
				
		deptItemAttr.allUserItem[k] = newUserItem	
		deptItemAttr.allUserItemIndexer[v.userId] = newUserItem	
		
		
		newUserItem:SetObjPos(0,newTopUser,"father.width", newTopUser + 56)
		newTopUser = newTopUser + 56
		users:AddChild(newUserItem)
		newUserItem:SetVisible(deptItemAttr.expand)
		newUserItem:SetChildrenVisible(deptItemAttr.expand)	
	end			
	local width = name:GetTextExtent()
	info:SetObjPos2(32+width+10,9,150,20)
	info:SetText(online.."/"..total)
	
end

function AddDeptUser(self,userData)
	local deptAttr = self:GetAttribute()
	deptAttr.expand = true
	
	local count = #deptAttr.data.users
	deptAttr.data.users[count+1] = userData
	
	DrawDeptUsers(self,deptAttr.data)
	
	local ownControl = self:GetOwnerControl()
	local listAttr = ownControl:GetAttribute()
	
	local total = table.getn(listAttr.allDeptItem)
	if deptAttr.index < total then 
		for i=deptAttr.index+1,total do
			local thisDept = listAttr.allDeptItem[i]
			local a,b,c,d = thisDept:GetObjPos()
			--XLMessageBox(""..(b+56))
			thisDept:SetObjPos(a,b+56,"father.width",d+56)
		end
	end
	
	self:GetOwnerControl():UpdateScroll()
	
end

function UpdateUser(self)
	local attr = self:GetAttribute()
	local name = self:GetControlObject("user.name")
	local userFace =  self:GetObject("userFace.mask:userFace")
	local userIntro =  self:GetObject("user.intro")
	
	local nameStr = attr.userName
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
	
	--XLMessageBox(""..attr.userStatus)
	imageClass:GetFace(attr.userId,40,40,attr.data.userStatus)
	
end

function UpdateUserInfo(self,data)
	local attr = self:GetAttribute()
	for k,deptItem in pairs(attr.allDeptItem) do
		local deptAttr = deptItem:GetAttribute()
		local userItem =  deptAttr.allUserItemIndexer[data.userId]
		if userItem ~= nil then
			local uAttr = userItem:GetAttribute()
			--data.selected = uAttr.data.selected
			--uAttr.data = data		
			deptAttr.data.users[uAttr.index] = data
			DrawDeptUsers(deptItem,deptAttr.data)
			--UpdateUser(userItem)
			return
		end
	end
end

function SetUserSelected(userItem)
	local bkg = userItem:GetObject("user.bkg")
	bkg:SetSrcColor("RGBA(253,238,227,255)")
	
	local userAttr = userItem:GetAttribute()
	userAttr.selected = true
	
	local dept = userItem:GetOwnerControl()
	local list = dept:GetOwnerControl()
	local attr = list:GetAttribute()
	
	--pre selected
	local oldSelUser = attr.selectUserItem
	if oldSelUser ~= nil then	
		if oldSelUser:GetID() == userItem:GetID() then
			return
		end
		oldSelUser:GetAttribute().selected = false
		OnUserLeave(oldSelUser)
	end
	
	attr.selectUserItem = userItem
	
end

function TwinkleDept(deptItem)
	
	local attr = deptItem:GetAttribute()	
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	
	local userItems = attr.allUserItem
	
	local twinkle = false
	
	for k,userItem in pairs(attr.allUserItem) do
		local uAttr = userItem:GetAttribute()
		if uAttr.twinkleFaceTimer ~= nil then
			twinkle = true
			break
		end
	end
	
	local name = deptItem:GetObject("dept.name")
	if twinkle == false then
		if attr.twinkleDeptTimer ~= nil then
			name:SetVisible(true)
			timerManager:KillTimer(attr.twinkleDeptTimer)
			attr.twinkleDeptTimer = nil
		end	
		return 
	else
		if attr.twinkleDeptTimer ~= nil then
			return
		end
	end
	
	
	function twinkleDeptTimer()
		if name:GetVisible() then
			name:SetVisible(false)
		else
			name:SetVisible(true)
		end
	end
	
	attr.twinkleDeptTimer = timerManager:SetTimer( twinkleDeptTimer, 560)
	
end

function TwinkleUser(self,userId,twinkle)

	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostWnd = hostwndManager:GetHostWnd("XiaoP.ChatWnd." .. userId)
		
	if hostWnd then
		twinkle = false
	end

	local attr = self:GetAttribute()
	for k,deptItem in pairs(attr.allDeptItem) do
		local deptAttr = deptItem:GetAttribute()
		if deptAttr.allUserItemIndexer[userId] ~= nil then
			TwinkleUserItem(deptAttr.allUserItemIndexer[userId],twinkle)
			return
		end
	end
	
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
			TwinkleDept(userItem:GetOwnerControl())
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
	
	attr.twinkleFaceTimer = timerManager:SetTimer( twinkleFaceTimer, 560)
	TwinkleDept(userItem:GetOwnerControl())
end

function OnUserClick(self)

	SetUserSelected(self)
	
	--[[
	local attr = self:GetAttribute()
	if attr.twinkleFaceTimer ~=nil then
		TwinkleUser(self,false)
	else
		TwinkleUser(self,true)
	end]]
	
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

function OnUserFaceEnter(self)
	local ctrl = self:GetOwnerControl()
	local ctrlAttr = ctrl:GetAttribute()
	
	local tree = self:GetOwner()
	local hostwnd = tree:GetBindHostWnd()
	
	local hleft,htop,hright,hbottom = hostwnd:GetWindowRect()
	local idCardCtrl = tree:GetUIObject("IDCard.Ctrl")
	
	local left,top,right,bottom = self:GetAbsPos()
	
	local appClass = XLGetObject("XiaoP.Wnds.App")
	local l,t,screenWidth,hbottom = appClass:GetScreenArea()
	
	local attr = idCardCtrl:GetAttribute()
	attr.Left = hleft - 306
	attr.Top = htop+top
	attr.data = ctrlAttr.data
	attr.data.face = self:GetBitmap()
	
	if attr.Top + 320 > hbottom then
		attr.Top = hbottom - 320
	end
	
	if hleft -300 < 0 then
		attr.Left = hright - 5
	end
	idCardCtrl:OnHostMouseHover()
end

function OnUserFaceLeave(self)
	local tree = self:GetOwner()
	local idCardCtrl = tree:GetUIObject("IDCard.Ctrl")
	idCardCtrl:OnHostMouseLeave()
end

--DeptGroup
function UpdateDept(self)
	local attr = self:GetAttribute()
	local status = self:GetControlObject("dept.status")
	local name = self:GetControlObject("dept.name")
	local users = self:GetObject("dept.users")
	
	name:SetText(attr.deptName)
	
	if attr.expand == true then
		status:SetResID("userlist.expand")
		attr.height = 30+attr.usersHeight
	else
		status:SetResID("userlist.collapse")
		attr.height = 30
	end	

	local newTop = 0
	local uItemHeight = 56
	
	if attr.expand == true then 
		for k,userItem in pairs(attr.allUserItem) do
			userItem:SetObjPos(0,newTop,"father.width", newTop + uItemHeight)
			newTop = newTop + uItemHeight
			users:AddChild(userItem)
		end
	end
	
	local left,top,right,bottom = self:GetObjPos()
	if attr.index > 1 then
		local deptUserList = self:GetParent():GetParent()
		local listAttr = deptUserList:GetAttribute()
		local lastItem = listAttr.allDeptItem[attr.index-1]
		local a,b,c,d = lastItem:GetObjPos()
		top = d
	end

	self:SetObjPos(left,top,"father.width",top + 30 + newTop)
	
	self:GetOwnerControl():UpdateScroll()
	
end

function ClearDeptList(self)
	local attr = self:GetAttribute()
	
	for i = #attr.allDeptItem, 1, -1 do
		table.remove(attr.allDeptItem, i)
		
	end
	
	for j = #attr.allDeptItemIndexer,1,-1 do
		table.remove(attr.allDeptItemIndexer, j)
	end
	self:GetObject("bkg"):RemoveAllChild()
end



function CreateDeptList(self,deptsData)
	if deptsData == nil then
		return
	end
	
	
	local attr = self:GetAttribute()
	local newTop = 0
	local height = 30
	local idx = 1
	
	if attr.allDeptItem == nil then
		attr.allDeptItem = {}
		attr.allDeptItemIndexer = {}
	else
		self:ClearDeptList()
	end
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")

		
	for idx,deptData in pairs(deptsData) do
			
			
			local newDeptItem = objFactory:CreateUIObject("deptUserList.deptItem."..deptData.deptId,"XiaoP.DeptUserList.DeptItem")	
			local deptItemAttr = newDeptItem:GetAttribute()	
			deptItemAttr.deptId = deptData.deptId
			deptItemAttr.deptName = deptData.deptName
			deptItemAttr.index = idx
			deptItemAttr.expand = deptData.expand
			deptItemAttr.usersHeight = 56 * table.getn(deptData.users)
			--deptItemAttr.data = deptData
			
			self:GetObject("bkg"):AddChild(newDeptItem)	
			DrawDeptUsers(newDeptItem,deptData)			
			
			attr.allDeptItem[idx] = newDeptItem
			attr.allDeptItemIndexer[deptData.deptId] = newDeptItem				
			newDeptItem:SetObjPos(0,newTop,"father.width",newTop + deptItemAttr.height)
			newTop = newTop+deptItemAttr.height 
			
		
			
	end
	
	self:UpdateScroll()
	
end

function CreateDept(self,deptData)
	if deptData == nil then
		return
	end

	local attr = self:GetAttribute()
	local newTop = 0
	local height = 30
	local idx = 1
	
	if attr.allDeptItem == nil then
		attr.allDeptItem = {}
		attr.allDeptItemIndexer = {}
	else
		idx = table.getn(attr.allDeptItem)
		if idx > 0 then
			local lastItem = attr.allDeptItem[idx]
			local l,t,l,b = lastItem:GetObjPos()
			newTop = b
		end
		
		idx = idx+1
	end
	
	local x,y,width,bottom = self:GetObjPos()
	
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	
	local newDeptItem = objFactory:CreateUIObject("deptUserList.deptItem."..deptData.deptId,"XiaoP.DeptUserList.DeptItem")
	
	local deptItemAttr = newDeptItem:GetAttribute()	
	deptItemAttr.deptId = deptData.deptId
	deptItemAttr.deptName = deptData.deptName
	deptItemAttr.index = idx
	deptItemAttr.expand = deptData.expand
	deptItemAttr.usersHeight = 56 * table.getn(deptData.users)
	deptItemAttr.data = deptData
	--users
	deptItemAttr.allUserItem = {}
	deptItemAttr.allUserItemIndexer = {}
	
	for k,v in pairs(deptData.users) do
	
		local newUserItem = objFactory:CreateUIObject("deptUserList.userItem."..v.userId,"XiaoP.DeptUserList.UserItem")		
		local userItemAttr = newUserItem:GetAttribute()
				
		userItemAttr.index = k
		userItemAttr.userId = v.userId
		userItemAttr.userName = v.userName
		userItemAttr.data = v
		userItemAttr.selected = false
			
		newUserItem:UpdateUser()
				
		deptItemAttr.allUserItem[k] = newUserItem	
		deptItemAttr.allUserItemIndexer[v.userId] = newUserItem	
	end			

	attr.allDeptItem[idx] = newDeptItem
	attr.allDeptItemIndexer[deptData.deptId] = newDeptItem	

	newDeptItem:SetObjPos(0,newTop,"father.width",newTop+height)
	self:GetObject("bkg"):AddChild(newDeptItem)	

	newDeptItem:UpdateDept()	

end

function ToggleDept(deptItem)
	local gStatus = deptItem:GetObject("dept.status")
	--local deptItem = dept:GetFather()
	local gSubs = deptItem:GetObject("dept.users")
	
	local attr = deptItem:GetAttribute()
	local left,top,right,bottom = deptItem:GetObjPos()
	
	
	attr.expand = not attr.expand
	
	if attr.expand == true then
		gStatus:SetResID("userlist.expand")
		attr.height = 30+attr.usersHeight
	else 
		gStatus:SetResID("userlist.collapse")
		attr.height = 30
	end	
	
	deptItem:SetObjPos(left,top,right,top + attr.height)
	
	for k,userItem in pairs(attr.allUserItem) do
		userItem:SetVisible(attr.expand)
		userItem:SetChildrenVisible(attr.expand)		
	end	
	
	local ownControl = deptItem:GetOwnerControl()
	local listAttr = ownControl:GetAttribute()
	--local l,t,r,b = ownControl:GetObject("bkg")
	
	local total = table.getn(listAttr.allDeptItem)
	if attr.index < total then 
		for i=attr.index+1,total do
			local thisDept = listAttr.allDeptItem[i]
			local a,b,c,d = thisDept:GetObjPos()
			if attr.expand == true then
				thisDept:SetObjPos(a,b+attr.usersHeight,"father.width",d+attr.usersHeight)
			else
				thisDept:SetObjPos(a,b-attr.usersHeight,"father.width",d-attr.usersHeight)
				--[[
				if i == total then
					XLMessageBox(""..(d-attr.usersHeight).."|"..(b-t).."|"..((b-t) - (d-attr.usersHeight)))
					listAttr.top = listAttr.top + (b-t) - (d-attr.usersHeight)
					ownControl:SetListPos()
				end]]
			end
		end
	end
	
	deptItem:GetOwnerControl():UpdateScroll()
end

function OnDeptClick(self)
	local deptItem = self:GetFather()
	ToggleDept(deptItem)	
end

function OnDeptHover(self)
	self:SetSrcColor("RGBA(254,244,237,255)")
end

function OnDeptLeave(self)
	self:SetSrcColor("RGBA(255,255,255,0)")
end


function OnMouseWheel(self, x, y, distance)
	self:GetOwnerControl():MouseWheel(distance)
end

function OnDeptMouseWheel(self, x, y, distance)
	self:GetOwnerControl():GetOwnerControl():MouseWheel(distance)
end

function OnUserMouseWheel(self, x, y, distance)	
	self:GetOwnerControl():GetOwnerControl():MouseWheel(distance)
end	

function SetListPos(self)
	
	local attr = self:GetAttribute()
	local top1 = attr.top
	local bkg = self:GetControlObject("bkg")
	local left,top,right,bottom = bkg:GetObjPos()
	local cnt = bkg:GetChildCount()-1
	
	--XLMessageBox(""..top1)
	for i=0,cnt do
		local item = bkg:GetChildByIndex(i)
		local itemAttr = item:GetAttribute()
		item:SetObjPos(0, top1, "father.width",top1+itemAttr.height)
		top1 = top1 + itemAttr.height
	end
	
end

function MouseWheel(self, distance)

	local bkg = self:GetControlObject("bkg")
	local left,top,right,bottom = bkg:GetObjPos()
	local height = bottom - top
	local attr = self:GetAttribute()
	local top1 = attr.top
	if distance > 0 then
		top1 = top1 + 56
	elseif distance < 0 then
		top1 = top1 - 56
	end
	
	
	local cnt = bkg:GetChildCount()
	local range = 0
	for i=0,cnt-1 do
		local item = bkg:GetChildByIndex(i)		
		local itemAttr = item:GetAttribute()
		range = range + itemAttr.height
	end	
	
	if height - (range + top1) < 0 then
		attr.top = top1
	else
		attr.top = height - (range + top1) + attr.top - 56		
	end
	if attr.top > 0 then attr.top = 0 end
	self:SetListPos()
	local vscroll = self:GetControlObject("scrollCtrl")
	vscroll:SetScrollPos(-attr.top, true)
end

function UpdateScroll(self)
	local bkg = self:GetControlObject("bkg")
	local empty = self:GetControlObject("empty.layout")

	if bkg:GetChildCount() == 0 then
		empty:SetVisible(true)
		empty:SetChildrenVisible(true)
	else
		empty:SetVisible(false)
		empty:SetChildrenVisible(false)
	end
	
	local left,top,right,bottom = bkg:GetObjPos()
	local height = bottom - top
	
	
	local vscroll = self:GetControlObject("scrollCtrl")
	vscroll:SetPageSize(height)
	
	local cnt = bkg:GetChildCount()
	local range = 0
	for i=0,bkg:GetChildCount()-1 do
		local item = bkg:GetChildByIndex(i)
		
		local itemAttr = item:GetAttribute()
		range = range + itemAttr.height
	end
	range = range - height
	
	if range < 0 then
		vscroll:SetVisible(false)
		vscroll:SetChildrenVisible(false)
		range = 0
	else
		vscroll:SetVisible(true)
		vscroll:SetChildrenVisible(true)
	end
	
	--修复调整大小后的scrollbar位置及list位置
	local attr = self:GetAttribute()
	if -attr.top > range then
		attr.top = - range
		self:SetListPos()
	end
	
	vscroll:SetScrollRange(0, range)
	vscroll:SetScrollPos(-attr.top, true)
end


--		点击纵向进度条的上箭头			self	“OnVScroll”	1	0
--		点击纵向进度条的下箭头			self	“OnVScroll”	2	0
--		点击纵向进度条的非滑块位置		self	“OnVScroll”	3	OnLButtonDown的y值
--		拖动纵向进度条的滑块				self	“OnVScroll”	4	onMouseMove的y值
function OnVScroll(scrollBar, eventName, ntype, newpos)
	local owner = scrollBar:GetOwnerControl()
	local attr = owner:GetAttribute()
	--XLMessageBox("face"..ntype)
	--if type == 4 then
		attr.top = -newpos
		
		owner:SetListPos()
	--end
end

function OnScrollBarMouseWheel(self,func,x,y,distance)
	self:GetOwnerControl():MouseWheel(distance)
end

function OnUserFaceDbClick(self)
	local userItem = self:GetOwnerControl()
	local attr  =	userItem:GetAttribute()

	local deptCtrl = userItem:GetOwnerControl()
	local deptUserCtrl = deptCtrl:GetOwnerControl()
	
	deptUserCtrl:FireExtEvent("OnUserItemDbClick",attr.userId)
end

function OnUserDbClick(self,x,y,flags)

	local attr  = self:GetAttribute()

	local deptCtrl = self:GetOwnerControl()
	local deptUserCtrl = deptCtrl:GetOwnerControl()
	
	deptUserCtrl:FireExtEvent("OnUserItemDbClick",attr.userId)

end

function OnSendMsg(self)
	local hostWnd = self:GetOwner():GetBindHostWnd()
	local userItem = hostWnd:GetUserData()
	if userItem == nil then
		return
	end
	
	local attr  = userItem:GetAttribute()

	local deptCtrl = userItem:GetOwnerControl()
	local deptUserCtrl = deptCtrl:GetOwnerControl()
	
	deptUserCtrl:FireExtEvent("OnUserItemDbClick",attr.userId)
end

function OnSendMail(self)
	local hostWnd = self:GetOwner():GetBindHostWnd()
	local userItem = hostWnd:GetUserData()
	if userItem == nil then
		return
	end
	
	local attr  = userItem:GetAttribute()
	local appClass = XLGetObject("XiaoP.Wnds.App")
	local left,top,right,bottom = appClass:MailSend(attr.userId.."@yt-inc.com")
	
end

function OnDelContact(self)
	local hostWnd = self:GetOwner():GetBindHostWnd()
	local userItem = hostWnd:GetUserData()
	if userItem == nil then
		return
	end
	
	local attr  = userItem:GetAttribute()
	local deptCtrl = userItem:GetOwnerControl()
	local deptUserCtrl = deptCtrl:GetOwnerControl()
	deptUserCtrl:FireExtEvent("OnUserItemDelete",attr.userId)
	
end


function OnUserRClick(self,x,y)
	SetUserSelected(self)
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local parent = hostwndManager:GetHostWnd("XiaoP.Main.Wnd.Instance")
	local parentHandle = parent:GetWndHandle()
	
	local left,top,right,bottom = parent:GetWindowRect()
	local l,t,r,b = self:GetObjPos()
	--local attr = self:GetAttribute()
	
	local obj = XLGetGlobal("xunlei.MenuHelper")
					
	obj:ShowMenu("XiaoP.DeptUserListMenu.Wnd", "XiaoP.DeptUserList.Menu", "XiaoP.DeptListMenu", parentHandle,nil,nil,self)
end

function OnClickMenu(self)
	
end

--[[function OnPopupMenu(self)
    local menuTree = self:GetBindUIObjectTree()
	local bkg = menuTree:GetUIObject("bkg")
	
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")	
	local aniAlpha = aniFactory:CreateAnimation("AlphaChangeAnimation")
	aniAlpha:BindRenderObj(bkg)
	aniAlpha:SetTotalTime(256)
	aniAlpha:SetKeyFrameAlpha(0,255)
	menuTree:AddAnimation(aniAlpha)
	aniAlpha:Resume()
end]]
