using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using Microsoft.Win32;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Net.Mail;
using System.Net;
using System.Text.RegularExpressions;
using XiaoP.UI.Core.Bolt;
using System.Management;
using XiaoP.Wnds;
using Pandora;

namespace XiaoP.Classes.Util
{
    class SystemHelper
    {
        public static int LOGPIXELSY = 90;
        public static int SizeToPixelsWidth(double fontSize)
        {
            System.Windows.Forms.Panel p = new System.Windows.Forms.Panel();
            System.Drawing.Graphics g = System.Drawing.Graphics.FromHwnd(p.Handle);
            IntPtr hdc = g.GetHdc();
            double lfHeight = GetDeviceCaps(hdc, LOGPIXELSY) * fontSize / 72;

            g.ReleaseHdc(hdc);
            return (int)lfHeight;
        }

        [DllImport("gdi32.dll")]
        private static extern int GetDeviceCaps(IntPtr hdc, int Index);



        public static bool isChatWndOpen(string id) {
            bool isChatWndOpen = false;
            foreach (IMessageFilter filter in XLBolt.Instance().GetMessageFilter())
            {
                if (filter.GetType().FullName == "XiaoP.Wnds.ChatWnd")
                {
                    ChatWnd chatWnd = (ChatWnd)filter;
                    if (id.StartsWith("group"))
                    {
                        if (chatWnd.group != null && chatWnd.group.groupId == id)
                        {
                            isChatWndOpen = true;
                            break;
                        }

                    }else{
                        if(chatWnd.user != null && chatWnd.user.userId == id){
                      
                            isChatWndOpen = true;
                            break;
                        }
                    }
                }
            }
            return isChatWndOpen;
        }

        public static List<ChatWnd> getOpenChatWnds()
        {
            List<ChatWnd> wndList = new List<ChatWnd>();
            foreach (IMessageFilter filter in XLBolt.Instance().GetMessageFilter())
            {
                if (filter.GetType().FullName == "XiaoP.Wnds.ChatWnd")
                {
                    ChatWnd chatWnd = (ChatWnd)filter;
                    wndList.Add(chatWnd);
                }
            }

            return wndList;
        }

        public static void mailSend(string to)//发送邮件  
        {
            string sEmailMSG = "mailto:" + to;
            try
            {
                System.Diagnostics.Process.Start(sEmailMSG);
            }
            catch (Exception ex)
            {
                PLog.Exception(ex);
                //MessageBox("请您安装邮件客户端程序！");
            }
        }  

        public static void saveFontProperties()
        {

            INIOperation.INIWriteValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "User", "fontSetting", Global.CUR_FONT.toJson());
            //Properties.Settings.Default.fontSetting = PGlobal.CUR_FONT.toJson();
            //Properties.Settings.Default.Save();//使用Save        
        }

        public static void openWebBrowser(string url)
        {
            try
            {
                System.Diagnostics.Process.Start(url);
            }
            catch(Exception ex)
            {
                PLog.Exception(ex);
            }
        }

        public static void openImageView(Image img)
        {
            if (img == null)
                return;

            Pandora.ImgView imgView = new Pandora.ImgView(img);
            imgView.Show();
        }

        /// <summary>
        /// 获取本地IP
        /// </summary>
        /// <returns></returns>
        public static string GetLocalIp()
        {
            IPHostEntry ipHost = Dns.GetHostEntry(Dns.GetHostName());

            string ipStr = "";

            foreach (IPAddress ipaddress in ipHost.AddressList)
            {
                if (IsIP(ipaddress.ToString()))
                {
                    ipStr = ipaddress.ToString();
                    break;
                }

            }
            return ipStr;
        }

        public static bool IsIP(string ip)
        {
            if (string.IsNullOrEmpty(ip))
                return false;

            return Regex.IsMatch(ip, @"^((\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.){3}(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$");
        }



        public static Rectangle getSystemWorkArea(){
        
            return SystemInformation.WorkingArea;
        }

        public static void PlayAudio(string filePath)
        {

            //Application.StartupPath + @"/sounds/1.wav";
            System.Media.SoundPlayer sndPlayer = new System.Media.SoundPlayer(filePath);
            sndPlayer.PlaySync();
        }

        /***设置任务栏图标***/
        public static void setAppIcon(IntPtr appHandle, Icon ico, int iconType = Messages.ICON_SMALL)
        {
            API.SendMessage(appHandle, Messages.WM_SETICON, iconType, ico.Handle);
        }

