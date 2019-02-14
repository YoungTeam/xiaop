function OnInitControl(self)
	
		--XLMessageBox("f")
		
	local layout = self:GetControlObject("layout")
	local attr = self:GetAttribute()
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	

	if attr.type == "gif" then
		local gif = objFactory:CreateUIObject("gif","SeqImageObject")
		--gif:SetGifResID("test.gif")
		gif:SetLoop(true)   
		gif:SetObjPos(0, 0, "father.width", "father.height")
		layout:AddChild(gif)		
	else
		local pic = objFactory:CreateUIObject("image","ImageObject")
		pic:SetDrawMode(1)
		pic:SetObjPos(0, 0, "father.width", "father.height")
		layout:AddChild(pic)
	end
	--XLMessageBox("f")
end

function SetId(self, id)
	local attr = self:GetAttribute()
	attr.id = id
end

function GetId(self)
	local attr = self:GetAttribute()
	return attr.id
end

function SetPos(self, pos)
	local attr = self:GetAttribute()
	attr.pos = pos
end

function GetPos(self)
	local attr = self:GetAttribute()
	return attr.pos
end

function SetWidth(self,width)
	local attr = self:GetAttribute()
	attr.width = width
end

function GetWidth(self)
	local attr = self:GetAttribute()
	return attr.width
end

function SetHeight(self,height)
	local attr = self:GetAttribute()
	attr.height = height
end

function GetHeight(self)
	local attr = self:GetAttribute()
	return attr.height
end

function SetXImage(self,image)
	local attr = self:GetAttribute()
	local imgObj = nil
	if attr.type ~= "gif" then
		imgObj = self:GetControlObject("image")
		imgObj:SetBitmap(image)
	else	
		imgObj = self:GetControlObject("gif")
		imgObj:SetGif(image)
		imgObj:Play()		
	end
end

function GetXImage(self)
	local attr = self:GetAttribute()
	local imgObj = nil
	if attr.type ~= "gif" then
		imgObj = self:GetControlObject("image")
		return imgObj:GetBitmap()
	else
		imgObj = self:GetControlObject("gif")
		return imgObj:GetGif()
	end
	
	return nil
end

function SetType(self,value)
	local attr = self:GetAttribute()
	attr.type = value
end

function GetType(self)
	local attr = self:GetAttribute()
	return attr.type
end

function SetFrom(self,from)
	local attr = self:GetAttribute()
	attr.from = from
end

function GetFrom(self)
	local attr = self:GetAttribute()
	return attr.from
end

function OnLButtonDbClick(self)

	local appClass = XLGetObject("XiaoP.Wnds.App")
	appClass:openImageView(self:GetId(),self:GetFrom())
	
end


