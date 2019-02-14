function OnInitControl(self)
	local cancelBtn = self:GetObject("sugg.cancel.btn")
	local suggList = self:GetObject("sugg.list")
	
	local suggUsers = self:GetObject("sugg.users")
	local suggEdit = self:GetObject("sugg.edit")
	
	cancelBtn:SetVisible(false)
	
	suggList:SetVisible(false)
	suggList:SetChildrenVisible(false)
	
	
	local mainClass = XLGetObject("XiaoP.Wnds.MainWnd")
	
	mainClass:AttachSuggListener(
		function(r)			
			if r == "" then 
				return 
			end
			
			local json = XLGetGlobal("xunlei.json")
			local data = json.decode(r)
			if data.query == suggEdit:GetText() then 
				suggUsers:CreateList(data.list)
				local attr = suggUsers:GetAttribute()
				if attr.items[1] ~= nil then
					suggUsers:SelectItem(attr.items[1])
				end
			end
		end
	)
	
end

function OnInitUserItem(self)
	self:UpdateUser()
end

function OnUserClick(self)
	--self:SetSrcColor("RGBA(255,255,204,255)")
	local bkg = self:GetObject("user.bkg")
	bkg:SetSrcColor("RGBA(255,255,153,255)")
	--XLMessageBox("f")
	local attr = self:GetAttribute()

	
	local suggUsers = self:GetOwnerControl()
	local suggCtrl = suggUsers:GetOwnerControl()
	local suggList = suggCtrl:GetObject("sugg.list")
	local suggEdit = suggCtrl:GetObject("sugg.edit")
	
	if suggCtrl ~= nil then
		suggCtrl:FireExtEvent("OnUserItemClick",attr.data.userId)
		suggCtrl:SetFocus(true)
		suggList:SetVisible(false)
		suggList:SetChildrenVisible(false)
	end
end

function OnEditKeyDown(self,event, key,  repeatCount,  flags)
	local ctrl = self:GetOwnerControl()
	local suggUsers = ctrl:GetObject("sugg.users")
	local attr = suggUsers:GetAttribute()
	
	local count = #attr.items
	local idx = 0
	if attr.selectItem ~= nil then
		local itemAttr = attr.selectItem:GetAttribute()
		idx = itemAttr.index
	end
	
	if key == 38 then
		if idx == 1 then 
			idx = count
		else
			idx = idx - 1
		end
		
	elseif key == 40 then
		if idx == count then 
			idx = 1
		else
			idx = idx + 1
		end
	end
	
	if attr.items[idx] ~= nil then
		suggUsers:SelectItem(attr.items[idx])
	end
	
	
	if key == 13 then
		if attr.selectItem ~= nil then
			OnUserClick(attr.selectItem)
			ctrl:SetSuggUserCtrlFocus(false)
		end
	end
	
	

end



function OnItemSelected(ctrl,event,userItem)
	--local ctrl = self:GetOwnerControl()
	local ctrlAttr = ctrl:GetAttribute()
	
	local thisAttr = userItem:GetAttribute()
	thisAttr.selected = true
	for i,item in pairs(ctrlAttr.items) do
	
		local attr = item:GetAttribute()
		local bkg = item:GetObject("user.bkg")
		
		local normal  = item:GetObject("user.normal.layout")	
		local detail  = item:GetObject("user.detail.layout")
		
		if thisAttr.index == i then
			attr.height = 56
			bkg:SetObjPos(0,0,"father.width",56)
			bkg:SetSrcColor("RGBA(254,244,237,255)")
			
			normal:SetVisible(false)
			normal:SetChildrenVisible(false)		
			detail:SetVisible(true)
			detail:SetChildrenVisible(true)
		else
			attr.height = 30
			bkg:SetObjPos(0,0,"father.width",30)
			bkg:SetSrcColor("RGBA(255,255,255,255)")
			normal:SetVisible(true)
			normal:SetChildrenVisible(true)		
			detail:SetVisible(false)
			detail:SetChildrenVisible(false)
		end		
	end

	ctrl:UpdateList()
end

function OnUserHover(self)
	local ctrl = self:GetOwnerControl()
	--SetSelected(ctrl,self)	
	ctrl:SelectItem(self)
end

function OnUserLeave(self)
	local bkg = self:GetObject("user.bkg")
	bkg:SetSrcColor("RGBA(255,255,255,255)")
	local thisAttr = self:GetAttribute()
	thisAttr.selected = false
