using System;
using System.Collections.Generic;
using System.Linq;
using System.Collections;
using System.Text;
using Newtonsoft.Json;
using System.Drawing;
using XiaoP.Classes;
using XiaoP.Classes.Data;
using XiaoP.Classes.Service;
using XiaoP.Classes.Util;
using System.Windows.Forms;
using XiaoP.UI.Core.Bolt;

namespace XiaoP.Wnds
{
    internal sealed class App
    {

        public event Action<string> OnTrayIconDoubleClick;
        private System.Windows.Forms.Timer NotifyTimer;
        private NotifyIcon nicon;

        public static void init() {

            Global.CUR_USER = UserService.getInfoById("yangting");

        }


        public void quit() {
            if (MainWnd.GetInstance() != null)
                MainWnd.GetInstance().destroy();
            Environment.Exit(0);
        }

        public string getVersion() {

            AssemblyInfo assemblyInfo = new AssemblyInfo();
            return assemblyInfo.Product+" "+assemblyInfo.Version;
            //this.Lbl_Copyright.Text = assemblyInfo.Copyright;
            //this.Lbl_Version.Text = assemblyInfo.Title + " " + assemblyInfo.Version;
        }

        public User getCurrentUser() {

            return Global.CUR_USER;
        }

        /***设置托盘*****/
        public void setTrayIcon() {
            /*
            MainWnd.ChatStack.Push("yangting");
            MainWnd.ChatStack.Push("jialike");
            MainWnd.ChatStack.Push("yangting");
            MainWnd.ChatStack.Push("zhangxiaowen");
            */
            if(nicon != null)
                return;

            nicon = new System.Windows.Forms.NotifyIcon();
            /*using (Bitmap bm = new Bitmap(@"D:/1.jpg"))
            {
                nicon.Icon = Icon.FromHandle(bm.GetHicon());
            }*/
            nicon.Icon = ICO_APP;
            //AssemblyInfo assemblyInfo = new AssemblyInfo();
            nicon.Text = this.getVersion();
            nicon.MouseUp += new MouseEventHandler((object sender, MouseEventArgs e) => {
                if (e.Button == MouseButtons.Right)
                {
                    if (Global.CUR_USER == null)
                        return;
                    if (MainWnd.GetInstance() != null) {
                        Point p = new Point(e.X, e.Y);
                        MainWnd.GetInstance().returnResult("mainMenu",p);
                    }
                }   
            
            });

            nicon.MouseDoubleClick += new MouseEventHandler((object sender, MouseEventArgs e) =>
            {
                if (OnTrayIconDoubleClick != null)
                {
                    string jsonRet = "";

                    if (MainWnd.ChatStack.Count() > 0) {
                        string chatId = MainWnd.ChatStack.Top();
                        Hashtable ret = new Hashtable();
                        if (chatId.StartsWith("group-"))
                        {
                            ret.Add("type", "groupchat");
                            chatId = chatId.Replace("group-", "");
                        }
                        else
                        {
                            if (ICO_HASH.ContainsKey(chatId))
                            {
                                ICO_HASH.Remove(chatId);
                            }
                            ret.Add("type", "chat");
                        }

                        ret.Add("data", chatId);
                        jsonRet = JsonConvert.SerializeObject(ret);
                    }

                    OnTrayIconDoubleClick(jsonRet);
                    
                }
            });
            nicon.Visible = true;

            //托盘定时器
            NotifyTimer = new System.Windows.Forms.Timer();
            NotifyTimer.Tick += new EventHandler(Timer_Notify_Tick);
            NotifyTimer.Interval = 500;
            NotifyTimer.Enabled = true;
            NotifyTimer.Start();
        
        }

        bool flag = false;
        static Icon ICO_NULL = global::XiaoP.Properties.Resources.ico_null;
        public static Icon ICO_APP = global::XiaoP.Properties.Resources.app32;
        public static Icon ICO_DEPT = global::XiaoP.Properties.Resources.dept_group;
        public static Icon ICO_Mail = global::XiaoP.Properties.Resources.mail_group;

