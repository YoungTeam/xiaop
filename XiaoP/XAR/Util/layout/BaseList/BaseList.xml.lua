function OnBind(self)
	local attr = self:GetAttribute()
	attr.top = attr.Top
	self:SetObjPos(0,attr.top,"father.width","father.height")
end

function OnInitControl(self)
	local attr  = self:GetAttribute()
	attr.items = {}
	attr.selectItem = nil
	local bkg = self:GetObject("bkg")
	bkg:SetSrcColor(attr.bgColor)

end

function SelectItem(self,item)
	local attr = self:GetAttribute()
	attr.selectItem = item
	
	self:FireExtEvent("OnItemSelected",item)
end

function InsertItem(self,itemData,idx)
	local attr = self:GetAttribute()
	--local oldItems = attr.items
	local newItems = {}
	
	for i,item in pairs(attr.items) do
		if i == idx then
			local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
			local newItem = objFactory:CreateUIObject("item."..i,attr.itemCtrl)
			
			local itemAttr = newItem:GetAttribute()
			itemAttr.index = i
			itemAttr.data = data
			newItems[i] = newItem
			
		elseif i< idx then 
			newItems[i] = item
		elseif i>idx then
			local itemAttr = item:GetAttribute()
			itemAttr.index = i+1
			newItems[i+1] = item
		end	
	end
	
	attr.items = newItems
	UpdateList(self)
end

function UpdateList(listCtrl)
	local attr = listCtrl:GetAttribute()
	local newTop = 0
	local l,t,r,b = listCtrl:GetObjPos()
	--XLMessageBox(""..t)
	
	--for i,item in pairs(attr.items) do
	for i=1, #(attr.items)	do
		local item = attr.items[i]
		--XLMessageBox(""..i.."|"..#attr.items)
		local itemAttr = item:GetAttribute()
		itemAttr.index = i
		item:SetObjPos(0,newTop,"father.width",newTop+itemAttr.height)
		attr.itemHeight = itemAttr.height
		newTop = newTop+itemAttr.height	
	end

	--local left,top,right,bottom = listCtrl:GetObjPos()
	--listCtrl:SetObjPos(0,top,"father.width",top+newTop)
	
	listCtrl:UpdateScroll()
end

function ClearList(self)
	local attr = self:GetAttribute()
	attr.selectItem = nil
	local bkg = self:GetObject("bkg")
	bkg:RemoveAllChild()	
end


function CreateList(self,listData)
	local attr = self:GetAttribute()
	local bkg = self:GetObject("bkg")
	
	if listData == nil or attr.itemCtrl == nil then
		return
	end
	
	attr.data = listData
	attr.items = {}
	attr.selectItem = nil
	bkg:RemoveAllChild()

	for i,data in pairs(listData) do
		
		local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
		local newItem = objFactory:CreateUIObject("item."..i,attr.itemCtrl)
		
		local itemAttr = newItem:GetAttribute()
		itemAttr.index = i
		itemAttr.data = data
		itemAttr.selected = false
		attr.items[i] = newItem
		
		bkg:AddChild(newItem)	
	end
	
	UpdateList(self)

end

function OnMouseWheel(self, x, y, distance)
	self:MouseWheel(distance)
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
		top1 = top1 + attr.itemHeight
	elseif distance < 0 then
		top1 = top1 - attr.itemHeight
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
		attr.top = height - (range + top1) + attr.top - attr.itemHeight	
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

--[[
function UpdateUI(self)
	local attr = self:GetAttribute()
	
	local name = self:GetControlObject("name")
	local bkg = self:GetControlObject("bkg")
	local face = self:GetControlObject("face")


	name:SetText(attr.username)

	if attr.select then
		bkg:SetSrcColor("userlist.select")	
	else 
		bkg:SetSrcColor("RGBA(255,255,255,255)")
	end
	
	
	local appFactory = XLGetObject("XiaoP.Wnds.App.Factory")
	local appClass = appFactory:CreateInstance()

	
	local img = appClass:GetFace(attr.userid)
	face:SetBitmap(img)
	

end

function OnListMouseWheel(self,x,y,distance,flags)
	local attr = self:GetAttribute()
	local total = table.getn(attr.alluseritem)
		
	local scrollpos = 0
	for i=1,total,1 do
		local left,top,right,bottom = attr.alluseritem[i]:GetObjPos()
		local newtop = top+distance
		
		if i==1 then
			if top <= 0 and newtop >0 then
				newtop = 0
			elseif top < 0 and newtop < (0-(total-5)*70) then
				newtop = 0-(total-5)*70
			end
	
			distance = newtop-top
			scrollpos = 0 - newtop/70
		end



		bottom = bottom + distance
		attr.alluseritem[i]:SetObjPos(left,newtop,right,bottom)
	end

	local scrollctrl = self:GetFather():GetObject("scrollctrl")
	scrollctrl:SetScrollPos(scrollpos)
end

function OnUserItemDbClick(self)

	local user = {}
	user.userid =  "yangting"
	OnOpenChatWnd(user)
end

function OnOpenChatWnd(user)
	local XARManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local loaded = XARManager:IsXARLoaded("Chat")
	if not loaded then
		loaded = XARManager:LoadXAR("Chat")
	end
	
	--XLMessageBox(""..loaded)
	if loaded then
		local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
		local hostWnd = hostwndManager:GetHostWnd("ChatFrame" .. user.userid)
		
		if not hostWnd then
			local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
			local frameHostWndTemplate = templateMananger:GetTemplate("XiaoP.Chat.Wnd","HostWndTemplate")
			if frameHostWndTemplate then  
				local frameHostWnd = frameHostWndTemplate:CreateInstance("ChatFrame" .. user.userid)
				if frameHostWnd then
					local objectTreeTemplate = templateMananger:GetTemplate("XiaoP.Chat.Tree","ObjectTreeTemplate")
					if objectTreeTemplate then
						local uiObjectTree = objectTreeTemplate:CreateInstance("ChatObjectTree" .. user.userid)
						if uiObjectTree then
							frameHostWnd:BindUIObjectTree(uiObjectTree)
							frameHostWnd:SetUserData(user.userid)
							frameHostWnd:Create()
						end
					end
				end
			end
		end
	end	
end]]
