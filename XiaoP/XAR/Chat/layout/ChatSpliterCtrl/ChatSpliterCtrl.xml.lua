function OnInitControl(self)
	local attr = self:GetAttribute()
	
	local l,t,r,b  =self:GetObjPos()
	local height = b - t
	
	local part1 = self:GetObject("chat.spliter.part1")
	local bar = self:GetObject("chat.spliter.bar")
	local part2 = self:GetObject("chat.spliter.part2")
	local fontTools = self:GetObject("spliter.bar.font.tools")
	fontTools:SetVisible(false)
	fontTools:SetChildrenVisible(false)
			
	--XLMessageBox(""..attr.BarTop)
	part1:SetObjPos2(0,0,"father.width",attr.BarTop-1)
	bar:SetObjPos2(0,attr.BarTop,"father.width",attr.BarHeight)
	--part2:SetObjPos2(0,attr.BarTop+attr.BarHeight+1,"father.width",height-(attr.BarTop+attr.BarHeight))
	part2:SetObjPos(0,attr.BarTop+attr.BarHeight+1,"father.width","father.height")
	
	
	self:FireExtEvent("OnCtrlInit")
end

function UpdateControl(ctrl,y)
	local left,top,right,bottom = ctrl:GetObjPos()
	local height = bottom - top
	
	
	local part1 = ctrl:GetObject("chat.spliter.part1")
	local bar = ctrl:GetObject("chat.spliter.bar")
	local part2 = ctrl:GetObject("chat.spliter.part2")
	local attr = ctrl:GetAttribute()
	
	
	local l,t,r,b = bar:GetObjPos()
	
	local barNewTop = t+y
	
	if (height-barNewTop-attr.BarHeight-1) < 50 or barNewTop < 50 then
		return
	end
	
	local text = ctrl:GetObject("test.txt")
	text:SetText(""..barNewTop)
	
	
	part1:SetObjPos2(0,0,"father.width", barNewTop-1)
	bar:SetObjPos2(0,barNewTop,"father.width",attr.BarHeight)
	part2:SetObjPos(0,barNewTop+attr.BarHeight+1,"father.width","father.height")

end

function OnFontButtonClick(self)
	local ctrl = self:GetOwnerControl()	
	local attr = ctrl:GetAttribute()
	local fontTools = self:GetOwnerControl():GetObject("spliter.bar.font.tools")
	local barTools = self:GetOwnerControl():GetObject("spliter.bar.tools")
	
	if fontTools:GetVisible() then
			attr.BarHeight = 30
			self:SetButtonStatus(0)
			fontTools:SetVisible(false)
			fontTools:SetChildrenVisible(false)
			barTools:SetObjPos(0,0,"father.width",30)
			UpdateControl(ctrl,30)
	else
			attr.BarHeight = 60	
			self:SetButtonStatus(3)
			fontTools:SetVisible(true)
			fontTools:SetChildrenVisible(true)
			barTools:SetObjPos(0,30,"father.width",30)
			UpdateControl(ctrl,-30)
	end
	
end

function OnEmotionButtonClick(self)
	
	local left,top,right,bottom = self:GetAbsPos()
	self:GetOwnerControl():FireExtEvent("OnEmotionClick",left,top)

end

function OnCaptureButtonClick(self)
	self:GetOwnerControl():FireExtEvent("OnCaptureClick")
end

function OnHistoryButtonClick(self)
	self:GetOwnerControl():FireExtEvent("OnHistoryClick")
end

-----字体

function SelFontStyle(ctrl)
	local attr = ctrl:GetAttribute()
	ctrl:FireExtEvent("OnFontStyleClick",attr.isUStyle,attr.isIStyle,attr.isBStyle)
end

function OnFontStyleUButtonClick(self)
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	
	if attr.isUStyle == nil or attr.isUStyle == false then
		self:SetButtonStatus(3)
		attr.isUStyle = true
	else
		self:SetButtonStatus(0)
		attr.isUStyle = false
	end
	
	SelFontStyle(ctrl)
	
end

function OnFontStyleIButtonClick(self)
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	
	if attr.isIStyle == nil or attr.isIStyle == false then
		self:SetButtonStatus(3)
		attr.isIStyle = true
	else
		self:SetButtonStatus(0)
		attr.isIStyle = false
	end
	SelFontStyle(ctrl)
end

function OnFontStyleBButtonClick(self)
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	
	if attr.isBStyle == nil or attr.isBStyle == false then
		self:SetButtonStatus(3)
		attr.isBStyle = true
	else
		self:SetButtonStatus(0)
		attr.isBStyle = false
	end
	
	SelFontStyle(ctrl)
end

function OnFontColorButtonClick(self)
	self:GetOwnerControl():FireExtEvent("OnFontColorClick")
end

function OnSpliterBarDown(self)
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	
	attr.barDown = true
	self:SetCaptureMouse(true)

end

function OnSpliterBarUp(self)
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	
	attr.barDown = false
	
	self:SetCursorID("IDC_ARROW")	
	self:SetCaptureMouse(false)	
end

function OnSpliterBarMove(self,x,y)
	
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	
	if attr.barDown == true then
		UpdateControl(ctrl,y)
	end
	
	
end

function OnSpliterBarEnter(self)
	self:SetCursorID("IDC_SIZENS")		
end

function OnSendGetObjectText(self, strID,obj)

	local control = self:GetOwnerControl()
	local text, handled = control:FireExtEvent("OnSendGetObjectText",obj)
	return text, handled, true	
end

function OnSendGetObjectUniqueID(self,event,obj)
	local id = obj:GetID()
	--XLMessageBox(id)
	return id,nil,true
end

function OnLinkNotify(self, eventName, rangeMin, rangeMax)
	local richedit = self:GetControlObject("edit")
	
	local url = richedit:GetTextRange(rangeMin, rangeMax)
	local appClass = XLGetObject("XiaoP.Wnds.App")	
	appClass:OpenUrl(url)
end

