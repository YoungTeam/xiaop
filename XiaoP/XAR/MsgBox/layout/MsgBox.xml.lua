function OnBindMessageWnd(self,hostWnd)
	local data = hostWnd:GetUserData()
	
	if data ~= nil then
		local title = self:GetUIObject("box.title")
		local content = self:GetUIObject("box.content")
		
		title:SetText(data.title)
		content:SetText(data.content)
	end
end

function OnBindConfirmWnd(self,hostWnd)
	local data = hostWnd:GetUserData()
	if data ~= nil then
		local title = self:GetUIObject("box.title")
		local content = self:GetUIObject("box.content")
		
		title:SetText(data.title)
		content:SetText(data.content)
	end
end


function OnOK(self)
	local owner = self:GetOwner()
	local hostWnd = owner:GetBindHostWnd()
	hostWnd:EndDialog(0)
end

function OnYes(self)
	local owner = self:GetOwner()
	local hostWnd = owner:GetBindHostWnd()	
	hostWnd:EndDialog(0)
	local data = hostWnd:GetUserData()
	
	if data.callback ~=nil then
		data.callback(true) 
	end
	
end

function OnNo(self)
	local owner = self:GetOwner()
	local hostWnd = owner:GetBindHostWnd()
	hostWnd:EndDialog(0)
	
	local data = hostWnd:GetUserData()
	if data.callback ~=nil then
		data.callback(false) 
	end
end


function MsgBox(data,hwd)
	local templatemananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local hostwndmanager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local objtreetemplate = templatemananger:GetTemplate("MessageBox","ObjectTreeTemplate")
	local objtree = objtreetemplate:CreateInstance("MessageBox.Instance")

	local modaltemplate = templatemananger:GetTemplate("MessageWnd","HostWndTemplate")
	local message = modaltemplate:CreateInstance("MessageWnd.Instance")

	message:SetUserData(data)
	message:BindUIObjectTree(objtree)
	
	local ret = message:DoModal(hwd)
	   
	local objtreemanager = XLGetObject("Xunlei.UIEngine.TreeManager")
	objtreemanager:DestroyTree("MessageBox.Instance")
	hostwndmanager:RemoveHostWnd("MessageWnd.Instance") 
	
	return ret
end


function ConfirmBox(data,hwd)
	local templatemananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local hostwndmanager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local objtreetemplate = templatemananger:GetTemplate("ConfirmBox","ObjectTreeTemplate")
	local objtree = objtreetemplate:CreateInstance("ConfirmBox.Instance")

	local modaltemplate = templatemananger:GetTemplate("MessageWnd","HostWndTemplate")
	local message = modaltemplate:CreateInstance("MessageWnd.Instance")

	message:SetUserData(data)
	message:BindUIObjectTree(objtree)
	
	local ret = message:DoModal(hwd)
	   
	local objtreemanager = XLGetObject("Xunlei.UIEngine.TreeManager")
	objtreemanager:DestroyTree("ConfirmBox.Instance")
	hostwndmanager:RemoveHostWnd("MessageWnd.Instance") 
	
	return ret
end



function RegisterObject(self)
	local obj = {}
	obj.MsgBox = MsgBox
	obj.ConfirmBox = ConfirmBox
	
	local XARManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local loaded = XARManager:IsXARLoaded("MsgBox")
	
	if not loaded then
		loaded = XARManager:LoadXAR("MsgBox")
	end
	
	XLSetGlobal("xiaop.messagebox", obj)
end