function SetButtonActive(self, button, active)
	local attr = self:GetAttribute()
	local btnAttr = button:GetAttribute()
	
	if active then
		button:SetNormalBkgTexture(attr.ActiveBtnBkgNormal)
		button:SetHoverBkgTexture(attr.ActiveBtnBkgHover)
		button:SetDownBkgTexture(attr.ActiveBtnBkgDown)
		button:SetDisableBkgTexture(attr.ActiveBtnBkgDisable)
		button:SetTextColorID("system.black")
		
		button:SetButtonStatus(3)
		
	else
		button:SetNormalBkgTexture(attr.BtnBkgNormal)
		button:SetHoverBkgTexture(attr.BtnBkgHover)
		button:SetDownBkgTexture(attr.BtnBkgDown)
		button:SetDisableBkgTexture(attr.BtnBkgDisable)
		button:SetTextColorID("system.gray")
		
		button:SetButtonStatus(0)
	end
end

function SetText(self,id,strText)
	local attr = self:GetAttribute()
	if not attr or not id then
		return
	end
	
	local obj = self:GetControlObject(id)
	if not obj then
		return
	end
	
	obj:SetText(strText)
end

--	active:bool 是否激活
function AddTabItem(self, id, text, tipText,icon,iconHover,iconDown, active)
	local objExist = self:GetControlObject(id)
	if objExist ~= nil then
		return
	end
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")

	local attr = self:GetAttribute()

	local bkgObj = self:GetControlObject("bkg")
	local btn = objFactory:CreateUIObject(id, "Thunder.ImageTextButton")
	
	local btnAttr = btn:GetAttribute()
	btnAttr.IconLeftPos = attr.IconLeftPos
	btnAttr.IconTopPos = attr.IconTopPos
	btnAttr.TextLeftPos = attr.TextLeftPos
	btnAttr.TextTopPos = attr.TextTopPos
	btnAttr.IconWidth = attr.IconWidth
	btnAttr.IconHeight = attr.IconHeight
	btnAttr.IconBitmapID = icon
	btnAttr.IconBitmapID_Hover = iconHover
	btnAttr.IconBitmapID_Down = iconDown
	
	btnAttr.Text = text
	btnAttr.TipText = tipText

	btnAttr.TextFontID = attr.TextFontID
	btnAttr.TextColorID = attr.TextColorID
	
	
	--[[
	local pos = 0
	
	if btnCount > 0 then
		local lastBtn = bkgObj:GetChildByIndex(btnCount - 1)
		local left, top, right, bottom = lastBtn:GetObjPos()
		pos = right + attr.ButtonInternalSpace
	end]]

	--XLMessageBox( attr.ButtonInternalSpace)

	local function OnButtonClick(btn)
		local id = btn:GetID()
		if id == attr.CurrentActiveTab then
			return
		end
		self:SetActiveTab(id)
	end
	btn:AttachListener("OnButtonClick", true, OnButtonClick)
	bkgObj:AddChild(btn)

	local btnCount = bkgObj:GetChildCount()
	--btn:SetObjPos(pos, 0, 0, 0 + attr.ButtonHeight)
	if btnCount == 3 then
		btn:SetObjPos2("father.width/3*"..(btnCount-1), 0, "father.width-father.width/3*2", 0 + attr.ButtonHeight)
	else
		btn:SetObjPos2("father.width/3*"..(btnCount-1), 0, "father.width/3", 0 + attr.ButtonHeight)
	end
	
	if active == true or
		(active == nil and attr.CurrentActiveTab == nil) then
		self:SetActiveTab(id, false)
	else
		SetButtonActive(self, btn, false)
	end
end



function RemoveTabItem(self, remove_id, active_id)
	local btn = self:GetControlObject(remove_id)
	if btn == nil then
		return
	end
	local bkgObj = self:GetControlObject("bkg")
	local attr = self:GetAttribute()
	local pos = 0
	local count = bkgObj:GetChildCount()
	for i = 0, count - 1 do
		local child = bkgObj:GetChildByIndex(i)
		local childID = child:GetID()
		if childID ~= remove_id then
			local childLeft, childTop, childRight, childBottom = child:GetObjPos()
			child:SetObjPos(pos, childTop, pos + attr.ButtonWidth, childBottom)
			pos = pos + attr.ButtonWidth + attr.ButtonInternalSpace
		end
	end
	bkgObj:RemoveChild(btn)
end





function SetActiveTab(self, tabID, fireEvent)
	local attr = self:GetAttribute()
	if attr.CurrentActiveTab == tabID then
		return
	end

	local btn = self:GetControlObject(tabID)
	if btn == nil then
		return
	end

	SetButtonActive(self, btn, true)
	
	local pre_active = attr.CurrentActiveTab
	if pre_active ~= nil then
		local btn = self:GetControlObject(pre_active)
		if btn == nil then
			return
		end
		SetButtonActive(self, btn, false)
	end
	
	attr.CurrentActiveTab = tabID
	if fireEvent ~= false then
		self:FireExtEvent("OnActiveTabChanged", tabID, pre_active)
	end
end


function OnInitTabCtrlBkg(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	bkg:SetTextureID(attr.BorderTexture)
end

function GetPage(self,instanceID)
	
	local attr = self:GetAttribute()
	if attr.Pages == nil then
		return nil
	end
	
	for k,v in pairs(attr.Pages) do
		if v.id == instanceID then
			return attr.Pages[k]
		end
	end
end

function AddPage(self,classID,instanceID)
	local attr = self:GetAttribute()
	if attr.Pages == nil then
		attr.Pages = {}
	end
	for k,v in pairs(attr.Pages) do
		if v.id == instanceID then
			return false
		end
	end
	
	local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local xarFactory = xarManager:GetXARFactory()
	local pageObj = xarFactory:CreateUIObject(instanceID,classID)
	
	attr.Pages[#(attr.Pages)+1] = {class=classID,id=instanceID,obj=pageObj}
	self:GetControlObject("bkg"):AddChild(pageObj)

	pageObj:SetVisible(false)
	pageObj:SetChildrenVisible(false)
	
	return true
end

function ActivePage(self,instanceID)
	local attr = self:GetAttribute()
	if attr.Pages == nil then
		return false
	end
	
	for k,v in pairs(attr.Pages) do
		if v.id == instanceID then
			if attr.selectPage == v then
				return true
			end
			
			
			if attr.selectPage ~= nil then
				attr.selectPage.obj:SetVisible(false)		
				attr.selectPage.obj:SetChildrenVisible (false)
				
				--self:GetControlObject("bkg"):RemoveChild(attr.selectPage.obj)
				--attr.selectPage.obj = nil
			end
			
			attr.selectPage = v
			--self:GetControlObject("bkg"):AddChild(v.obj)
			v.obj:SetVisible(true)
			v.obj:SetChildrenVisible(true)
			
			return true
		end
	end
	
	return false
end
