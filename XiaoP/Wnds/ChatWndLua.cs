using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using XiaoP.UI.Core.Bolt;
using System.Drawing;

namespace XiaoP.Wnds
{
    [LuaClass(CreatePolicy.Factory)]
    internal sealed class ChatWndLua : LuaBaseClass<ChatWnd, ChatWndLua>
    {
        [LuaClassMethod]
        private static int AttachResultListener(IntPtr L)
        {
            var instance = GetInstance(L);
            if (!L.IsLuaFunction(-1)) return 0;
            var function = L.ToAction<string>((result) =>
            {
                L.PushString(result);  
                L.Call(1, 0);
            });
            instance.OnResultFinish += function;
            return 0;
        }

        [LuaClassMethod]
        private static int AttachHandleListener(IntPtr L)
        {
            var instance = GetInstance(L);
            if (!L.IsLuaFunction(-1)) return 0;
            var function = L.ToAction<string,string,IntPtr>((id,type,handle) =>
            {
                L.PushString(id);
                L.PushString(type);
                L.PushBitmap(handle);
                L.Call(3, 0);
            });
            instance.OnHandleFinish += function;
            return 0;
        }

        [LuaClassMethod]
        private static int Init(IntPtr L)
        {
            var instance = GetInstance(L);
            var userId = L.GetString(2);
            instance.init(userId);

            return 0;
        }

        [LuaClassMethod]
        private static int InitGroup(IntPtr L)
        {
            var instance = GetInstance(L);
            var groupId = L.GetString(2);
            instance.initGroup(groupId);

            return 0;
        }

        [LuaClassMethod]
        private static int SetIcon(IntPtr L)
        {
            var instance = GetInstance(L);
            var app = L.GetHandle(2);
            instance.setIcon(app);
            //L.PushString(result);
            return 0;
        }

        [LuaClassMethod]
        private static int FlashWindow(IntPtr L)
        {
            var instance = GetInstance(L);
            var app = L.GetHandle(2);
            var flash = L.GetBool(3);
            instance.flashWindow(app,flash);

            return 0;
        }

        [LuaClassMethod]
        private static int GetUserInfo(IntPtr L)
        {
            var instance = GetInstance(L);
            var userId = L.GetString(2);
            instance.getUserInfo(userId);
            return 0;
        }

        [LuaClassMethod]
        private static int LastestChatHistory(IntPtr L)
        {
            var instance = GetInstance(L);
            //instance.lastestChatHistory();
            return 0;
        }
        
        [LuaClassMethod]
        private static int PopupEmotion(IntPtr L)
        {
            var instance = GetInstance(L);
            var x = L.GetInt32(2);
            var y = L.GetInt32(3);

            //IntPtr richTextBoxPtr = instance.getSendRichTextBox();
            instance.popupEmotion(x,y);
            //L.PushHandle(richTextBoxPtr);
            return 0;
        }

        [LuaClassMethod]
        private static int CaptureScreen(IntPtr L)
        {
            var instance = GetInstance(L);
            instance.captureScreen();
            return 0;
        }

        [LuaClassMethod]
        private static int SendChat(IntPtr L)
        {
            var instance = GetInstance(L);
            var richText = L.GetString(2);
            //var userId = L.GetString(2);
            //IntPtr richTextBoxPtr = instance.getSendRichTextBox();
            var ret = instance.sendChat(richText);
            L.PushString(ret);
            return 1;
        }

        [LuaClassMethod]
        private static int DequeueChat(IntPtr L)
        {
            var instance = GetInstance(L);
            instance.dequeueChat();
            return 0;
        }


        [LuaClassMethod]
        private static int GetHistory(IntPtr L)
        {
            var instance = GetInstance(L);
            var pageType = L.GetString(2);
            instance.getHistory(pageType);
            return 0;
        }

        [LuaClassMethod]
        private static int GetGroupHistory(IntPtr L)
        {
            var instance = GetInstance(L);
            var pageType = L.GetString(2);
            instance.getGroupHistory(pageType);
            return 0;
        }

        [LuaClassMethod]
        private static int GetFontStyle(IntPtr L)
        {
            var instance = GetInstance(L);
           
            var handle = instance.getFontStyleCombobox();
            L.PushHandle(handle);
            return 1;
        }

        [LuaClassMethod]
        private static int GetFontSize(IntPtr L)
        {
            var instance = GetInstance(L);

            var handle = instance.getFontSizeCombobox();
            L.PushHandle(handle);
            return 1;
        }

        
        [LuaClassMethod]
        private static int ClickFontColor(IntPtr L)
        {
            var instance = GetInstance(L);

            instance.clickFontColor();
            return 0;
        }

        [LuaClassMethod]
        private static int SelectFontStyle(IntPtr L)
        {
            var instance = GetInstance(L);
            var isU = L.GetBool(2);
            var isI = L.GetBool(3);
            var isB = L.GetBool(4);


            instance.selectFontStyle(isU, isI, isB);
            return 0;
        }
        
        [LuaClassMethod]
        private static int Destroy(IntPtr L)
        {
            var instance = GetInstance(L);
            instance.destroy();
            instance = null;
            return 0;
        }


      

         [LuaClassMethod]
        private static int AddSendImg(IntPtr L)
        {
            var instance = GetInstance(L);
            IntPtr bmpHandle = L.GetBitmap(2);
            var id = L.GetString(3);
            var type = L.GetString(4);
            if (type == null)
                type = "jpg";
            Rectangle rec = instance.addSendImg(bmpHandle, id, type);
            L.PushInt32(rec.Width);
            L.PushInt32(rec.Height);
            //L.PushBool(instance.addSendImg(bmpHandle, id, type));
            return 2;
        }
        
        
    }
}
