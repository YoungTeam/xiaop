using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using System.Threading;
using System.Collections;
using System.Timers;
using System.Windows.Forms;
using Newtonsoft.Json;
using XiaoP.Classes;
using XiaoP.Classes.Data;
using XiaoP.Classes.Service;
using XiaoP.Classes.Util;
using XiaoP.UI.Core.Bolt;

using CaptureTool;

namespace XiaoP.Wnds
{
    internal sealed class MainWnd
    {
        private static MainWnd instance = null;
        public event Action<string> OnResultFinish;
        public event Action<string> OnSuggFinish;

        public static List<Department> deptList = null;
        public static List<Category> groupList = null;
        public static List<User> recentList = null;
        public static int novaTodo = -1;
        public static int novaMine = -1;

        private Thread signalThread = null;
        private System.Timers.Timer CheckTimer;
        private System.Timers.Timer HeartBeatTimer;

        public static XStack ChatStack = new XStack();


        public MainWnd() {
            instance = this;

            AppDomain.CurrentDomain.UnhandledException += new UnhandledExceptionEventHandler(
                (object sender, UnhandledExceptionEventArgs e)=>{
                    try
                    {
                        //this.logout();
                        SystemHelper.SendMail(
                            Global.CUR_USER.userId + "@yt-inc.com",
                            Global.CUR_USER.userName,
                            "yangting@yt-inc.com",
                            "【小P问题报告】" + DateTime.Now.ToString("yyyy-MM-dd"),
                            e.ExceptionObject.ToString());

                        PLog.Error(e.ExceptionObject.ToString());
                     
                    }
                    catch
                    {

                    }
            
                }
            );

        }
        public static MainWnd GetInstance() {
            return instance;
        }

        public void returnResult(string type, object data)
        {
            Hashtable ret = new Hashtable();
            XLBolt.Instance().Invoke(delegate()
            {
                ret.Add("type", type);
                ret.Add("data", data);
                try
                {
                    OnResultFinish(JsonConvert.SerializeObject(ret));
                }
                catch (Exception ex) {
                    PLog.Exception(ex);
                }
            });
        }
        
        public void init() {

            if (Global.Debug) {
                if (Global.CUR_USER.userId == null)
                    Global.CUR_USER.userId = "zhangxiaowen";

            }
            //返回用户信息
            this.getUserInfo(Global.CUR_USER.userId);
            this.getDeptStaff(Global.CUR_USER.userId);
            this.getGroupList(Global.CUR_USER.userId);
            this.getRecentStaff(Global.CUR_USER.userId);
            this.getNovaTodo(Global.CUR_USER.userId);
            this.getNovaMine(Global.CUR_USER.userId);
            this.initEmotions();
            Global.SEND_MODE = INIOperation.INIGetStringValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", Global.CUR_USER.userId, "sendMode", "Enter");
       

            //开启消息提醒
            if (signalThread == null || signalThread.ThreadState != System.Threading.ThreadState.Running)
            {
                signalThread = new Thread(new ThreadStart(() => {
                    SignalService.receive(
                        returnResult
                    );                 
                }));
                signalThread.IsBackground = true;
                signalThread.Name = "SIGNAL:" + Global.CUR_USER.userId;
                signalThread.Start();
            }

            //线程检查定时器
            CheckTimer = new System.Timers.Timer();
            CheckTimer.Elapsed += new ElapsedEventHandler(Timer_Check_Tick);
            CheckTimer.Interval = 20000;
            CheckTimer.Enabled = true;
            CheckTimer.Start();

            HeartBeatTimer = new System.Timers.Timer();
            HeartBeatTimer.Elapsed += new ElapsedEventHandler(Timer_HeartBeat_Tick);
            //到达时间的时候执行事件；   
            HeartBeatTimer.Interval = 5 * 1000;
            HeartBeatTimer.Enabled = true;
            HeartBeatTimer.Start();

            
        }

        
        public void showCapture() {

                FrmCapture frmCapture = new FrmCapture();
                frmCapture.FinishCatpure += delegate(object o, EventArgs e)
                {
                    /*
                    Guid guid = Guid.NewGuid();
                    SendImage sImage = new SendImage();
                    sImage.id = guid.ToString().Replace("-", "");
                    sImage.image = Clipboard.GetImage();

                    this.SendGifs.Add(sImage);*/
                    Image img = Clipboard.GetImage();
                    TxtMsg txtMsg = new TxtMsg();
                    if (img != null)
                    {
                        Guid guid = Guid.NewGuid();

                        ImgMsg imgMsg = new ImgMsg();
                        imgMsg.pos = -1;
                        imgMsg.id = guid.ToString().Replace("-", "");
                        if (img.RawFormat == System.Drawing.Imaging.ImageFormat.Gif)
                            imgMsg.type = "gif";
                        else
                            imgMsg.type = "jpg";

                        Rectangle rec = ImgHelper.getScalingRec(img, 200, 200);
                        imgMsg.width = rec.Width;
                        imgMsg.height = rec.Height;

                        imgMsg.from = "clipboard";
                        txtMsg.imgList.Add(imgMsg);

                        returnResult("appendSendRichEdit", txtMsg);
                    }

                    //this.ExtRichTextBox_Send.InsertMyControl(pic);
                };
           
            frmCapture.Show();
 
        }

