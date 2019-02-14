using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using XiaoP.UI.Core.Bolt;

namespace XiaoP.Wnds
{

    [LuaClass(CreatePolicy.Factory)]
    internal sealed class XImageLua : LuaBaseClass<XImage, XImageLua>
    {
        [LuaClassMethod]
        private static int AttachImgListener(IntPtr L)
        {
            var instance = GetInstance(L);
            if (!L.IsLuaFunction(-1)) return 0;

            var function = L.ToAction<IntPtr>((result) =>
            {
                L.PushBitmap(result);
                L.Call(1, 0);
            });

            instance.OnImgFinish += function;
            return 0;
        }

        [LuaClassMethod]
        private static int AttachHQImgListener(IntPtr L)
        {
            var instance = GetInstance(L);
            if (!L.IsLuaFunction(-1)) return 0;

            var function = L.ToAction<IntPtr>((result) =>
            {
                L.PushHandle(result);
                L.Call(1, 0);
            });

            instance.OnHQImgFinish += function;
            return 0;
        }

        [LuaClassMethod]
        private static int GetSuggFace(IntPtr L) {

            var instance = GetInstance(L);
            var userId = L.GetString(2);
            instance.getSuggFace(userId);

            return 0;
        }

        [LuaClassMethod]
        private static int GetDefaultFace(IntPtr L)
        {
            var instance = GetInstance(L);
            var width = L.GetInt32(2);
            var height = L.GetInt32(3);
            var status = L.GetInt32(4);
            if (status != 1)
                status = 0;

            instance.getDefaultFace( width, height, status);
           
            return 0;
    
        }

        [LuaClassMethod]
        private static int GetFace(IntPtr L)
        {
            var instance = GetInstance(L);
            var userId = L.GetString(2);
            var width = L.GetInt32(3);
            var height = L.GetInt32(4);
            var status = L.GetInt32(5);
            if (status != 1)
                status = 0;

            if (width > 0)
                instance.getFace(userId,width,height,status);
            else
                instance.getFace(userId);
            //L.PushBitmap(imgPtr);
            return 0;
        }


        [LuaClassMethod]
        private static int GetHQFace(IntPtr L)
        {
            var instance = GetInstance(L);
            var userId = L.GetString(2);

            instance.getHQFace(userId);
            //L.PushBitmap(imgPtr);
            return 0;
        }


        [LuaClassMethod]
        private static int GetImgByUrl(IntPtr L)
        {
            var instance = GetInstance(L);
            var url = L.GetString(2);

            instance.getImgByUrl(url);
            return 0;
        }

        [LuaClassMethod]
        private static int GetGifHandleFromFile(IntPtr L)
        {
            var instance = GetInstance(L);
            var id = L.GetString(2);
            var from = L.GetString(3);
            L.PushGif(instance.getGifHandleFromFile(id, from));
            return 1;
        }

    }
}