        static Hashtable ICO_HASH = new Hashtable();

        private void Timer_Notify_Tick(object sender, EventArgs e)
        {

            //如果没有提醒
            if (MainWnd.ChatStack.Count() == 0)
            {   
                nicon.Icon = ICO_APP;
                this.nicon.Text = this.getVersion();
                return;
            }

       


            flag = !flag;
            if (flag)
            {
                string chatId = MainWnd.ChatStack.Top();

                Icon ico = null;
                if (ICO_HASH.ContainsKey(chatId))
                {
                    ico = (Icon)ICO_HASH[chatId];
                }
                else
                {
                    if (chatId.StartsWith("group-"))
                    {

                        ico = ICO_DEPT;
                    }
                    else
                    {
                        Image face = UserService.getFace(chatId, 16, 19);
                        ico = ImgHelper.getIcon(face);
                    }

                    ICO_HASH.Add(chatId, ico);
                }

                nicon.Icon = ico;
            }
            else {
                nicon.Icon = ICO_NULL;
            }

        }

        public Rectangle getRect(IntPtr wndHandle)
        {
            
            Rectangle rec = new Rectangle();
            API.GetWindowRect(wndHandle,ref rec);

            return rec;

        }

        public bool isClipboardTextFormatAvailable()
        {
            return OSShellHelper.checkClipboardFormatAvailable(API.CF_TEXT, IntPtr.Zero);
        
        }

        public int[] getCursorPos() {

            Point p = OSShellHelper.getCursorPos();

            return new int[]{ p.X, p.Y };
        }


        public int[] getWorkArea(int x ,int y) {

            Rectangle rec = OSShellHelper.getWorkArea();

            return new int[] { rec.X, rec.Y, rec.Width, rec.Height };
        }

        public int[] getScreenArea(int x, int y)
        {

            Rectangle rec = OSShellHelper.getScreenArea();
            return new int[] { rec.X, rec.Y, rec.Width, rec.Height };
        }

        public void openUrl(string url) {

            SystemHelper.openWebBrowser(url);

        }

        public void mailSend(string mail) {
            SystemHelper.mailSend(mail);
        }

        public void setSendMode(string sendMode) {

            INIOperation.INIWriteValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", Global.CUR_USER.userId, "sendMode", sendMode);
            Global.SEND_MODE = sendMode;
        }

        public string getSendMode() {
            return Global.SEND_MODE;
        }


        public string getMinOrExit() {
            return INIOperation.INIGetStringValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "closingMiniOrExit", "Exit");
        }

