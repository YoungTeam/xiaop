using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.IO;
using System.Windows.Forms;
using System.Xml;
using System.Net;
using System.Threading;
using System.Globalization;
using Pandora.Module.Util;

namespace Upgrade
{
    public partial class MainForm : Form
    {
        private WebClient downWebClient = new WebClient();
        private static long totalSize;//所有文件大小 
        private static long upSize;//已更新文件大小 
        private static string fileName;//当前文件名 
        private static long fileSize;//当前文件大小 
        private static string[] fileNames;
        private static int downloadedNum = 0 ;

        private string CurrentVersion = "";
        private string LastestVersion = "";
        private string UpdateUrl = "";
        private string AppExe = "";
        private bool finished = false;
        //private string LocalUpdate = "";
        
        public MainForm()
        {
            InitializeComponent();
        }

        public MainForm(string[] args)
        {
            InitializeComponent();
           
            if(args.Length >0){
                this.AppExe = args[0];
            }
            //this.progressBar1.Hide();
            //this.label1.Hide();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            this.Hide();
            this.ShowInTaskbar = false;
            this.notifyIcon1.Visible = false;


            this.CurrentVersion = this.getCurrentVersion(Application.StartupPath + "\\Pandora.exe");
            this.GetConfigValue();
            this.GetTheLastestVersionInfo();

            if (string.Compare(this.LastestVersion, this.CurrentVersion) > 0)
            {

                if (!checkPandoraProcess()) 
                    this.updateSetUp();

                //this.notifyIcon1.Text = "检测到新版本" + this.LastestVersion + ",准备开始更新";
                this.notifyIcon1.BalloonTipTitle = "小P"; 
                this.notifyIcon1.BalloonTipText = "检测到新版本" + this.LastestVersion + ",准备开始更新";
                this.notifyIcon1.Visible = true;
                this.notifyIcon1.ShowBalloonTip(10000);
                //Thread.Sleep(2000);
                this.UpdateStart();
            }
            else {
                this.notifyIcon1.BalloonTipTitle = "小P";
                this.notifyIcon1.BalloonTipText = "当前已是最新版本";
                this.notifyIcon1.Visible = true;
                this.notifyIcon1.ShowBalloonTip(10000);
                Thread.Sleep(2000);
                Application.Exit();
            }
            
        }


        private void updateSetUp() {

           
            if (Directory.Exists(Application.StartupPath + "\\update"))
            {
                DirectoryInfo parentdi = new DirectoryInfo(Application.StartupPath + "\\update");
                foreach (FileInfo fi in parentdi.GetFiles())//访问当前目录的文件
                {
                    string version = this.getCurrentVersion(fi.FullName);
                    //string version = fi.Name.Replace("Pandora_", "").Replace(".exe", "").Replace("XiaoP Setup", "");
                    if (string.Compare(version, this.LastestVersion) == 0)
                    {
                        this.notifyIcon1.BalloonTipTitle = "小P";
                        this.notifyIcon1.BalloonTipText = "升级程序包" + this.LastestVersion + ",开始安装";
                        System.Diagnostics.Process.Start(fi.FullName, "/S /D=" + Application.StartupPath);
                        this.notifyIcon1.Visible = true;
                        this.notifyIcon1.ShowBalloonTip(10000);
                        Thread.Sleep(2000);
                        Application.Exit();
                    }
                }
            }
            
            
        
        }