end

function UpdateUser(self)
	local attr = self:GetAttribute()
	if attr.data == nil then
		return
	else
		if type(attr.data) ~= "table" then
			return
		end
	end
	
	if attr.data.userName ==nil then
		return
	end
	
	local normal  = self:GetObject("user.normal.layout")	
	local detail  = self:GetObject("user.detail.layout")
	normal:SetVisible(true)
	normal:SetChildrenVisible(true)		
	detail:SetVisible(false)
	detail:SetChildrenVisible(false)
	
	local detailName = self:GetObject("user.detail.name")
	local normalName = self:GetObject("user.normal.name")
	local normalFace = self:GetObject("user.normal.face")
	local detailFace = self:GetObject("user.detail.face")
	local phone = self:GetObject("user.phone")
	local mobile = self:GetObject("user.mobile")
	
	local deptInfo = ""
	if attr.data.deptName~=nil and attr.data.deptName ~= "" then
		deptInfo = attr.data.deptName
		if attr.data.miniDeptName ~= nil and attr.data.miniDeptName ~= "" then
			deptInfo = deptInfo.."-"..attr.data.miniDeptName
		end
	end
	

	
	detailName:SetText(attr.data.userName.."("..deptInfo..")")
	normalName:SetText(attr.data.userName.."("..deptInfo..")")
	phone:SetText(attr.data.telExt)
	mobile:SetText(attr.data.mobile)

	
	--加载用户信息
	
	local ImageFactory = XLGetObject("XiaoP.Wnds.XImage.Factory")
	imageClass = ImageFactory:CreateInstance()
	
	imageClass:AttachImgListener(
		function(r)
			detailFace:SetBitmap(r)
			normalFace:SetBitmap(r)
			imageClass = nil
		end
	)
	
		
	--if attr.data.logoPhotoFlag == nil or attr.data.logoPhotoFlag == 0 then
		--imageClass:GetDefaultFace(40,40,attr.data.userStatus)
	--else
		imageClass:GetFace(attr.data.userId,40,40,attr.data.userStatus)	
	--end

end

function OnEditChange(self,event,text)
	local ownCtrl = self:GetOwnerControl()
	local suggUsers = ownCtrl:GetObject("sugg.users")
	local suggList = ownCtrl:GetObject("sugg.list")
	if text == "" then
	
		suggList:SetObjPos(0,35,"father.width",34)
		suggUsers:ClearList()
		return
	else
		suggList:SetObjPos(0,35,"father.width","father.height+36")
	end
	ownCtrl:FireExtEvent("OnSuggEditChange", text)
	
end

function OnEditFocusChange(self,event,focus)
	if focus then
		local ownCtrl = self:GetOwnerControl()
		ownCtrl:SetSuggUserCtrlFocus(true)
	else
		self:SetState(3)
	end
end

function SetSuggUserCtrlFocus(ownCtrl,focus)

	 local suggIcon = ownCtrl:GetObject("sugg.icon")
	 local cancelBtn = ownCtrl:GetObject("sugg.cancel.btn")
	 local suggList = ownCtrl:GetObject("sugg.list")
	 local suggEdit = ownCtrl:GetObject("sugg.edit")
	 
	 local tip = ownCtrl:GetObject("sugg.list.tip.text")
	 
	 if focus then
		
		if suggEdit:GetText() == "       可在全公司范围内查找员工" then
			suggEdit:SetText("")
		else
			
		end
		suggIcon:SetVisible(false)
		cancelBtn:SetVisible(true)
		
		suggList:SetVisible(true)
		suggList:SetChildrenVisible(true)
		suggEdit:SetState(3)
	else
		
		cancelBtn:SetVisible(false)
		suggIcon:SetVisible(true)
		suggEdit:SetText("       可在全公司范围内查找员工")

		suggList:SetVisible(false)
		suggList:SetChildrenVisible(false)
		suggEdit:SetFocus(false)
		suggEdit:SetState(0)
	
	 end
	 
end

function OnSuggCancel(self)
	local ownCtrl = self:GetOwnerControl()
	ownCtrl:SetSuggUserCtrlFocus(false)
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
	
	--XLMessageBox(""..top.."|"..top)
	local attr = idCardCtrl:GetAttribute()
	attr.Left = hleft - 306
	attr.Top = htop+top-50
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