function OnBind(self)
	local attr = self:GetAttribute()
	attr.top = 0
end

--[[
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

end]]


--DeptUser
--[[
function AddDeptUser(self,data)

	--local ctrl = self:GetOwnerControl()
	--local attr = ctrl:GetAttribute()
	local deptAttr = self:GetAttribute()
	
	local top = 0
	local index = #deptAttr.allUserItem+1
	if #deptAttr.allUserItem > 0 then
		local lastUserItem = deptAttr.allUserItem[#deptAttr.allUserItem]
		local l,t,r,b = lastUserItem:GetObjPos()
		top = b
	end

	if deptAttr.allUserItemIndexer[data.userId] ~=nil then 
		XLMessageBox("already exist")
		return
	end
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local newUserItem = objFactory:CreateUIObject("deptUserList.userItem."..data.userId,"XiaoP.DeptUserList.UserItem")		
	local userItemAttr = newUserItem:GetAttribute()
			
	userItemAttr.index = index
	userItemAttr.userId = data.userId
	userItemAttr.userName = data.userName
	userItemAttr.data = data
	userItemAttr.selected = false
	
	newUserItem:UpdateUser()
			
	deptAttr.allUserItem[index] = newUserItem	
	deptAttr.allUserItemIndexer[data.userId] = newUserItem	
	
	newUserItem:SetObjPos(0,top,"father.width", top + 70)
	
	local users = self:GetObject("dept.users")
	users:AddChild(newUserItem)
	
	
	deptAttr.usersHeight = 70 * index
	deptAttr.height = 30 + deptAttr.usersHeight
	deptAttr.expand = false
	
	--ToggleDept(self)
	
	local left,top,right,bottom = self:GetObjPos()
	self:SetObjPos(left,top,right,top + deptAttr.height)
	
	for k,userItem in pairs(deptAttr.allUserItem) do
		userItem:SetVisible(true)
		userItem:SetChildrenVisible(true)		
	end	
	
	local ownControl = self:GetOwnerControl()
	local listAttr = ownControl:GetAttribute()
	
	local total = table.getn(listAttr.allDeptItem)
	if deptAttr.index < total then 
		for i=deptAttr.index+1,total do
			local thisDept = listAttr.allDeptItem[i]
			local a,b,c,d = thisDept:GetObjPos()
			--XLMessageBox(""..(b+70))
			thisDept:SetObjPos(a,b+70,"father.width",d+70)
		end
	end
	
	self:GetOwnerControl():UpdateScroll()
end
]]
function UpdateGroup(self)
	local attr = self:GetAttribute()
	local name = self:GetControlObject("group.name")

	local icon =  self:GetObject("group.icon")
	name:SetText(attr.name)
	
	if attr.type=="mail" then
		icon:SetResID("mail.icon")
	elseif attr.type =="dept" then
		icon:SetResID("dept.icon")	
	end
end

function UpdateGroupInfo(self,data)
	local attr = self:GetAttribute()
	for k,categoryItem in pairs(attr.allCategoryItem) do
		local categoryAttr = deptItem:GetAttribute()
		local groupItem = categoryAttr.allGroupItem[data.groupId]
		if groupItem ~= nil then
			local groupAttr = groupItem:GetAttribute()
			groupAttr.data = data
			UpdateGroup(groupItem)
			return
		end
	end
end

function SetGroupSelected(groupItem)
	local groupAttr = groupItem:GetAttribute()
	groupAttr.selected = true
	
	local bkg = groupItem:GetObject("group.bkg")
	bkg:SetSrcColor("RGBA(253,238,227,255)")

	
	local category = groupItem:GetOwnerControl()
	local list = category:GetOwnerControl()
	local attr = list:GetAttribute()
	
	--pre selected
	local oldSelGroup = attr.selectGroupItem
	if oldSelGroup ~= nil then	
		if oldSelGroup:GetID() == groupItem:GetID() then
			return
		end
		oldSelGroup:GetAttribute().selected = false
		OnGroupLeave(oldSelGroup)
	end
	
	attr.selectGroupItem = groupItem
	
end

function TwinkleCategory(categoryItem)
	
	local attr = categoryItem:GetAttribute()	
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	
	--local groupItems = attr.allGroupItem
	
	local twinkle = false
	
	for k,groupItem in pairs(attr.allGroupItem) do
		local uAttr = groupItem:GetAttribute()
		if uAttr.twinkleFaceTimer ~= nil then
			twinkle = true
			break
		end
	end
	
	local name = categoryItem:GetObject("category.name")
	if twinkle == false then
		if attr.twinkleCategoryTimer ~= nil then
			name:SetVisible(true)
			timerManager:KillTimer(attr.twinkleCategoryTimer)
			attr.twinkleCategoryTimer = nil
		end	
		return 
	else
		if attr.twinkleCategoryTimer ~= nil then
			return
		end
	end
	
	
	function twinkleCategoryTimer()
		if name:GetVisible() then
			name:SetVisible(false)
		else
			name:SetVisible(true)
		end
	end
	
	attr.twinkleCategoryTimer = timerManager:SetTimer( twinkleCategoryTimer, 500)
	
end

function TwinkleGroup(self,groupId,twinkle)

	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostWnd = hostwndManager:GetHostWnd("XiaoP.GroupChatWnd." .. groupId)
		
	if hostWnd then
		twinkle = false
	end

	local attr = self:GetAttribute()
	for k,categoryItem in pairs(attr.allCategoryItem) do
		local cateAttr = categoryItem:GetAttribute()
		if cateAttr.allGroupItemIndexer[groupId] ~= nil then
			TwinkleGroupItem(cateAttr.allGroupItemIndexer[groupId],twinkle)
			return
		end
	end
	
end

function TwinkleGroupItem(groupItem,twinkle)
	local attr = groupItem:GetAttribute()	
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	
	local face = groupItem:GetObject("group.icon")
	if twinkle == false then
		if attr.twinkleFaceTimer ~= nil then
			face:SetVisible(true)
			timerManager:KillTimer(attr.twinkleFaceTimer)
			attr.twinkleFaceTimer = nil
			TwinkleCategory(groupItem:GetOwnerControl())
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
	TwinkleCategory(groupItem:GetOwnerControl())
end

function OnGroupClick(self)

	SetGroupSelected(self)
	
	--[[
	local attr = self:GetAttribute()
	if attr.twinkleFaceTimer ~=nil then
		TwinkleUser(self,false)
	else
		TwinkleUser(self,true)
	end]]
	
end

function OnGroupHover(self)
	local attr = self:GetAttribute()
	if attr.selected then
		return
	end
	
	local bkg = self:GetObject("group.bkg")
	bkg:SetSrcColor("RGBA(254,244,237,255)")
end

function OnGroupLeave(self)
	local attr = self:GetAttribute()
	if attr.selected then
		return
	end
	
	local bkg = self:GetObject("group.bkg")
	bkg:SetSrcColor("RGBA(255,255,255,0)")
end


--DeptGroup
function UpdateCategory(self)
	local attr = self:GetAttribute()
	local status = self:GetControlObject("category.status")
	local name = self:GetControlObject("category.name")
	local groups = self:GetObject("category.groups")
	
	name:SetText(attr.name)
	
	if attr.expand == true then
		status:SetResID("userlist.expand")
		attr.height = 30+attr.usersHeight
	else
		status:SetResID("userlist.collapse")
		attr.height = 30
	end	

	local newTop = 0
	local itemHeight = 28
	
	if attr.expand == true then 
		for k,groupItem in pairs(attr.allGroupItem) do
			groupItem:SetObjPos(0,newTop,"father.width", newTop + itemHeight)
			newTop = newTop + itemHeight
			groups:AddChild(groupItem)
		end
	end
	
	local left,top,right,bottom = self:GetObjPos()
	if attr.index > 1 then
		local groupListCtrl = self:GetOwnerControl()
		local listAttr = groupListCtrl:GetAttribute()
		local lastItem = listAttr.allCategoryItem[attr.index-1]
		local a,b,c,d = lastItem:GetObjPos()
		top = d
	end

	self:SetObjPos(left,top,"father.width",top + 30 + newTop)
	
	self:GetOwnerControl():UpdateScroll()
	
end

function ClearGroupList(self)
	local attr = self:GetAttribute()
	
	for i = #attr.allCategoryItem, 1, -1 do
		table.remove(attr.allCategoryItem, i)
		
	end
	
	for j = #attr.allCategoryItemIndexer,1,-1 do
		table.remove(attr.allCategoryItemIndexer, j)
	end
	self:GetObject("bkg"):RemoveAllChild()
end

function CreateGroupList(self,categorysData)


	if categorysData == nil then
		return
	end
	
	local attr = self:GetAttribute()
	local newTop = 0
	local height = 30
	local idx = 1
	
	if attr.allCategoryItem == nil then
		attr.allCategoryItem = {}
		attr.allCategoryItemIndexer = {}
	else
		self:ClearGroupList()
	end
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	
	for idx,categoryData in pairs(categorysData) do
			
			local categoryItem = objFactory:CreateUIObject("groupList.categoryItem."..idx,"XiaoP.GroupList.CategoryItem")	
			local categoryItemAttr = categoryItem:GetAttribute()
		
			categoryItemAttr.index = idx	
			categoryItemAttr.id = categoryData.id
			categoryItemAttr.name = categoryData.name			
			categoryItemAttr.expand = categoryData.expand
			
			categoryItemAttr.groupsHeight = 28 * table.getn(categoryData.groups)
			
			--users
			categoryItemAttr.allGroupItem = {}
			categoryItemAttr.allGroupItemIndexer = {}	
			
			--更新dept信息
			local status = categoryItem:GetControlObject("category.status")
			local name = categoryItem:GetControlObject("category.name")
			local groups = categoryItem:GetObject("category.groups")
			local info = categoryItem:GetObject("category.info")
			
			name:SetText(categoryItemAttr.name)
			local width = name:GetTextExtent()
			info:SetObjPos2(32+width+10,9,150,20)
			info:SetText(#categoryData.groups)
			
			if categoryItemAttr.expand == true then
				status:SetResID("userlist.expand")
				categoryItemAttr.height = 30+categoryItemAttr.groupsHeight
			else
				status:SetResID("userlist.collapse")
				categoryItemAttr.height = 30
			end	
			
			--添加groups
			local newTopGroup = 0
			for k,v in pairs(categoryData.groups) do
	
				local newGroupItem = objFactory:CreateUIObject("groupList.groupItem."..v.groupId,"XiaoP.GroupList.GroupItem")		
				local itemAttr = newGroupItem:GetAttribute()
						
				itemAttr.index = k
				
				
				itemAttr.id = v.groupId
				itemAttr.name = v.groupName
				itemAttr.type = v.groupType
				itemAttr.data = v
						
				itemAttr.selected = false
				
				newGroupItem:UpdateGroup()
						
				categoryItemAttr.allGroupItem[k] = newGroupItem	
				categoryItemAttr.allGroupItemIndexer[v.groupId] = newGroupItem	
				
				
				newGroupItem:SetObjPos(0,newTopGroup,"father.width", newTopGroup + 28)
				newTopGroup = newTopGroup + 28
				groups:AddChild(newGroupItem)
				newGroupItem:SetVisible(categoryItemAttr.expand)
				newGroupItem:SetChildrenVisible(categoryItemAttr.expand)	
			end			

			attr.allCategoryItem[idx] = categoryItem			
			categoryItem:SetObjPos(0,newTop,"father.width",newTop + categoryItemAttr.height)
			newTop = newTop+categoryItemAttr.height 
			self:GetObject("bkg"):AddChild(categoryItem)	
					
	end
	
	self:UpdateScroll()
	
end

--[[
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
	deptItemAttr.usersHeight = 70 * table.getn(deptData.users)
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

end]]

function ToggleCategory(categoryItem)
	local gStatus = categoryItem:GetObject("category.status")
	local gSubs = categoryItem:GetObject("category.groups")
	local attr = categoryItem:GetAttribute()
	local left,top,right,bottom = categoryItem:GetObjPos()
	
	
	attr.expand = not attr.expand
	
	if attr.expand == true then
		gStatus:SetResID("userlist.expand")
		attr.height = 30+attr.groupsHeight
	else 
		gStatus:SetResID("userlist.collapse")
		attr.height = 30
	end	
	
	categoryItem:SetObjPos(left,top,right,top + attr.height)
	
	for k,groupItem in pairs(attr.allGroupItem) do
		groupItem:SetVisible(attr.expand)
		groupItem:SetChildrenVisible(attr.expand)		
	end	
	
	local ownControl = categoryItem:GetOwnerControl()
	local listAttr = ownControl:GetAttribute()
	
	local total = table.getn(listAttr.allCategoryItem)

	if attr.index < total then 		
		for i=attr.index+1,total do
			local thisCategory = listAttr.allCategoryItem[i]
			local a,b,c,d = thisCategory:GetObjPos()
			if attr.expand == true then
				thisCategory:SetObjPos(a,b+attr.groupsHeight,"father.width",d+attr.groupsHeight)
			else
				thisCategory:SetObjPos(a,b-attr.groupsHeight,"father.width",d-attr.groupsHeight)
			end
		end
	end
	
	categoryItem:GetOwnerControl():UpdateScroll()
end

function OnCategoryClick(self)
	local categoryItem = self:GetFather()
	ToggleCategory(categoryItem)	
end

function OnCategoryHover(self)
	self:SetSrcColor("RGBA(254,244,237,255)")
end

function OnCategoryLeave(self)
	self:SetSrcColor("RGBA(255,255,255,0)")
end


function OnMouseWheel(self, x, y, distance)
	self:GetOwnerControl():MouseWheel(distance)
end

function OnGroupMouseWheel(self, x, y, distance)	
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
		top1 = top1 + 70
	elseif distance < 0 then
		top1 = top1 - 70
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
		attr.top = height - (range + top1) + attr.top - 70		
	end
	if attr.top > 0 then attr.top = 0 end
	self:SetListPos()
	local vscroll = self:GetControlObject("scrollCtrl")
	vscroll:SetScrollPos(-attr.top, true)
end

function UpdateScroll(self)
	local bkg = self:GetControlObject("bkg")

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

function OnGroupDbClick(self,x,y,flags)

	local attr  = self:GetAttribute()

	local categoryCtrl = self:GetOwnerControl()
	local groupListCtrl = categoryCtrl:GetOwnerControl()
	
	groupListCtrl:FireExtEvent("OnGroupItemDbClick",attr.data.groupId)

end
