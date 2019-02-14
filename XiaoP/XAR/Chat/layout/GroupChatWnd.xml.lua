local Instances = {}
function GetInstance(groupId)
	if Instances[groupId] == nil then
		local chatFactory = XLGetObject("XiaoP.Wnds.ChatWnd.Factory")	
		Instances[groupId] = chatFactory:CreateInstance()
	end
	
	return Instances[groupId]

end

function GetGroupId(self)
	local owner  = self:GetOwner()
	return string.gsub(owner:GetID(), "XiaoP.GroupChat.Tree.(%w+)","%1")
end

function OnGroupChatWndCreate(self)
	self:Center()
end
function OnGroupChatWndSize(self,type_, width, height)

	if Type == "min" then
		---最小化时w h 为0 不要用这个重设obj pos 否则各种异常
		return
	elseif Type == "max" then
		local tree = self:GetBindUIObjectTree()
		if tree ~= nil then
			local sysButton = tree:GetUIObject( "SystemBtn" )
			if sysButton ~= nil then
				sysButton:SetMaxState( false )
			end
		end
	elseif Type == "restored" then
		local tree = self:GetBindUIObjectTree()
		if tree ~= nil then
			local sysButton = tree:GetUIObject( "SystemBtn" )
			if sysButton ~= nil then
				sysButton:SetMaxState( true )
			end
		end
	end

	local objectTree = self:GetBindUIObjectTree()
	local rootObject = objectTree:GetRootObject()
	
	rootObject:SetObjPos(0, 0, width, height)
end

function OnMinisize(self)
	local hostwnd = self:GetOwner():GetBindHostWnd()
	hostwnd:Min() 
end

function OnMaxSize(self)
	local hostWnd = self:GetOwner():GetBindHostWnd()
	hostWnd:Max()
	self:SetMaxState( false )
end

function OnReStore(self)
	local hostWnd = self:GetOwner():GetBindHostWnd()
	hostWnd:Restore()
	self:SetMaxState( true )
end

function OnClose(self)
	local groupId = GetGroupId(self)
	local owner = self:GetOwner()
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local HostWnd = owner:GetBindHostWnd()
	hostwndManager:RemoveHostWnd(HostWnd:GetID())
	local treeMananger = XLGetObject("Xunlei.UIEngine.TreeManager")
	treeMananger:DestroyTree(owner:GetID())
	
	local chatClass = GetInstance(groupId)
	chatClass:Destroy()
	if Instances[groupId] ~= nil then
		Instances[groupId] =nil
	end
	
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function OnClickSend(self)
	local groupId = GetGroupId(self)
	local chatClass = GetInstance(groupId)
	
	local sendRichEdit = self:GetObject("tree:chat.area:send.richedit")	
	local richText = sendRichEdit:GetRichText()
	local text = sendRichEdit:GetText()
	
		

	
	local sendEidt = sendRichEdit:GetControlObject("edit")
	
	local msg = {}
	msg.imgList = {}
	msg.content = text
	
	--chatAttr.objects
	text = trim(text)
	local chatAttr = sendRichEdit:GetAttribute()
	if text == "" and #chatAttr.objects == 0 then
		sendRichEdit:AddTip("发送内容不能为空")
		return
	end
	for i,object in pairs(chatAttr.objects) do
		if object:GetID() ~= nil then
			local xImage = {}
			xImage.pos = object:GetPos()
			xImage.id = object:GetId()
			if object:GetFrom() == "clipboard" then
				xImage.from = "file"
			else
				xImage.from = object:GetFrom()			
			end
			xImage.type = object:GetType()
			xImage.width = object:GetWidth()
			xImage.height = object:GetHeight()
			msg.imgList[i] = xImage
		end
	end			
	
	chatAttr.objects = {}
	
	local json = XLGetGlobal("xunlei.json")
	local msgJson = json.encode(msg)
	
	local txtMsgStr = chatClass:SendChat(msgJson)

	local txtMsg = json.decode(txtMsgStr)
	local chatRichEdit = self:GetObject("tree:chat.area:chat.richedit")
	appendToChatRichExit(chatRichEdit,txtMsg)
	
	sendRichEdit:ClearRichText()

