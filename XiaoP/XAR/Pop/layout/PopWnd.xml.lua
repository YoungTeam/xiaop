local popData = nil

function OnInitControl(self)

end

function OnInitTxtPopWndInfo(self)
	local objTree = self:GetOwner()
	local left, bottom, right, top = self:GetObjPos()
	
	local timeStr = os.time()
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local popHostWnd = hostWndManager:GetHostWnd("XiaoP.PopWnd."..timeStr)
	if popHostWnd == nil then
		return
	end
	
	local title = self:GetObject("tree:pop.title")
	local txtTitle  = self:GetObject("tree:txt.title")
	local txtContent  = self:GetObject("tree:txt.content")
	local img = self:GetObject("tree:img")
	
	local data = popHostWnd:GetUserData()
	if data ~= nil then
		title:SetText(data.title)
		txtTitle:SetText(data.txtTitle)
		txtContent:SetText(data.txtContent)
	end
	
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	if aniFactory then
		local posAnim = aniFactory:CreateAnimation("PosChangeAnimation")
		posAnim:BindObj(self)
		posAnim:SetKeyFramePos(left, top, left, bottom)
		posAnim:SetTotalTime(2000)
		--[[
		local cookie = posAnim:AttachListener(true,function (self,oldState,newState)
				if newState == 4 then
					self:SetObjPos(left, top, right, bottom)
				end
			end)]]
		objTree:AddAnimation(posAnim)
		posAnim:Resume()
	end		
end

function OnInitImgTxtPopWndInfo(self)
	local objTree = self:GetOwner()
	local left, bottom, right, top = self:GetObjPos()
	
	local timeStr = os.time()
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local popHostWnd = hostWndManager:GetHostWnd("XiaoP.PopWnd."..timeStr)
	if popHostWnd == nil then
		return
	end
	
	local title = self:GetObject("tree:pop.title")
	local txtTitle  = self:GetObject("tree:txt.title")
	local txtContent  = self:GetObject("tree:txt.content")
	local img = self:GetObject("tree:img")
	
	local data = popHostWnd:GetUserData()
	if data ~= nil then
		title:SetText(data.title)
		txtTitle:SetText(data.txtTitle)
		txtContent:SetText(data.txtContent)
		
		local ImageFactory = XLGetObject("XiaoP.Wnds.XImage.Factory")
		imageClass = ImageFactory:CreateInstance()
		imageClass:AttachImgListener(
			function(r)
				img:SetBitmap(r)
			end
		)
		imageClass:GetImgByUrl(data.imgUrl)
	end
	
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	if aniFactory then
		local posAnim = aniFactory:CreateAnimation("PosChangeAnimation")
		posAnim:BindObj(self)
		posAnim:SetKeyFramePos(left, top, left, bottom)
		posAnim:SetTotalTime(2000)
		--[[
		local cookie = posAnim:AttachListener(true,function (self,oldState,newState)
				if newState == 4 then
					self:SetObjPos(left, top, right, bottom)
				end
			end)]]
		objTree:AddAnimation(posAnim)
		posAnim:Resume()
	end		
end

function OnInitNovaPopWndInfo(self)
	
	
	local objTree = self:GetOwner()
	local left, bottom, right, top = self:GetObjPos()
	
	local timeStr = os.time()
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local popHostWnd = hostWndManager:GetHostWnd("XiaoP.PopWnd."..timeStr)
	if popHostWnd == nil then
		return
	end
	
	--数据绘制
	local title = self:GetObject("tree:pop.title")
	local txtTitle  = self:GetObject("tree:pop.txt.title")
	local userFace = self:GetObject("tree:userFace")
	local novabeginner  = self:GetObject("tree:pop.nova.beginner")
	local novatime  = self:GetObject("tree:pop.nova.time")

	local novaentry  = self:GetObject("tree:pop.nova.entry")
	local novapropname  = self:GetObject("tree:pop.nova.propname")
	local novahandler  = self:GetObject("tree:pop.nova.handler")
	local novaact  = self:GetObject("tree:pop.nova.act")
	
	
	
	
	local data = popHostWnd:GetUserData()
	if data ~= nil then
		title:SetText(data.title)
		novabeginner:SetText(data.beginnerName)
		novatime:SetText(data.arriveTime)
		novaentry:SetText("工单名称："..data.entryTitle)
		novahandler:SetText("上环节处理人："..data.handlerName)
		novapropname:SetText("流程名称："..data.propName)
		novaact:SetText("待办环节："..data.actTitle)

		local ImageFactory = XLGetObject("XiaoP.Wnds.XImage.Factory")
		imageClass = ImageFactory:CreateInstance()
		imageClass:AttachImgListener(
			function(r)
				userFace:SetBitmap(r)
				--faceReal:SetWindow(r)
			end
		)
		
		imageClass:GetFace(data.draftId,40,40,1)
		
	end
	
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	if aniFactory then
		local posAnim = aniFactory:CreateAnimation("PosChangeAnimation")
		posAnim:BindObj(self)
		posAnim:SetKeyFramePos(left, top, left, bottom)
		posAnim:SetTotalTime(2000)
		--[[
		local cookie = posAnim:AttachListener(true,function (self,oldState,newState)
				if newState == 4 then
					self:SetObjPos(left, top, right, bottom)
				end
			end)]]
		objTree:AddAnimation(posAnim)
		posAnim:Resume()
	end			

end

function Popup(self,data,popType)
	
	--XLMessageBox(self:GetID())
	local timeStr = os.time()
	
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local tipsHostWndTemplate = templateMananger:GetTemplate("XiaoP.Pop.Wnd","HostWndTemplate")
	local tipsHostWnd = tipsHostWndTemplate:CreateInstance("XiaoP.PopWnd."..timeStr)

	--加载用户信息
	local appClass = XLGetObject("XiaoP.Wnds.App")
	local left,top,right,bottom = appClass:GetWorkArea()
	if popType == "nova" then
		tipsHostWnd:SetTipTemplate("xiaop.popwnd.nova.panel")
	elseif popType == "txt" then
		tipsHostWnd:SetTipTemplate("xiaop.popwnd.text.panel")
	elseif popType == "imgTxt" then
		tipsHostWnd:SetTipTemplate("xiaop.popwnd.imgtext.panel")
	end
	
	
	tipsHostWnd:SetPosition(right-312-50,bottom-206)
	tipsHostWnd:SetUserData(data)
	--tipsHostWnd:SetPosition(150,206)
	
	if data.delayCancel ~= nil and data.delayCancel  >= 0 then
		tipsHostWnd:Popup()
	end
	
	if data.delayCancel ~= nil and data.delayCancel  > 0 then
		tipsHostWnd:DelayCancel(data.delayCancel) 
	end
end

function OnOpen(self)
	local owner = self:GetOwner()
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostWnd = owner:GetBindHostWnd()
	
	local data = hostWnd:GetUserData()
	
	if data.link ~= nil and data.link ~= "" then
		local appClass = XLGetObject("XiaoP.Wnds.App")	
		appClass:OpenUrl(data.link)
	end
	
	hostWnd:Cancel()
end

function OnClose(self)
	local owner = self:GetOwner()
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostWnd = owner:GetBindHostWnd()
	
	hostWnd:Cancel()
end

function OnDestroy(self)
	--local timeId = self:GetUserData()
	
	
end


