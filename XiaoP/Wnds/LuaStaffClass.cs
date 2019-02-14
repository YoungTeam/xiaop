using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using XiaoP.UI.Core.Bolt;

namespace XiaoP.LuaClasses
{

    [LuaClass(CreatePolicy.Factory)]
    internal sealed class LuaStaffClass : LuaBaseClass<StaffClass, LuaStaffClass>
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
        private static int GetInfo(IntPtr L)
        {
            var instance = GetInstance(L);
            var userId = L.GetString(2);
            instance.getInfo(userId);
            //L.PushString(result);
            return 0;
        }

        [LuaClassMethod]
        private static int GetRecent(IntPtr L)
        {
            var instance = GetInstance(L);
            var userId = L.GetString(2);
            var result = instance.getRecent(userId);
            L.PushString(result);
            return 1;
        }


        /*
        [LuaClassMethod]
        private static int Add(IntPtr L)
        {
            var instance = GetInstance(L);          //通过父类的GetInstance(L)方法获取BOLT环境下通过工厂类创建的MyClass实例
            var left = L.GetInt32(2);               //获取Lua栈的第2个元素
            var right = L.GetInt32(3);              //获取Lua栈的第3个元素
            var result = instance.Add(left, right); //调用MyClass的Add方法
            L.PushInt32(result);                    //将计算结果Push到Lua栈，L.PushXXX是一系列扩展方法，方便将C#数据Push到Lua栈
            //参考：ComicDown.UI.COre/Bolt.NET/LuaExtension.cs
            return 1;                               //1表示往Lua栈里Push了一个元素
        }*/
    }
}