        public static bool AddAutoRun(string keyName, string filePath)
        {
            try
            {
                RegistryKey runKey = Registry.CurrentUser.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", true);
                if (runKey == null)
                {
                    runKey = Registry.LocalMachine.CreateSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run");
                }
                runKey.SetValue(keyName, filePath);
                runKey.Close();
            }
            catch (Exception ex)
            {
                Console.Write(ex.Message);
                return false;
            }
            return true;
        }

        public static bool DelAutoRun(string keyName)
        {
            try
            {
                RegistryKey runKey = Registry.CurrentUser.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", true);
                runKey.DeleteValue(keyName);
                runKey.Close();
            }
            catch (Exception ex)
            {
                Console.Write(ex.Message);
                return false;
            }
            return true;
        }

        public static bool IsAutoRun()
        {   bool autoRun = false;
            try
            {
                RegistryKey runKey = Registry.CurrentUser.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", false);
                if (runKey != null)
                {
                    if (runKey.GetValue("Pandora") != null)
                        autoRun = true;
                }
                runKey.Close();
            }
            catch (Exception ex)
            {
                Console.Write(ex.Message);
                return false;
            }
            return autoRun;
        }


        public static string GetBIOSSerialNumber()
        {
            string result = string.Empty;
            ManagementObjectSearcher searcher =
                new ManagementObjectSearcher("Select SerialNumber From Win32_BIOS");
            ManagementObjectCollection moc = searcher.Get();

            if (moc.Count > 0)
            {
                foreach (ManagementObject share in moc)
                {
                    result = share["SerialNumber"].ToString();
                }
            }
            return result;
        }

        public static bool SendMail(string fromId, string fromName, string to, string title, string content)
        {


            MailAddress from = new MailAddress(fromId, fromName); //邮件的发件人

            MailMessage mail = new MailMessage();

            //设置邮件的标题
            mail.Subject = title;

            //设置邮件的发件人
            //Pass:如果不想显示自己的邮箱地址，这里可以填符合mail格式的任意名称，真正发mail的用户不在这里设定，这个仅仅只做显示用
            mail.From = from;


            mail.To.Add(to);

            //设置邮件的抄送收件人
            //这个就简单多了，如果不想快点下岗重要文件还是CC一份给领导比较好
            //mail.CC.Add(new MailAddress("Manage@hotmail.com", "尊敬的领导"));

            //设置邮件的内容
            mail.Body = content;
            //设置邮件的格式
            mail.BodyEncoding = System.Text.Encoding.UTF8;
            mail.IsBodyHtml = true;
            //设置邮件的发送级别
            mail.Priority = MailPriority.Normal;

            /*
            //设置邮件的附件，将在客户端选择的附件先上传到服务器保存一个，然后加入到mail中
            string fileName = txtUpFile.PostedFile.FileName.Trim();
            fileName = "D:/UpFile/" + fileName.Substring(fileName.LastIndexOf("/") + 1);
            txtUpFile.PostedFile.SaveAs(fileName); // 将文件保存至服务器
            mail.Attachments.Add(new Attachment(fileName));
            */
            //mail.DeliveryNotificationOptions = DeliveryNotificationOptions.OnSuccess;

            SmtpClient client = new SmtpClient();
            //设置用于 SMTP 事务的主机的名称，填IP地址也可以了
            client.Host = "portal.sys.yt-op.org";

            //设置用于 SMTP 事务的端口，默认的是 25
            //client.Port = 25;
            client.UseDefaultCredentials = false;
            //这里才是真正的邮箱登陆名和密码，比如我的邮箱地址是 hbgx@hotmail， 我的用户名为 hbgx ，我的密码是 xgbh
            //client.Credentials = new System.Net.NetworkCredential("hbgx", "xgbh");
            client.DeliveryMethod = SmtpDeliveryMethod.Network;
            //都定义完了，正式发送了，很是简单吧！
            try
            {
                client.Send(mail);
            }
            catch (Exception ex)
            {
                Console.Write(ex.Message);
            }
            return true;
        }
        
