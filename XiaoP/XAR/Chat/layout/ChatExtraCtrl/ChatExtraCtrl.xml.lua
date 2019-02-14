function OnInitControl(self)

	local attr = self:GetAttribute()
	local historyLayout = self:GetObject("chat.extra.history.layout")
	local infoLayout = self:GetObject("chat.extra.info.layout")
	local groupinfoLayout = self:GetObject("chat.extra.groupinfo.layout")
		
	historyLayout:SetVisible(false)
	historyLayout:SetChildrenVisible(false)
	
	if attr.chatType =="chat" then
		infoLayout:SetVisible(true)
		infoLayout:SetChildrenVisible(true)
		
		groupinfoLayout:SetVisible(false)
		groupinfoLayout:SetChildrenVisible(false)		
	else
		infoLayout:SetVisible(false)
		infoLayout:SetChildrenVisible(false)
		
		groupinfoLayout:SetVisible(true)
		groupinfoLayout:SetChildrenVisible(true)		
	end
	
	self:FireExtEvent("OnCtrlInit")
end

function UpdateInfo(self,data)
	--XLMessageBox(chatExtra:GetID())
	local attr = self:GetAttribute()
	if attr.chatType == "chat" then
		local username = self:GetObject("chat.info.username.text")
		local userno = self:GetObject("chat.info.userno.text")
		local dept = self:GetObject("chat.info.dept.text")
		local mobile = self:GetObject("chat.info.mobile.text")
		local phone = self:GetObject("chat.info.phone.text")
		local mail = self:GetObject("chat.info.mail.text")
		local signature = self:GetObject("chat.info.signature.text")
		
		if data.userName == nil then 
			return 
		end
		username:SetText(data.userName.."的个人信息")
		userno:SetText(data.userNo)
		dept:SetText(data.deptName)
		mobile:SetText(data.mobile)
		phone:SetText(data.telExt)
		mail:SetText(data.userId)
		signature:SetText(data.introduction)
	else 
		local groupboard = self:GetObject("chat.groupinfo.board")
		if data.groupBoard == nil or data.groupBoard == "" then
			data.groupBoard = "暂无公告"
			groupboard:SetTextColorResID("chatwnd.groupinfo.board.none.color")
		end
		--local groupManager = data.groupManager
		local memberListCtr = self:GetObject("chat.groupinfo.members")
		local memberAttr = memberListCtr:GetAttribute()
		memberAttr.groupManager = data.groupManager
		
		groupboard:SetText(data.groupBoard)
		
		
	end
end

function UpdateMember(self,userData)
	local memberListCtr = self:GetObject("chat.groupinfo.members")
	local attr = memberListCtr:GetAttribute()
	
	for k,user in pairs(attr.data) do
		if user.userId == userData.userId then
			attr.data[k] = userData
			memberListCtr:CreateList(attr.data)
			return
		end
	end
end


function CreateMembersList(self,data)
	local memberListCtr = self:GetObject("chat.groupinfo.members")
	memberListCtr:CreateList(data)
end

function SwitchLayout(self)
	local attr = self:GetAttribute()
	local historyLayout = self:GetObject("chat.extra.history.layout")
	
	local infoLayout = nil 
	if attr.chatType == "chat" then
		infoLayout = self:GetObject("chat.extra.info.layout")
	else
		infoLayout = self:GetObject("chat.extra.groupinfo.layout")
	end
	
	local owner = self:GetOwner()
	local hostWnd = owner:GetBindHostWnd()
	local left,top,right,bottom = hostWnd:GetWindowRect()
	local width,height = right- left,bottom-top
	
	
	
	--local l,t,r,b = self:GetObjPos()
	--597 750
	--XLMessageBox(""..width)
	local status = ""
	if historyLayout:GetVisible() == true then
		
		historyLayout:SetVisible(false)
		historyLayout:SetChildrenVisible(false)
		
		infoLayout:SetVisible(true)
		infoLayout:SetChildrenVisible(true)
		
		status = "info"
		
		hostWnd:SetMinTrackSize(594,516)
		hostWnd:Move(left,top,width-(attr.historyWidth-attr.infoWidth),height)
		
		self:SetObjPos2("father.width-166",61,166,"father.height-height-1")
		--self:SetObjPos()
		--166
	else
		historyLayout:SetVisible(true)
		historyLayout:SetChildrenVisible(true)
		
		infoLayout:SetVisible(false)
		infoLayout:SetChildrenVisible(false)	
		
		status = "history"
		
		hostWnd:SetMinTrackSize(763,516)
		hostWnd:Move(left,top,width+(attr.historyWidth-attr.infoWidth),height)
		self:SetObjPos2("father.width-335",61,335,"father.height-height-1")
		--335
	end
	
	return status
end

function UpdatePageInfo(self,data)
	local pageInfo = self:GetObject("chat.extra.history.info.page")
	pageInfo:SetText("第 "..(data.totalPages-data.curPage+1).."/"..data.totalPages.." 页")
end

function OnHistoryFirstClick(self)
	self:GetOwnerControl():FireExtEvent("OnHistoryFirstClick")
end

function OnHistoryPrevClick(self)
	self:GetOwnerControl():FireExtEvent("OnHistoryPrevClick")
end

function OnHistoryNextClick(self)
	self:GetOwnerControl():FireExtEvent("OnHistoryNextClick")
end

function OnHistoryLastClick(self)
	self:GetOwnerControl():FireExtEvent("OnHistoryLastClick")
end

function OnLinkNotify(self, eventName, rangeMin, rangeMax)
	local richedit = self:GetControlObject("edit")
	
	local url = richedit:GetTextRange(rangeMin, rangeMax)
	local appClass = XLGetObject("XiaoP.Wnds.App")	
	appClass:OpenUrl(url)
end

