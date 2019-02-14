using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using XiaoP.UI.Core.Bolt;
using XiaoP.Classes;

namespace XiaoP.Wnds
{
    [LuaClass(CreatePolicy.Singleton)]
    internal sealed class AppLua : LuaBaseClass<App, AppLua>
    {
        [LuaClassMethod]
        private static int AttachTrayIconListener(IntPtr L)
        {
            var instance = GetInstance(L);
            if (!L.IsLuaFunction(-1)) return 0;
            var function = L.ToAction<string>((result) =>
            {
                L.PushString(result);
                L.Call(1, 0);
            });
            instance.OnTrayIconDoubleClick += function;
            return 0;
        }

        [LuaClassMethod]
        private static int GetVersion(IntPtr L)
        {
            var instance = GetInstance(L);
            var version = instance.getVersion();
       
            L.PushString(version);
            return 1;
        }

        [LuaClassMethod]
        private static int GetCurrentUserId(IntPtr L)
        {
            var instance = GetInstance(L);
            var user = instance.getCurrentUser();
            if (user != null)
                L.PushString(user.userId);
            else
                L.PushString("");
            return 1;
        }

        [LuaClassMethod]
        private static int SetTrayIcon(IntPtr L)
        {
            var instance = GetInstance(L);
            instance.setTrayIcon();
            //var userId = L.GetString(2);
            //IntPtr imgPtr = instance.getFace(userId);

            //L.PushBitmap(imgPtr);
            return 0;
        }

        [LuaClassMethod]
        private static int OpenUrl(IntPtr L) 
        {
            var instance = GetInstance(L);
            var url = L.GetString(2);
            instance.openUrl(url);
            return 0;
        }
        

        [LuaClassMethod]
        private static int GetRect(IntPtr L)
        {
            var instance = GetInstance(L);
            //var wnd = L.GetHandle(2);

            IntPtr wndHandle = XLUE.XLUE_GetHostWndByID("XiaoP.ChatWnd");
            instance.getRect(XLUE.XLUE_GetHostWndWindowHandle(wndHandle));

            return 0;
        }

        [LuaClassMethod]
        private static int IsClipboardTextFormatAvailable(IntPtr L)
        {
            var instance = GetInstance(L);
            bool ret = instance.isClipboardTextFormatAvailable();

            L.PushBool(ret);

            return 1;
        }


        [LuaClassMethod]
        private static int GetCursorPos(IntPtr L)
        {

            var instance = GetInstance(L);
            int[] p  = instance.getCursorPos();
            L.PushInt32(p[0]);
            L.PushInt32(p[1]);

            return 2;
        }

        [LuaClassMethod]
        private static int GetWorkArea(IntPtr L)
        {
            var instance = GetInstance(L);
            int x = L.GetInt32(2);
            int y = L.GetInt32(3);

            int[] p = instance.getWorkArea(x,y);
            
            L.PushInt32(p[0]);
            L.PushInt32(p[1]);
            L.PushInt32(p[2]);
            L.PushInt32(p[3]);
            return 4;
        }

        [LuaClassMethod]
        private static int GetScreenArea(IntPtr L)
        {
            var instance = GetInstance(L);
            int x = L.GetInt32(2);
            int y = L.GetInt32(3);

            int[] p = instance.getScreenArea(x, y);

            L.PushInt32(p[0]);
            L.PushInt32(p[1]);
            L.PushInt32(p[2]);
            L.PushInt32(p[3]);
            return 4;

        }

        [LuaClassMethod]
        private static int Feedback(IntPtr L)
        {
            var instance = GetInstance(L);
            instance.openUrl(Global.PANDORA_HOME + "sq/wtbg/?from=xiaop");
            return 0;
        }

        [LuaClassMethod]
        private static int MailSend(IntPtr L)
        {
            var instance = GetInstance(L);
            var mail = L.GetString(2);
            instance.mailSend(mail);
            return 0;
        }

        [LuaClassMethod]
        private static int SetSendMode(IntPtr L)
        {
            var instance = GetInstance(L);
            var sendMode = L.GetString(2);
            instance.setSendMode(sendMode);
            return 1;
        }

        [LuaClassMethod]
        private static int GetSendMode(IntPtr L)
        {
            var instance = GetInstance(L);
            L.PushString(instance.getSendMode());
            return 1;
        }

        [LuaClassMethod]
        private static int SaveSettings(IntPtr L)
        {
            var instance = GetInstance(L);
            var minOrExit = L.GetString(2);
            var autoStart = L.GetBool(3);
            var popType = L.GetString(4);
            var showMobile = L.GetBool(5);
            instance.saveSettings(minOrExit, autoStart, popType, showMobile);            
            return 0;
        }

        [LuaClassMethod]
        private static int LoadSettgings(IntPtr L)
        {
            var instance = GetInstance(L);
            L.PushString(instance.loadSettgings());
            return 1;
        }

        [LuaClassMethod]
        private static int LoadLoginSettings(IntPtr L)
        {
            var instance = GetInstance(L);
            L.PushString(instance.loadLoginSettings());
            return 1;
        }
        
        [LuaClassMethod]
        private static int SaveLoginSettings(IntPtr L)
        {
            var instance = GetInstance(L);
            var userId = L.GetString(2);
            var isRemember = L.GetBool(3);
            var autoStart = L.GetBool(4);
            instance.saveLoginSettings(userId,isRemember,autoStart);

            return 0;
        }

        [LuaClassMethod]
        private static int GetImageFromClipboard(IntPtr L)
        {
            var instance = GetInstance(L);
            L.PushBitmap(instance.getImageFromClipboard());
            return 1;
        }

        [LuaClassMethod]
        private static int GetGifHandleFromFile(IntPtr L)
        {
             var instance = GetInstance(L);
             var id = L.GetString(2);
             var from = L.GetString(3);
             L.PushGif(instance.getGifHandleFromFile(id,from));
             return 1;
         }

        [LuaClassMethod]
        private static int GetImageFromFile(IntPtr L)
        {
             var instance = GetInstance(L);
             var id = L.GetString(2);
             L.PushBitmap(instance.getImageFromFile(id));
             return 1;
         }

        [LuaClassMethod]
         private static int SaveImageFromHandle(IntPtr L)
        {
            var instance = GetInstance(L);
            IntPtr bmpHandle = L.GetBitmap(2);
            var id = L.GetString(3);
            var type = L.GetString(4);
            if (type == null)
                type = "jpg";

            L.PushBool(instance.saveImageFromHandle(bmpHandle,id,type));
            return 1;
        }

        [LuaClassMethod]
        private static int openImageView(IntPtr L)
        {

            var instance = GetInstance(L);
            string id = L.GetString(2);
            string from = L.GetString(3);

            instance.openImageView(id, from);
            return 0;
        }
       

        [LuaClassMethod]
        private static int GetMinOrExit(IntPtr L)
        {
            var instance = GetInstance(L);
            L.PushString(instance.getMinOrExit());
            return 1;
        }

        [LuaClassMethod]
        private static int LoadUpgrade(IntPtr L)
        {
            var instance = GetInstance(L);
            instance.loadUpgrade();
            return 0;
        }
        
        [LuaClassMethod]
        private static int Quit(IntPtr L)
        {
            var instance = GetInstance(L);
            instance.quit();
            return 0;
        }

    }
}
