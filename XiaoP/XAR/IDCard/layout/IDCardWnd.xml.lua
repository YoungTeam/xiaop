function OnInitControl(self)
	
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local attr = self:GetAttribute()
		
	local XARManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local success = XARManager:LoadXAR("IDCard")

	local idCardHostWndTemplate = templateMananger:GetTemplate("XiaoP.IDCard.Wnd","HostWndTemplate")
	--attr.tipHostWndId = "Thunder.Tips.HostWnd" .. attr.tipId
	
	if idCardHostWndTemplate then
		local idCardHostWnd = idCardHostWndTemplate:CreateInstance("XiaoP.IDCard.Wnd.Instance")
		
		local function OnCreate(hostwnd)
			
			local objTree = hostwnd:GetBindUIObjectTree()
			if objTree ~= nil then
				attr.objTree = objTree   
				
				--[[
				local absLeft, absTop = self:GetAbsPos()
				local ownerTree = self:GetOwner()
				local mainWnd = ownerTree:GetBindHostWnd()
				XLMessageBox(""..absLeft)]]
				hostwnd:SetPosition(attr.Left,attr.Top)	
				
			end
				--XLMessageBox("f")
		end
	
	
		idCardHostWnd:SetTipTemplate("XiaoP.IDCard.Panel")
		--idCardHostWnd:DelayPopup(attr.DelayShow)	
		--idCardHostWnd:SetPosition(600,300)		
		idCardHostWnd:AttachListener("OnCreate", false, OnCreate)
		attr.hostWnd = idCardHostWnd
		
	end
	
	if self:GetVisible() == true and attr.EnableAutoHide == true then
		--attr.AutoHideTimer = timerManager:SetTimer( OnAutoHideTimer, attr.AutoHideInterval)
	end

--[[
				local arg = {...}
				local self = arg[1]
				local objTree = self:GetOwner()
				local bkg = self:GetObject("bkg")

			
				local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
				if aniFactory then
					local alphaAnim = aniFactory:CreateAnimation("AlphaChangeAnimation")
					alphaAnim:BindObj(bkg)
					alphaAnim:SetKeyFrameAlpha(0, 255)
					alphaAnim:SetTotalTime(1000)
					local cookie = alphaAnim:AttachListener(true,function (aniSelf,oldState,newState)
							if newState == 4 then
								--mirrorRoot:SetVisible(false)	
								--root:SetVisible(true)
								--root:SetChildrenVisible(true)	
							end
						end)
					objTree:AddAnimation(alphaAnim)
					alphaAnim:Resume()
				end	
				]]
end

function OnInitIDCard(self)
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local idCardHostWnd = hostWndManager:GetHostWnd("XiaoP.IDCard.Wnd.Instance")
	if idCardHostWnd == nil then
		
		return
	end
	
	local ctrl = idCardHostWnd:GetUserData()
	local attr = ctrl:GetAttribute()
	
	local face = self:GetObject("tree:userFace")
	local name = self:GetObject("tree:user.name")
	local desc = self:GetObject("tree:user.desc")
	local dept = self:GetObject("tree:user.dept")
	local phone = self:GetObject("tree:user.phone")
	local mobile = self:GetObject("tree:user.mobile")
	local mail = self:GetObject("tree:user.mail")
	
	
	local addBtn = self:GetObject("tree:addContact.btn")
	
	if(attr.data.isInContact) then
		addBtn:SetVisible(false)
	end
	--XLMessageBox(face:GetID())
	
	name:SetText(attr.data.userName.." (".. attr.data.userNo ..")")
	if attr.data.introduction == nil or attr.data.introduction == "" then
		desc:SetText("暂无个人介绍")
	else 
		desc:SetText(attr.data.introduction)
	end
	
	if attr.data.miniDeptName ~= nil and attr.data.miniDeptName ~= "" then
		dept:SetText(attr.data.deptName.." - "..attr.data.miniDeptName)
	else
		dept:SetText(attr.data.deptName)
	end
	
	
	phone:SetText(attr.data.telExt)
	mobile:SetText(attr.data.mobile)
	mail:SetText(attr.data.userId.."@yt-inc.com")
	
	local ImageFactory = XLGetObject("XiaoP.Wnds.XImage.Factory")
	imageClass = ImageFactory:CreateInstance()
	imageClass:AttachImgListener(
		function(r)
			face:SetBitmap(r)
			--faceReal:SetWindow(r)
		end
	)
	
	imageClass:GetFace(attr.data.userId)
	
end

function OnMouseEnter(self,x,y)
	
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local idCardHostWnd = hostWndManager:GetHostWnd("XiaoP.IDCard.Wnd.Instance")
	if idCardHostWnd == nil then
		
		return
	end
		
	local ctrl = idCardHostWnd:GetUserData()
	local attr = ctrl:GetAttribute()
	
	
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	
	if attr.OnCancelTimer ~= nil then
		
		timerManager:KillTimer(attr.OnCancelTimer)
		attr.OnCancelTimer = nil

	end
	idCardHostWnd:SetUserData(ctrl)
	
