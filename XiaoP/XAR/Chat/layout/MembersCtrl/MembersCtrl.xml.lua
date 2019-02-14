function OnInitControl(self)

	--[[
	local membersList = self:GetObject("members.list")

	local  data = {}
	
	local user = {}
	user.userId = "yangting"
	user.userName = "杨挺"
	user.userNo = "114114"
	user.userStatus = 1
	
	
	local user1 = {}
	user1.userId = "zhangxiaowen"
	user1.userName = "张晓雯"
	user1.userNo = "114114"
	user1.userStatus = 1
	
	data[1] = user
	data[2] = user1
	]]
	--membersList:CreateList(data)
end

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
	
	if a.isManager then
		aWeight = -100
	end
	
	if b.isManager then
		bWeight = -100
	end
	
	return aWeight < bWeight
end


function CreateMembersList(self,data)
	local title = self:GetObject("members.title")
	local titleInfo = self:GetObject("members.title.info")
	local width = title:GetTextExtent()
	
	

	local attr = self:GetAttribute()
	attr.data = data
	local membersList = self:GetObject("members.list")
	table.sort(data,comps)
	membersList:CreateList(data)
	
	local online = 0
	for k,user in pairs(data) do
		if user.userStatus == 1 then
			online = online+1
		end
	end
	
	titleInfo:SetObjPos2(10+width+10,2,150,20)
	titleInfo:SetText("["..online.."/"..#data.."]")
end

function UpdateMember(self)
	local attr = self:GetAttribute()
	if attr.data == nil then
		return
	else
		if type(attr.data) ~= "table" then
			return
		end
	end
	
	local extraCtrl = self:GetOwnerControl():GetOwnerControl()
	local exAttr = extraCtrl:GetAttribute()
	--local attr = extraCtrl:GetAttribute()
	
	--XLMessageBox(exAttr.groupManager)
	
	
	local memberName = self:GetObject("user.name")
	local memberFace = self:GetObject("user.face")
	local manager = self:GetObject("manager")
	
	if attr.data.isManager then
		manager:SetVisible(true)
	end
	
	memberName:SetText(attr.data.userName.." ("..attr.data.userNo..")")
		--加载用户信息
	local ImageFactory = XLGetObject("XiaoP.Wnds.XImage.Factory")
	imageClass = ImageFactory:CreateInstance()
	imageClass:AttachImgListener(
		function(r)
			memberFace:SetBitmap(r)
		end
	)
	
	imageClass:GetFace(attr.data.userId,20,20,attr.data.userStatus)	
end

function OnInitMember(self)
	self:UpdateMember()
end
function OnMemberHover(self)
	local attr = self:GetAttribute()
	if attr.selected then
		return
	end
	
	local bkg = self:GetObject("user.bkg")
	bkg:SetSrcColor("RGBA(254,244,237,255)")
end
function OnMemberLeave(self)
	local attr = self:GetAttribute()
	if attr.selected then
		return
	end
	
	local bkg = self:GetObject("user.bkg")
	bkg:SetSrcColor("RGBA(255,255,255,0)")
end
function OnMemberClick(self)
	local bkg = self:GetObject("user.bkg")
	bkg:SetSrcColor("RGBA(253,238,227,255)")
	
	SetMemberSelected(self)
end

function OnMemberDbClick(self,x,y,flags)

	local attr  = self:GetAttribute()
	local ctrl = self:GetOwnerControl()
	
	if attr.data == nil then
		return
	end
	OpenChatWnd(attr.data.userId)

end

function OpenChatWnd(userId)
	if userId == nil then
		return
	end

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
			hostWnd:SetFocus(true)
		end
		hostWnd:BringWindowToTop(true)
	end
end

function OnMemberMouseWheel(self, x, y, distance)	
	self:GetOwnerControl():MouseWheel(distance)
end	

function SetMemberSelected(memberItem)
	local memberAttr = memberItem:GetAttribute()
	memberAttr.selected = true
	
	local list = memberItem:GetOwnerControl()
	local attr = list:GetAttribute()
	
	--pre selected
	local oldSelMember = attr.selectItem
	if oldSelMember ~= nil then	
		if oldSelMember:GetID() == memberItem:GetID() then
			return
		end
		oldSelMember:GetAttribute().selected = false
		OnMemberLeave(oldSelMember)
	end
	
	attr.selectItem = memberItem
end