        private void UpdateStart() {
            float tempf;
            //委托下载数据时事件 
            this.downWebClient.DownloadProgressChanged += delegate(object wcsender, DownloadProgressChangedEventArgs ex)
            {
                /*
                this.Lbl_Process.Text = String.Format(
                    CultureInfo.InvariantCulture,
                    "正在下载:{0}  [ {1}/{2} ]",
                    fileName,
                    ConvertSize(ex.BytesReceived),
                    ConvertSize(ex.TotalBytesToReceive));
                */

                fileSize = ex.TotalBytesToReceive;
                tempf = ((float)(upSize + ex.BytesReceived) / totalSize);
                //this.progressBar1.Value = Convert.ToInt32(tempf * 100);
                //this.ProgressBar_Download.Value = ex.ProgressPercentage;
                //this.notifyIcon1.BalloonTipText = "已下载"+ex.ProgressPercentage+"%";
                //this.notifyIcon1.ShowBalloonTip
                //this.notifyIcon1.ShowBalloonTip(1000);
            };
            //委托下载完成时事件 
            this.downWebClient.DownloadFileCompleted += delegate(object wcsender, AsyncCompletedEventArgs ex)
            {
                if (ex.Error != null)
                {
                    //MeBox(ex.Error.Message);
                    this.Close();
                }
                else
                {
                   
                    upSize += fileSize;
                    if (fileNames.Length > downloadedNum)
                    {
                        DownloadFile(downloadedNum);
                    }
                    else
                    {
                        //SetConfigValue("conf.config", "UpDate", this.LastUpdateTime);
                        //this.notifyIcon1.BalloonTipText = "更新程序下载完毕";

                        this.notifyIcon1.Visible = true;

                        if (checkPandoraProcess())
                        {
                            this.notifyIcon1.ShowBalloonTip(30000, "小P" + this.LastestVersion + "版本下载完毕", "您可以点击立刻升级\n或忽略下次重启将自动更新", ToolTipIcon.None);
                            this.finished = true;
                            Thread.Sleep(10000);
                            Application.Exit();
                        }
                        else {

                            this.updateSetUp();
                        }
                        
                        
                        //UpdaterClose();
                    }
                }
            };

            totalSize = GetUpdateSize(UpdateUrl + "fileSize.php");
            //size = 1000;
            if (totalSize == 0)
            {
                Application.Exit();
                //UpdaterClose();
            }

            downloadedNum = 0;
            upSize = 0;
            if (fileNames != null)
                DownloadFile(0);        
        

        }

        /// <summary> 
        /// 下载文件 
        /// </summary> 
        /// <param name="arry">下载序号</param> 
        private void DownloadFile(int arry)
        {
            try
            {
                downloadedNum++;
                fileName = fileNames[arry];
                /*
                this.label1.Text = String.Format(
                    CultureInfo.InvariantCulture,
                    "更新进度 {0}/{1}  [ {2} ]",
                    num,
                    count,
                    ConvertSize(size));
                */

                //this.ProgressBar_Download.Value = 0;

                string dstDir = Application.StartupPath + "\\update\\";
                if (!Directory.Exists(dstDir))
                    Directory.CreateDirectory(dstDir);

                this.downWebClient.DownloadFileAsync(
                    new Uri(UpdateUrl + "versions/" + fileName),
                    Application.StartupPath + "\\update\\" + fileName);
            }
            catch (WebException ex)
            {
                Console.Write(ex.Message);
                this.Close();
            }
        }


        /// <summary> 
        /// 获取更新文件大小统计 
        /// </summary> 
        /// <param name="filePath">更新文件数据XML</param> 
        /// <returns>返回值</returns> 
        private static long GetUpdateSize(string filePath)
        {
            long len;
            len = 0;
            try
            {
                WebClient wc = new WebClient();
                Stream sm = wc.OpenRead(filePath);
                XmlTextReader xr = new XmlTextReader(sm);
                while (xr.Read())
                {
                    if (xr.Name == "UpdateSize")
                    {
                        len = Convert.ToInt64(xr.GetAttribute("Size"), CultureInfo.InvariantCulture);
                        break;
                    }
                }
                xr.Close();
                sm.Close();
            }
            catch (WebException ex)
            {
                Console.Write(ex.Message);
            }
            return len;
        }