        /***线程检查****/
        private void Timer_Check_Tick(object sender, ElapsedEventArgs e)
        {
            if (signalThread.ThreadState != System.Threading.ThreadState.Background && signalThread.ThreadState != System.Threading.ThreadState.Running
                && signalThread.ThreadState != (System.Threading.ThreadState.WaitSleepJoin | System.Threading.ThreadState.Background))
            {
                while (signalThread.IsAlive)
                {
                    signalThread.Abort();
                }
                signalThread = new Thread(new ThreadStart(() =>
                {
                    SignalService.receive(returnResult);
                }));
                signalThread.IsBackground = true;
                signalThread.Name = "SIGNAL:" + Global.CUR_USER.userId;
                signalThread.Start();
            }
        }

        private void Timer_HeartBeat_Tick(object sender, ElapsedEventArgs e)
        {
            SignalService.sendHeartBeat();
        }


        public void setIcon(IntPtr app)
        {
            SystemHelper.setAppIcon(app, App.ICO_APP);
        }

        public void initEmotions()
        {
            //
            Thread thread = new Thread(new ThreadStart(
                () =>
                {

                    if (Global.EMOTION_LIST.Count == 0)
                    {
                        for (int i = 1; i < 133; i++)
                        {
                            Global.EMOTION_LIST.Add(
                                new Bitmap(Global.PANDORA_PFOFILE + "system\\emotion\\default\\" + i + ".gif")
                            );
                        }
                    }
                
             }));
            thread.IsBackground = true;
            thread.Start();
        }

        public void getUserInfo(string userId)
        {

            Thread thread = new Thread(new ThreadStart(
                () =>
                {
                    if (Global.CUR_USER==null || Global.CUR_USER.userName == null)
                        Global.CUR_USER = UserService.getInfoById(userId);
                    returnResult("info", Global.CUR_USER);
                }

             ));

            thread.IsBackground = true;
            thread.Start();
        
        }

        public void getDeptStaff(string userId)
        {

            Thread thread = new Thread(new ThreadStart(
                              () =>
                              {
                                  if(deptList==null)
                                      deptList = StaffService.getDept(userId);

                                  returnResult("dept", deptList);

                              }
                          ));
            thread.IsBackground = true;
            thread.Start();      
        
        }

        public void getRecentStaff(string userId)
        {  

            Thread thread = new Thread(new ThreadStart(
                    () =>
                    {

                        if (recentList == null)
                            recentList = StaffService.getRecent(userId);

                        returnResult("recent", recentList);

                    }
                ));
            thread.IsBackground = true;
            thread.Start();
        }

