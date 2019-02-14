using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Drawing;
using System.Windows.Forms;
using XiaoP.UI.Core.Bolt;
using XiaoP.Wnds;
using XiaoP.Classes;
namespace XiaoP
{
    class Program
    {
        static XLBolt bolt;

        [STAThread]
        static void Main(string[] args)
        {  
            //
            //获取XLBOLT单例对象
            //
            bolt = XLBolt.Instance();

            //
            //BOLT查找路径
            //
            //var xarSearchPath = Path.Combine(System.Windows.Forms.Application.StartupPath, @"..\..\XAR\");
            var xarSearchPath = Path.Combine(System.Windows.Forms.Application.StartupPath, @"xar\XAR\");
            //
            //XAR文件夹或者包的名字
            //
            var xarName = "Login";

            //显示icon
            //App.setTrayIcon();

            //
            //启动XLBOLT
            //
            bolt.Run(xarSearchPath, xarName, () =>
            {   
                //
                //请在此处注册C#类或对象给BOLT环境   /
                //          
                XImageLua.Register();
                AppLua.Register();
                LoginWndLua.Register();
                MainWndLua.Register();
                ChatWndLua.Register();

            },true);


        }
    }
}
