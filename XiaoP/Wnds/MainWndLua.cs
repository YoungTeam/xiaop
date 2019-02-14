using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using XiaoP.Classes;
using XiaoP.UI.Core.Bolt;

namespace XiaoP.Wnds
{
    [LuaClass(CreatePolicy.Singleton)]
    internal sealed class MainWndLua : LuaBaseClass<MainWnd, MainWndLua>
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
        private static int AttachSuggListener(IntPtr L)
        {
            var instance = GetInstance(L);
            if (!L.IsLuaFunction(-1)) return 0;
            var function = L.ToAction<string>((result) =>
            {
                L.PushString(result);
                L.Call(1, 0);
            });
            instance.OnSuggFinish += function;
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
        private static int Init(IntPtr L)
        {
            var instance = GetInstance(L);
            //var userId = L.GetString(2);
            instance.init();
            //L.PushString(result);
            return 0;
        }

        [LuaClassMethod]
        private static int GetInfo(IntPtr L)
        {
            var instance = GetInstance(L);
            var userId = L.GetString(2);
            instance.getUserInfo(userId);
            //L.PushString(result);
            return 0;
        }

        [LuaClassMethod]
        private static int GetRecent(IntPtr L)
        {
            var instance = GetInstance(L);
            var userId = L.GetString(2);
            instance.getRecentStaff(userId);
            //L.PushString(result);
            return 0;
        }

        [LuaClassMethod]
        private static int GetDept(IntPtr L)
        {
            var instance = GetInstance(L);
            var userId = L.GetString(2);
            instance.getDeptStaff(userId);
            //L.PushString(result);
            return 0;
        }

        [LuaClassMethod]
        private static int AddContact(IntPtr L)
        {
            var instance = GetInstance(L);
            var userId = L.GetString(2);
            instance.addContact(userId);
            //L.PushString(result);
            return 0;
        }

        [LuaClassMethod]
        private static int RemoveContact(IntPtr L)
        {
            var instance = GetInstance(L);
            var userId = L.GetString(2);
            instance.removeContact(userId);
            return 0;
        }
        

        [LuaClassMethod]
        private static int GetSuggUserList(IntPtr L)
        {
            var instance = GetInstance(L);
            var query = L.GetString(2);
            instance.getSuggUserList(query);
            //L.PushString(result);
            return 0;
        }

        [LuaClassMethod]
        private static int OpenNovaTodo(IntPtr L)
        {
            var instance = GetInstance(L);
            instance.openNovaTodo();
            return 0;
        }

        [LuaClassMethod]
        private static int OpenNovaMine(IntPtr L)
        {
            var instance = GetInstance(L);
            instance.openNovaMind();
            return 0;
        }

        [LuaClassMethod]
        private static int Destroy(IntPtr L)
        {
            var instance = GetInstance(L);
            instance.destroy();
            return 0;
        }

    }
}