        public void getNovaTodo(string userId)
        {
            Thread thread = new Thread(new ThreadStart(
                    () =>
                    {
                        if(novaTodo < 0)
                            novaTodo = NovaService.getNovaToDo(userId);
                        returnResult("nova.todo", novaTodo);
                    }
                ));
            thread.IsBackground = true;
            thread.Start();

        }

        public void getNovaMine(string userId)
        {
            Thread thread = new Thread(new ThreadStart(
                    () =>
                    {
                        if (novaMine < 0)
                            novaMine = NovaService.getNovaMine(userId);
                        returnResult("nova.mine", novaMine);
                    }
                ));
            thread.IsBackground = true;
            thread.Start();
        }

        public void getGroupList(string userId) { 
        
             
            Thread thread = new Thread(new ThreadStart(
            () =>
            {

                if (groupList == null)
                    groupList = GroupService.getGroupListByUserId(userId);
                returnResult("groups", groupList);

            }
            ));
            thread.IsBackground = true;
            thread.Start();
        }

        public void getSuggUserList(string query)
        {

            Thread thread = new Thread(new ThreadStart(
                    () =>
                    {
                        List<User> userList = UserService.getUserListByQuery(query);
                        string response = "";
                        Hashtable retData = new Hashtable();
                        retData.Add("query",query);
                        retData.Add("list", userList);
                        try
                        {
                            response = JsonConvert.SerializeObject(retData);
                        }
                        catch (Exception ex)
                        {
                            PLog.Exception(ex);
                        }

                        XLBolt.Instance().Invoke(delegate()
                        {
                            if (OnSuggFinish != null)
                            {
                                OnSuggFinish(response);
                            }
                        });

                    }
                ));
            thread.IsBackground = true;
            thread.Start();

        }

        public void addContact(string userId) {
            Thread thread = new Thread(new ThreadStart(
                        () =>
                        {
                            bool ret = StaffService.addContact(Global.CUR_USER.userId,userId);
                            User user = null;
                            if(ret)
                                user = UserService.getInfoById(userId);

                            returnResult("addContact", user);
                        
                        }
                    ));
            thread.IsBackground = true;
            thread.Start();
        }

        public void removeContact(string userId) {
      
            Thread thread = new Thread(new ThreadStart(
                        () =>
                        {
                            bool ret = StaffService.removeContact(Global.CUR_USER.userId, userId);
                            returnResult("removeContact", userId);

                        }
                    ));
            thread.IsBackground = true;
            thread.Start();
        }

        public void cancelChatSignal(string userId)
        {
            MainWnd.ChatStack.Remove(userId);
            returnResult("cancelChatSignal", userId);
        }

        public void cancelGroupChatSignal(string groupId)
        {
            MainWnd.ChatStack.Remove("group-"+groupId);
            returnResult("cancelGroupChatSignal", groupId);
        }

        public void addRecent(User user) {
            returnResult("addRecent", user);
        }

        public void openNovaTodo() {

            SystemHelper.openWebBrowser(Global.PANDORA_HOME + "nova/my_job/my_todo.jspf");
        }

        public void openNovaMind() {
            SystemHelper.openWebBrowser(Global.PANDORA_HOME + "nova/my_job/my_todo.jspf");
        }

        public void destroy()
        {
            if (HeartBeatTimer != null)
                HeartBeatTimer.Stop();

            if (CheckTimer != null)
                CheckTimer.Stop();



            Thread thread = new Thread(new ThreadStart(
              () =>
              { 

                  if (signalThread != null)
                  {
                      while (signalThread.IsAlive)
                      {
                          signalThread.Abort();
                      }
                  }
              }
           ));

            thread.IsBackground = true;
            thread.Start();

            if (Global.CUR_USER != null)
                UserService.logoutUser(Global.CUR_USER.userId);
            
            
        }

    }
}