end

function OnMouseLeave(self,x,y)

	--self:GetObject("tree:user.dept"):SetText(""..x.."|"..y)
	if x <= 10 or x >=  300 or y >= 290 or y <= 10 then
		self:SetCaptureMouse(true)
	else
		self:SetCaptureMouse(false)	
	end
	
	if x > 0 and x < 312 and y > 0 and y < 305 then 
		return
	end
	
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local idCardHostWnd = hostWndManager:GetHostWnd("XiaoP.IDCard.Wnd.Instance")
	if idCardHostWnd == nil then	
		return
	end
	
	local ctrl = idCardHostWnd:GetUserData()
	local attr = ctrl:GetAttribute()
	
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	if attr.OnPopupTimer ~= nil then
		timerManager:KillTimer(attr.OnPopupTimer)
		attr.OnPopupTimer = nil
	end
	
	
	function OnCancelTimer( item, id )
		if id == attr.OnCancelTimer then
			timerManager:KillTimer(attr.OnCancelTimer)
			attr.OnCancelTimer = nil
			idCardHostWnd:Cancel()
			attr.OnShow = false
		end
	end
	
	attr.OnCancelTimer = timerManager:SetTimer( OnCancelTimer, attr.DelayCancelInterval)
	idCardHostWnd:SetUserData(ctrl)
end

function OnHostMouseHover(self)

	local attr = self:GetAttribute()
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local idCardHostWnd = hostWndManager:GetHostWnd("XiaoP.IDCard.Wnd.Instance")
	
	if idCardHostWnd == nil then	
		return
	end

	
	if attr.OnShow then
		idCardHostWnd:Cancel()
	end
	

	
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	
	if attr.OnCancelTimer ~= nil then
		timerManager:KillTimer(attr.OnCancelTimer)
		attr.OnCancelTimer = nil
	end
	
	function OnPopupTimer( item, id )
		if id == attr.OnPopupTimer then
			timerManager:KillTimer(attr.OnPopupTimer)
			attr.OnPopupTimer = nil

			idCardHostWnd:Popup()
			attr.OnShow = true
		end
	end
	
	attr.OnPopupTimer = timerManager:SetTimer( OnPopupTimer, attr.DelayPopupInterval)
	idCardHostWnd:SetUserData(self)
	
end
function OnHostMouseLeave(self)
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local idCardHostWnd = hostWndManager:GetHostWnd("XiaoP.IDCard.Wnd.Instance")
	if idCardHostWnd == nil then
		return
	end
	

	
	local attr = self:GetAttribute()
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	
	if attr.OnPopupTimer ~= nil then
		timerManager:KillTimer(attr.OnPopupTimer)
		attr.OnPopupTimer = nil
	end
	
	function OnCancelTimer( item, id )
		
		if id == attr.OnCancelTimer then
			timerManager:KillTimer(attr.OnCancelTimer)
			attr.OnCancelTimer = nil
			idCardHostWnd:Cancel()
			attr.OnShow = false
		end
	end
	
	attr.OnCancelTimer = timerManager:SetTimer( OnCancelTimer, attr.DelayCancelInterval)
		
	idCardHostWnd:SetUserData(self)
end

function OnAddContact(self)
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local idCardHostWnd = hostWndManager:GetHostWnd("XiaoP.IDCard.Wnd.Instance")
	if idCardHostWnd == nil then	
		return
	end
	
	local ctrl = idCardHostWnd:GetUserData()
	local attr = ctrl:GetAttribute()
	
	--加载用户信息
	local mainClass = XLGetObject("XiaoP.Wnds.MainWnd")
	mainClass:AddContact(attr.data.userId)
	
	local addBtn = self:GetObject("tree:addContact.btn")
	addBtn:SetVisible(false)
	
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local idCardHostWnd = hostWndManager:GetHostWnd("XiaoP.IDCard.Wnd.Instance")
	if idCardHostWnd == nil then	
		return
	end
	
	local ctrl = idCardHostWnd:GetUserData()
	local attr = ctrl:GetAttribute()
	
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	if attr.OnPopupTimer ~= nil then
		timerManager:KillTimer(attr.OnPopupTimer)
		attr.OnPopupTimer = nil
	end
	
	
	function OnCancelTimer( item, id )
		if id == attr.OnCancelTimer then
			timerManager:KillTimer(attr.OnCancelTimer)
			attr.OnCancelTimer = nil
			idCardHostWnd:Cancel()
			attr.OnShow = false
		end
	end
	
	attr.OnCancelTimer = timerManager:SetTimer( OnCancelTimer, attr.DelayCancelInterval)
	idCardHostWnd:SetUserData(ctrl)
end