        /// <summary> 
        /// 读取.exe.config的值 
        /// </summary> 
        /// <param name="path">.exe.config文件的路径</param> 
        /// <param name="appKey">"key"的值</param> 
        /// <returns>返回"value"的值</returns> 
        internal void GetConfigValue()
        {

            this.UpdateUrl = "http://10.148.96.28/";

            String[] serverIp = HttpHelper.httpPost("http://oa.yt-inc.com/api/xiaop/index.jspa?act=server", null, 1000).Trim().Split(',');
            if (serverIp.Length > 0)
            {
                Random random = new Random();
                this.UpdateUrl = "http://"+serverIp[random.Next(serverIp.Length)]+"/";
            }

        }

        public string getCurrentVersion(string exePath)
        {

            try
            {
                System.Diagnostics.FileVersionInfo file1 = System.Diagnostics.FileVersionInfo.GetVersionInfo(exePath);
                return  file1.FileVersion;
            }
            catch (Exception)
            {
                return " ";
            }

        }


        /// <summary> 
        /// 判断软件的更新日期 
        /// </summary> 
        /// <param name="Dir">服务器地址</param> 
        /// <returns>返回日期</returns> 
        private void GetTheLastestVersionInfo()
        {
            //string LastUpdateTime = "";
            string AutoUpdaterFileName = this.UpdateUrl + "AutoUpdater.xml";

            XmlNode xUpdateNode;
            XmlNodeList nodeList;
            XmlElement xVersion;
            XmlDocument xDoc = new XmlDocument();
            Stream sm = null;
            XmlTextReader xml = null; 
            try
            {
                WebClient wc = new WebClient();
                sm = wc.OpenRead(AutoUpdaterFileName);
                xml = new XmlTextReader(sm);
                xDoc.Load(xml);



                xUpdateNode = xDoc.SelectSingleNode("//UpdateInfo");

                xVersion = (XmlElement)xDoc.SelectSingleNode("//Version");

                this.LastestVersion = xVersion.GetAttribute("Num");

                nodeList = xDoc.SelectNodes("//UpdateFileList/UpdateFile");//.SelectSingleNode("//appSettings");

                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < nodeList.Count; i++)
                {

                    XmlNode node = nodeList[i];
                    if (i == 0)
                    {
                        sb.Append(node.InnerText);
                    }
                    else
                    {
                        sb.Append("," + node.InnerText);
                    }

                }

                fileNames = sb.ToString().Split(',');

            }
            catch (WebException ex)
            {
                Console.Write(ex.ToString());
            }
            finally {
                if (sm != null)
                    sm.Close();
                if (xml != null)
                    xml.Close();
            
            }
        }

        /// <summary> 
        /// 转换字节大小 
        /// </summary> 
        /// <param name="byteSize">输入字节数</param> 
        /// <returns>返回值</returns> 
        private static string ConvertSize(long byteSize)
        {
            string str = "";
            float tempf = (float)byteSize;
            if (tempf / 1024 > 1)
            {
                if ((tempf / 1024) / 1024 > 1)
                {
                    str = ((tempf / 1024) / 1024).ToString("##0.00", CultureInfo.InvariantCulture) + "MB";
                }
                else
                {
                    str = (tempf / 1024).ToString("##0.00", CultureInfo.InvariantCulture) + "KB";
                }
            }
            else
            {
                str = tempf.ToString(CultureInfo.InvariantCulture) + "B";
            }
            return str;
        }

        private void MainForm_FormClosed(object sender, FormClosedEventArgs e)
        {
            if (this.AppExe != "")
                System.Diagnostics.Process.Start(this.AppExe, "-i");
        }

        private void notifyIcon1_BalloonTipClicked(object sender, EventArgs e)
        {
            if (this.finished)
            {
                //MessageBox.Show("fff");
                System.Diagnostics.Process.Start(Application.StartupPath+"//update//"+fileNames[0]);
                Application.Exit();
            }
        }


        private static bool checkPandoraProcess() { 
        
           //Process current = Process.GetCurrentProcess();
           Process[] processes = Process.GetProcessesByName("Pandora");
           if (processes.Length > 0)
               return true;
           return false;
        }

    }
}
