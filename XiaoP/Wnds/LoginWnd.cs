using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using Newtonsoft.Json;
using System.Drawing;
using System.Net;
using System.Collections;
using XiaoP.UI.Core.Bolt;
using XiaoP.UI.Core.Bolt.NET;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Threading;
using XiaoP.Classes;
using XiaoP.Classes.Util;
using XiaoP.Classes.Service;
using System.Windows.Forms;

namespace XiaoP.Wnds
{

    internal sealed class LoginWnd : LuaBaseView,IMessageFilter
    {
        public event Action<string> OnResultFinish;
        //public event Action<IntPtr> OnHandleFinish;
        //public event Action<Bitmap> OnLoadImgFinish;
        private string userId = null;

        private void returnResult(string type, object data)
        {
            Hashtable ret = new Hashtable();
            XLBolt.Instance().Invoke(delegate()
            {
                ret.Add("type", type);
                ret.Add("data", data);

                OnResultFinish(JsonConvert.SerializeObject(ret));
            });
        }

        public LoginWnd(){
            XLBolt.Instance().AddMessageFilter(this);
        }

        public bool PreFilterMessage(ref System.Windows.Forms.Message msg)
        {
           // if (API.GetAsyncKeyState((int)Keys.ControlKey) != 0 ) {
            
          //
           

            if (msg.Msg == API.WM_KEYDOWN){
            
                switch((Keys)msg.WParam){
                    case Keys.Enter:
                        returnResult("hotkey","enter");
                        break;
                }

            } 
            return false;
        }

        public void authentication(string userId, string userPwd)
        {
            Thread thread = new Thread(new ThreadStart(
                            () =>
                            {

                                string ret = "false";
                                this.userId = userId;

                                LDAPHelper ldap = new LDAPHelper(null, userId, userPwd);
                                if (ldap.login())
                                {
                                    ret = "true";
                                }

                                if (Global.Debug)
                                    ret = "true";

                                //是否记住密码
                                if (bool.Parse(INIOperation.INIGetStringValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "isRemember", "false")))
                                {
                                    Properties.Settings.Default.userPwd = XEncrypt.EncryptDES(userPwd);

                                }
                                else {
                                    Properties.Settings.Default.userPwd = "";
                                }
                                Properties.Settings.Default.Save();
                                

                                returnResult("auth", ret);

                            }
                        ));
            //thread.IsBackground = true;
            thread.Start();

        }

        
        /*
        private void updateProcess(bool status,int value ,string info)
        {
            Hashtable ret = new Hashtable();
            XLBolt.Instance().Invoke(delegate()
            {

                ret.Add("ret", status);
                ret.Add("value", value);
                ret.Add("info", info);
               
                OnResultFinish(JsonConvert.SerializeObject(ret));
            });
        }*/

        //初始化各种数据及监听线程准备
        private static Thread thread;
        public void logining() {

            if (userId != null)
            {
                if (userId.IndexOf("@") != -1)
                {

                    string[] nameArr = userId.Split('@');
                    userId = nameArr[0];
                }

            }

            cancelThread = false;
            thread = new Thread(new ThreadStart(
                                      () =>
                                      {
                                          if (cancelThread)
                                              return;                                      
                                          Global.CUR_USER = UserService.loginUser(userId);
                                          if (cancelThread)
                                              return;

                                          if (Global.CUR_USER == null)
                                          {
                                              returnResult("logining",0);
                                              return;
                                          }

                                          returnResult("logining", 10);

                                          MainWnd.deptList = StaffService.getDept(userId);
                                          if (cancelThread)
                                              return;
                                          returnResult("logining", 20);

                                          MainWnd.recentList = StaffService.getRecent(userId);
                                          if (cancelThread)
                                              return;

                                          returnResult("logining", 40);

                                          MainWnd.novaTodo = NovaService.getNovaToDo(userId);
                                          if (cancelThread)
                                              return;
                                          returnResult("logining", 60);

                                          MainWnd.novaMine = NovaService.getNovaMine(userId);
                                          if (cancelThread)
                                              return;
                                          returnResult("logining", 99);

                                          Thread.Sleep(100);
                                          if (cancelThread)
                                              return;
                                          returnResult("logining", 100);

                                      }
                                  ));
            thread.IsBackground = true;
            thread.Start();
        }

        private static bool cancelThread = false;
        public void cancel() {

            if (thread != null) {
                try
                {
                    cancelThread = true;
                    while (thread.IsAlive) {
                        thread.Abort();
                    }
                    if(MainWnd.deptList!=null)
                        MainWnd.deptList.Clear();
                    if(MainWnd.recentList!=null)
                        MainWnd.recentList.Clear();

                    returnResult("cancel","");
                }
                catch (Exception ex) {
                    PLog.Exception(ex);
                }
            }
        }


        public void destroy() {
            //XLBolt.Instance().RemoveMessageFilter(this);
        }
        
    }
}