end

function ToTextArray( str )
    local len  = #str
    local left = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local t = {}
    local start = 1
    local wordLen = 0
    while len ~= left do
        local tmp = string.byte(str, start)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                break
            end
            i = i - 1
        end
        wordLen = i + wordLen
        local tmpString = string.sub(str, start, wordLen)
        start = start + i
        left = left + i
        t[#t + 1] = tmpString
    end
    return t
end

function appendToChatRichExit(chatRichEdit,msg)
	local appClass = XLGetObject("XiaoP.Wnds.App")
	local curUserId = appClass:GetCurrentUserId()
	
	local len = chatRichEdit:GetLength()
	chatRichEdit:SetSel(len, len)
	
	if chatRichEdit:GetID() ~=  "send.richedit" then
		
		local fmt = {textcolor="#0000FFFF",facename="微软雅黑",height=12,weight = 400,underline=false,italic=false}
		if curUserId == msg.from then
			fmt.textcolor = "#40B475FF"
		end
		
		chatRichEdit:SetInsertCharFormat(fmt)
		
		chatRichEdit:AppendText(msg.userName.."（")
		chatRichEdit:AppendText(msg.from)
		chatRichEdit:AppendText("）　"..string.sub(msg.sendTime,11,-1).."\n")
		
		--local len = chatRichEdit:GetLength()
		--chatRichEdit:SetSel(len, len)
		
	end
	
	chatRichEdit:SetInsertCharFormat(msg.fmt)
	

	local currPos,textPos = 1,1
	
	if  #msg.imgList == 0 then
	
		chatRichEdit:AppendText(msg.content)
	else
		--中英文混合重整
		local newText = ToTextArray(msg.content)
		
		for k,imgData in pairs(msg.imgList) do
			if imgData.pos == -1 then
				imgData.pos = chatRichEdit:GetLength()
			end
			
			currPos = imgData.pos	
			
			for i=textPos,currPos do
				chatRichEdit:AppendText(newText[i])
				--chatRichEdit:AppendText(string.sub(msg.content,textPos,currPos))	
			end
			
			--插入图片
				
			local img = nil
			if imgData.from == "emotion" then
				img = appClass:GetGifHandleFromFile(imgData.id,"emotion")
				if img~=nil then 
					imgData.width, imgData.height = img:GetSize()	
				end
			elseif imgData.from == "clipboard" then
				img = appClass:GetImageFromClipboard()
			end
			
			if img == nil  then				
				img = appClass:GetImageFromFile(imgData.id)
			end
			
			local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
			local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
		
			local imageObj = objFactory:CreateUIObject("","XImageCtrl")
			
			if imageObj then
				imageObj:SetResProvider(xarManager)
				
				imageObj:SetObjPos(0, 0, imgData.width, imgData.height)
				imageObj:SetType(imgData.type)
				imageObj:SetFrom(imgData.from)
				imageObj:SetId(imgData.id)
				imageObj:SetPos(imgData.pos)
				
				
				chatRichEdit:GetControlObject("edit"):InsertObject(imageObj)	
				if img ~= nil then
					imageObj:SetXImage(img)
				end
				
				local chatAttr = chatRichEdit:GetAttribute()
				table.insert(chatAttr.objects, imageObj)
			end		
			
			

			--计算下一次
			textPos = textPos + currPos - 1;
		end	
		
		for i=textPos+1,#newText do
				chatRichEdit:AppendText(newText[i])
		end
	end
	
	if chatRichEdit:GetID() ~=  "send.richedit" then
		chatRichEdit:AppendText("\n")
	end
	
	local len = chatRichEdit:GetLength()
	chatRichEdit:SetSel(len, len)
			
end

function OnClickClose(self)
	local groupId = GetGroupId(self)
	local owner = self:GetOwner()
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local HostWnd = owner:GetBindHostWnd()
	hostwndManager:RemoveHostWnd(HostWnd:GetID())
	local treeMananger = XLGetObject("Xunlei.UIEngine.TreeManager")
	treeMananger:DestroyTree(owner:GetID())
	
	local chatClass = GetInstance(groupId)
	chatClass:Destroy()
	if Instances[groupId] ~= nil then
		Instances[groupId] =nil
	end
	
end


function OnChatSpliterCtrlInit(self)
		
	local groupId = GetGroupId(self)
	local chatClass = GetInstance(groupId)
	
	local fontStyle = self:GetObject("font.style.combobox")
	fontStyle:SetWindow(chatClass:GetFontStyle())
	
	local fontSize = self:GetObject("font.size.combobox")
	fontSize:SetWindow(chatClass:GetFontSize())
	
end

function OnChatExtraCtrlInit(self)
	local groupId = GetGroupId(self)
end

function OnInitHistoryRichEdit(self)
	local groupId = GetGroupId(self)
	local chatClass = GetInstance(groupId)
	
	self:SetWindow(chatClass:GetHistoryRichTextBox())
end

function OnHistoryClick(self)
	--XLMessageBox(self:GetID())
	local owner = self:GetOwner()
	local hostWnd = owner:GetBindHostWnd()
	local left,top,right,bottom = hostWnd:GetWindowRect()
	
	local extraCtrl= owner:GetUIObject("chat.extra.ctrl")
	local chatLayout = owner:GetUIObject("chat.area.layout")
	
	
	local historyBtn = self:GetObject("spliter.bar.history.btn")
	
	
	local status = extraCtrl:SwitchLayout()
	local ctrlAttr = extraCtrl:GetAttribute()
	
	if status == "history" then
		historyBtn:SetButtonStatus(3)
		chatLayout:SetObjPos2(1,61,"father.width-335","father.height-60")
		local groupId = GetGroupId(self)
		local chatClass = GetInstance(groupId)
		chatClass:GetGroupHistory("last")
	else
		historyBtn:SetButtonStatus(0)	
		chatLayout:SetObjPos2(1,61,"father.width-166","father.height-60")
	end
	
end


function OnHistoryFirstClick(self,event)
	local groupId = GetGroupId(self)
	local chatClass = GetInstance(groupId)
	chatClass:GetGroupHistory("first")
end

function OnHistoryPrevClick(self,event)
	local groupId = GetGroupId(self)
	local chatClass = GetInstance(groupId)
	chatClass:GetGroupHistory("prev")
end


function OnHistoryNextClick(self,event)
	local groupId = GetGroupId(self)
	local chatClass = GetInstance(groupId)
	chatClass:GetGroupHistory("next")
end

function OnHistoryLastClick(self,event)
	local groupId = GetGroupId(self)
	local chatClass = GetInstance(groupId)
	chatClass:GetGroupHistory("last")
end

function OnEmotionClick(self,event,x,y)
	local tree = self:GetOwner()
	local hostwnd = tree:GetBindHostWnd()
	local hleft,htop = hostwnd:GetWindowRect()

	local groupId = GetGroupId(self)
	local chatClass = GetInstance(groupId)
	chatClass:PopupEmotion(hleft+x,htop+y)
end

function OnCaptureClick(self)
	local groupId = GetGroupId(self)
	
	local chatClass = GetInstance(groupId)
	chatClass:CaptureScreen()
end

function OnFontStyleClick(self,event,isU,isI,isB)

	local groupId = GetGroupId(self)
	
	local chatClass = GetInstance(groupId)
	chatClass:SelectFontStyle(isU,isI,isB)

end


function OnFontColorClick(self)
	local groupId = GetGroupId(self)
	
	local chatClass = GetInstance(groupId)
	chatClass:ClickFontColor()
	
end

function UpdateGroupInfo(owner,data)
	if data == nil then
		return
	end
		
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local chatHostWnd = hostwndManager:GetHostWnd("XiaoP.GroupChatWnd."..data.groupId)
	
	if chatHostWnd == nil then
	
		return 
	end

	chatHostWnd:SetTitle(data.groupName)
--XLMessageBox(data.groupName)
	local chatClass = GetInstance(data.groupId)
	chatClass:SetIcon(chatHostWnd:GetWndHandle())

	local groupName = owner:GetUIObject("chat.groupName")
	local groupLogo = owner:GetUIObject("group.logo")

	local chatExtra = owner:GetUIObject("chat.extra.ctrl")
	chatExtra:UpdateInfo(data)
	
	groupName:SetText(data.groupName)
	if data.groupType == "dept" then
		groupLogo:SetResID("dept.logo")
	else
		groupLogo:SetResID("mail.logo")
	end

end

function FlashWindow(groupId)

	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local chatHostWnd = hostwndManager:GetHostWnd("XiaoP.GroupChatWnd."..groupId)
	local chatClass = GetInstance(groupId)
	
	
	if chatHostWnd == nil then
		return 
	end
	
	
	if chatHostWnd:GetFocus() then
		
		chatClass:FlashWindow(chatHostWnd:GetWndHandle(),false)
	else
		
		chatClass:FlashWindow(chatHostWnd:GetWndHandle(),true)
	end
		
end

function OnNcActivate(self,active)
	local groupId = self:GetUserData()
	local owner = self:GetBindUIObjectTree()
	
	local sendRichedit = nil
	if owner ~= nil then
		local spliterCtrl = owner:GetUIObject("chat.area")
		sendRichedit = spliterCtrl:GetObject("send.richedit")
	end
	if active then
		FlashWindow(groupId)				
		AsynCall(
			function (x)
				if sendRichedit ~= nil then
					sendRichedit:SetFocus(true)
				end		
			end
		)
	end
end

function OnBindHostWnd(owner,hostWnd,isBind)

	if not isBind then 
		return
	end
	
	local groupId = hostWnd:GetUserData()
	
	local chatExtra = owner:GetUIObject("chat.extra.ctrl")
	local chatExtaCtrl = owner:GetUIObject("chat.extra.ctrl")
	local chatRichEdit = owner:GetUIObject("chat.area:chat.richedit")
	local sendRichEdit = owner:GetUIObject("chat.area:send.richedit")
	local historyRichEdit = owner:GetUIObject("chat.extra.ctrl:chat.extra.history.richedit")
	
	local chatClass = GetInstance(groupId)
	chatClass:InitGroup(groupId)
	
	chatClass:AttachResultListener(
		function(r)
			local json = XLGetGlobal("xunlei.json")
			local ret = json.decode(r);
				
			if ret.type == "info" then
				UpdateGroupInfo(owner,ret.data)
			elseif ret.type == "lastestchats" then	
				
				updateLastestRichEdit(chatRichEdit,ret.data)
			elseif ret.type =="members" then
				chatExtra:CreateMembersList(ret.data)
			elseif ret.type == "history" then
				chatExtra:UpdatePageInfo(ret.data)				
			elseif ret.type == "newmsg" then
				FlashWindow(ret.data)
				chatClass:DequeueChat()
			elseif ret.type == "close" then
				OnClose(chatExtaCtrl)
			elseif ret.type == "userInfo" then						
				chatExtra:UpdateMember(ret.data)
			
			elseif ret.type == "setCharFormat" then
				sendRichEdit:SetInsertCharFormat(ret.data)
				
				local edit = sendRichEdit:GetControlObject("edit")
				edit:SetSel(0,sendRichEdit:GetLength())
				edit:SetSelectCharFormat(ret.data,true)
				local len = sendRichEdit:GetLength()
				edit:SetSel(len,len)
			elseif ret.type == "appendSendRichEdit" then
				appendToChatRichExit(sendRichEdit,ret.data)	
			elseif ret.type == "appendChatRichEdit" then
				local msg = json.decode(ret.data);
				appendToChatRichExit(chatRichEdit,msg)	
			elseif ret.type == "updateHistoryRichEdit" then
				updateHistoryRichEdit(historyRichEdit,ret.data)
			elseif ret.type == "sendChat" then
				OnClickSend(sendRichEdit)
			end
		end
	)
	
	chatClass:AttachHandleListener(
		function(id,t,handle)
			local chatAttr = chatRichEdit:GetAttribute()
			for i,object in pairs(chatAttr.objects) do
				if object:GetId() == id then
					object:SetBitmap(handle)
					table.remove(chatAttr.objects, i)
				end
			end
		end		
	)
	
end

function updateLastestRichEdit(chatRichEdit,msgs)
	local json = XLGetGlobal("xunlei.json")
	
	for k,msgStr in pairs(msgs) do
		local msg = json.decode(msgStr)
		appendToChatRichExit(chatRichEdit,msg)	
	end
	
end

function updateHistoryRichEdit(historyRichEdit,msgs)
	
	local json = XLGetGlobal("xunlei.json")
	
	historyRichEdit:ClearRichText()
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
		
	
	for k,msgStr in pairs(msgs) do
		
		local msg = json.decode(msgStr)
		
		if msg.spliter ~=nil then
			local imageObj1 = objFactory:CreateUIObject("spliter.left"..k,"ImageObject")
			if imageObj1 then
				imageObj1:SetResProvider(xarManager)
				imageObj1:SetObjPos(0, 0, 118, 12)
				imageObj1:SetResID("chat.history.split")	
				historyRichEdit:GetControlObject("edit"):InsertObject(imageObj1)
			end
			
			local fmt = {textcolor="#666666FF",facename="微软雅黑",height=12,weight = 400,underline=false,italic=false}
			historyRichEdit:SetInsertCharFormat(fmt)
			historyRichEdit:AppendText(msg.spliter)
			
			local imageObj2 = objFactory:CreateUIObject("spliter.right"..k,"ImageObject")
			if imageObj2 then
				imageObj2:SetResProvider(xarManager)
				imageObj2:SetObjPos(0, 0, 118, 12)
				imageObj2:SetResID("chat.history.split")	
				historyRichEdit:GetControlObject("edit"):InsertObject(imageObj2)
			end
			historyRichEdit:AppendText("\n")
		else
			appendToChatRichExit(historyRichEdit,msg)		
		end
	end
end

function OnSendGetObjectText(self,strID,obj)
	if obj == nil then
		
		return
	end
	
	
	local id = obj:GetId()
	local img = obj:GetXImage()
	
	local groupId = GetGroupId(self)
	local chatClass = GetInstance(groupId)	
	
	if obj:GetFrom() ~= "emotion" then
		local width,height = chatClass:AddSendImg(img,id)
		obj:SetWidth(width)
		obj:SetHeight(height)
	end
	
	local str = "<ximg." .. id .. ">"
	return str,true
end

function OnGroupChatWndClose(self)

	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local objTree = self:UnbindUIObjectTree()
	local treeMananger = XLGetObject("Xunlei.UIEngine.TreeManager")
	--XLMessageBox(objTree:GetID())
	treeMananger:DestroyTree(objTree)	
	
	hostwndManager:RemoveHostWnd(self:GetID())
	
	local groupId = self:GetUserData()
	local chatClass = GetInstance(groupId)
	chatClass:Destroy()
	if Instances[groupId] ~= nil then
		Instances[groupId] =nil
	end
	
end