        public string loadLoginSettings() {

            string userId = INIOperation.INIGetStringValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "userId", "");
            bool isRemember = bool.Parse(INIOperation.INIGetStringValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "isRemember", "false"));
            bool autoStart = bool.Parse(INIOperation.INIGetStringValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "autoStart", "false"));

            string userPwd = "";
            //是否记住密码
            if (isRemember)
            {
                userPwd = XEncrypt.DecryptDES(Properties.Settings.Default.userPwd);
            }

            Hashtable loginTable = new Hashtable();
            
            loginTable.Add("userId", userId);
            loginTable.Add("userPwd", userPwd);
            loginTable.Add("isRemember", isRemember);
            loginTable.Add("autoStart", autoStart);

            return JsonConvert.SerializeObject(loginTable);

        }

        public void saveLoginSettings(string userId, bool isRemember, bool autoStart)
        {
            INIOperation.INIWriteValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "userId", userId);
            INIOperation.INIWriteValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "isRemember", isRemember.ToString());
            INIOperation.INIWriteValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "autoStart", autoStart.ToString());
        }

        public string loadSettgings() {
           // this.CheckBox_SaveAccount.Checked = bool.Parse(INIOperation.INIGetStringValue(PGlobal.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "isRemember", "false")); //Properties.Settings.Default.isRemember;


            //if (Properties.Settings.Default.closingMiniOrExit == "Mini")
            string minOrExit = INIOperation.INIGetStringValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "closingMiniOrExit", "Exit");

            bool autoStart = SystemHelper.IsAutoRun();

            string popType = INIOperation.INIGetStringValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "noticeType", "Always");
            bool showMobile = true;
            if (Global.CUR_USER.showMobile == 0)
                showMobile = false;

            Hashtable setttings = new Hashtable();
            setttings.Add("minOrExit",minOrExit);
            setttings.Add("popType", popType);
            setttings.Add("showMobile", showMobile);
            setttings.Add("autoStart", autoStart);

            return JsonConvert.SerializeObject(setttings);
        }

        public void saveSettings(string minOrExit,bool autoStart,string popType,bool showMobile)
        {

            //Properties.Settings.Default.isRemember = this.CheckBox_SaveAccount.Checked;
            //INIOperation.INIWriteValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "isRemember", this.CheckBox_SaveAccount.Checked.ToString());
            
            if (minOrExit == "mini")
            {

                INIOperation.INIWriteValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "closingMiniOrExit", "Mini");
                //Properties.Settings.Default.closingMiniOrExit = "Mini";

            }
            else if (minOrExit == "exit")
            {
                INIOperation.INIWriteValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "closingMiniOrExit", "Exit");
                //Properties.Settings.Default.closingMiniOrExit = "Exit";
            }

            INIOperation.INIWriteValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "closingNoRemind", "True");

            //开机自动启动
            if (autoStart)
            {
                SystemHelper.AddAutoRun("Pandora", Application.ExecutablePath);
            }
            else
            {
                SystemHelper.DelAutoRun("Pandora");
            }
            INIOperation.INIWriteValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "autoStart", autoStart.ToString());

            //待办提醒设置

            /*
            string noticeStr = this.ComboBox_Notice.Text;
            string noticeType = "Always";
            if (noticeStr == "保留2分钟弹窗")
                noticeType = "2minutes";
            else if (noticeStr == "不再显示弹窗")
                noticeType = "Never";
            */
            INIOperation.INIWriteValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "noticeType", popType);

            //设置是否需要显示手机

            int mobile = 1;
            if (!showMobile)
                mobile = 0;

            if (Global.CUR_USER.showMobile != mobile)
            {
                UserService.setUserShowMobile(Global.CUR_USER.userId, mobile);
                Global.CUR_USER.showMobile = mobile;
            }

        }

        public IntPtr getImageFromClipboard() {
            IntPtr imgHandle = IntPtr.Zero;
            Image img = Clipboard.GetImage();
            if (img != null)
            {
                imgHandle = ImgHelper.getImgHandle(img);
            }

            return imgHandle;
        }

        public IntPtr getImageFromFile(string id)
        {
            //先查数据库
            //ImgHelper.get
            return ImgHelper.getData(id,"jpg");
       
        }

        public IntPtr getGifHandleFromFile(string id, string from) {
            IntPtr gifHandle = IntPtr.Zero;
            if (from == "emotion") {
                string filePath = Global.PANDORA_PFOFILE +"system\\emotion\\default\\" + id + ".gif";
                
                gifHandle =  ImgHelper.getGifHandle(filePath);
            }
            return gifHandle;
        }

        public bool saveImageFromHandle(IntPtr hBmp,string id,string type) {

            bool ret = XLGraphics.XLGP_SaveXLBitmapToJpegFile(hBmp, Global.CUR_USER.profiles + "images\\" + id + ".jpg", 100);
            return ret;

        }

        public void openImageView(string id, string from)
        {

            Image img = null;
            if (from == "emotion")
                return;
            if (from == "clipboard")
            {
                img = Clipboard.GetImage();
            }
            else if (from == "file")
            {
                img = ImgHelper.getImageFromFile(Global.CUR_USER.profiles + "images\\" + id + ".jpg");

            }

            SystemHelper.openImageView(img);

        }

        public void loadUpgrade() {

            System.Diagnostics.Process.Start(Application.StartupPath + "\\Upgrade.exe");

        }

    }
}