        /// <summary>
        /// 新消息任务栏提示 
        /// </summary>
        /// <param name="hWnd"></param>
        /// <param name="bInvert"></param>
        /// <returns></returns>
        [DllImport("user32.dll")]
        public static extern bool FlashWindow(IntPtr hWnd, bool bInvert);

    }

    public static class FlashWindow
    {
        /*
         // Flash window until it recieves focus
        FlashWindow.Flash(this);
 
        // Flash window 5 times
        FlashWindow.Flash(this, 5);
 
        // Start Flashing "Indefinately"
        FlashWindow.Start(this);
 
        // Stop the "Indefinate" Flashing
        FlashWindow.Stop(this); 
        */
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool FlashWindowEx(ref FLASHWINFO pwfi);

        [StructLayout(LayoutKind.Sequential)]
        private struct FLASHWINFO
        {
            /// <summary>
            /// The size of the structure in bytes.
            /// </summary>
            public uint cbSize;
            /// <summary>
            /// A Handle to the Window to be Flashed. The window can be either opened or minimized.
            /// </summary>
            public IntPtr hwnd;
            /// <summary>
            /// The Flash Status.
            /// </summary>
            public uint dwFlags;
            /// <summary>
            /// The number of times to Flash the window.
            /// </summary>
            public uint uCount;
            /// <summary>
            /// The rate at which the Window is to be flashed, in milliseconds. If Zero, the function uses the default cursor blink rate.
            /// </summary>
            public uint dwTimeout;
        }

        /// <summary>
        /// Stop flashing. The system restores the window to its original stae.
        /// </summary>
        public const uint FLASHW_STOP = 0;

        /// <summary>
        /// Flash the window caption.
        /// </summary>
        public const uint FLASHW_CAPTION = 1;

        /// <summary>
        /// Flash the taskbar button.
        /// </summary>
        public const uint FLASHW_TRAY = 2;

        /// <summary>
        /// Flash both the window caption and taskbar button.
        /// This is equivalent to setting the FLASHW_CAPTION | FLASHW_TRAY flags.
        /// </summary>
        public const uint FLASHW_ALL = 3;

        /// <summary>
        /// Flash continuously, until the FLASHW_STOP flag is set.
        /// </summary>
        public const uint FLASHW_TIMER = 4;

        /// <summary>
        /// Flash continuously until the window comes to the foreground.
        /// </summary>
        public const uint FLASHW_TIMERNOFG = 12;


        /// <summary>
        /// Flash the spacified Window (Form) until it recieves focus.
        /// </summary>
        /// <param name="form">The Form (Window) to Flash.</param>
        /// <returns></returns>
        public static bool Flash(IntPtr wnd)
        {
           
            FLASHWINFO fi = Create_FLASHWINFO(wnd, FLASHW_ALL | FLASHW_TIMERNOFG, uint.MaxValue, 0);
            return FlashWindowEx(ref fi);
           
        }

        private static FLASHWINFO Create_FLASHWINFO(IntPtr handle, uint flags, uint count, uint timeout)
        {
            FLASHWINFO fi = new FLASHWINFO();
            fi.cbSize = Convert.ToUInt32(Marshal.SizeOf(fi));
            fi.hwnd = handle;
            fi.dwFlags = flags;
            fi.uCount = count;
            fi.dwTimeout = timeout;
            return fi;
        }

        /// <summary>
        /// Flash the specified Window (form) for the specified number of times
        /// </summary>
        /// <param name="form">The Form (Window) to Flash.</param>
        /// <param name="count">The number of times to Flash.</param>
        /// <returns></returns>
        public static bool Flash(IntPtr wnd, uint count)
        {
           
            FLASHWINFO fi = Create_FLASHWINFO(wnd, FLASHW_ALL, count, 0);
            return FlashWindowEx(ref fi);
           
        }

        /// <summary>
        /// Start Flashing the specified Window (form)
        /// </summary>
        /// <param name="form">The Form (Window) to Flash.</param>
        /// <returns></returns>
        public static bool Start(IntPtr wnd)
        {
           
            FLASHWINFO fi = Create_FLASHWINFO(wnd, FLASHW_ALL, uint.MaxValue, 0);
            return FlashWindowEx(ref fi);
           
        }

        /// <summary>
        /// Stop Flashing the specified Window (form)
        /// </summary>
        /// <param name="form"></param>
        /// <returns></returns>
        public static bool Stop(IntPtr wnd)
        {
            
            FLASHWINFO fi = Create_FLASHWINFO(wnd, FLASHW_STOP, uint.MaxValue, 0);
            return FlashWindowEx(ref fi);
            
        }

    }

}
