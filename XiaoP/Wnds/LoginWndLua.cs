using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using XiaoP.UI.Core.Bolt;

namespace XiaoP.Wnds
{

    [LuaClass(CreatePolicy.Singleton)]
    internal sealed class LoginWndLua : LuaBaseClass<LoginWnd, LoginWndLua>
    {

        [LuaClassMethod]
        private static int AttachResultListener(IntPtr L)
        {
            var instance = GetInstance(L);          //通过调用父类的GetInstance(L)方法获取BOLT环境下通过工厂类创建的MyClass实例           
            if (!L.IsLuaFunction(-1)) return 0;     //判断Lua栈的栈顶元素是否为function

            //
            //调用L.ToAction<T>(Action<T> caller)扩展方法将Lua栈顶function转为C#的Action<T>委托
            //其中caller用来具体将委托的参数Push到Lua栈，并通过L.Call(int arg,int ret)调用Lua的function
            //   arg表示Push到Lua栈的元素个数
            //   ret表示Lua function的返回值个数
            //
            var function = L.ToAction<string>((result) =>
            {
                L.PushString(result);  //将resultPush到Lua栈 
                L.Call(1, 0);         //调用Lua的方法，1表示参数个数为1，0表示返回值个数为0
            });

            instance.OnResultFinish += function; //将转换后的委托添加到MyClass实例的OnAddFinish事件上
            return 0;                         //此处并没有往Lua栈里Push元素，故返回0
        }

        [LuaClassMethod]
        private static int Authentication(IntPtr L)
        {
            var instance = GetInstance(L);
            var userId = L.GetString(2);
            var userPwd = L.GetString(3);

            instance.authentication(userId,userPwd);
            return 0;
        }

        [LuaClassMethod]
        private static int Logining(IntPtr L)
        {
            var instance = GetInstance(L);
            //var userId = L.GetString(2);
          
            instance.logining();
            return 0;
        }

        [LuaClassMethod]
        private static int Cancel(IntPtr L)
        {
            var instance = GetInstance(L);
            instance.cancel();
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
