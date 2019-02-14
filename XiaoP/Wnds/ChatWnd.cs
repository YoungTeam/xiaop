using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using XiaoP.Classes;
using XiaoP.Classes.Data;
using XiaoP.Classes.Service;
using XiaoP.Classes.Util;
using System.Windows.Forms;
using System.Collections;
using System.Timers;
using System.IO;
using System.Runtime.InteropServices;
using Newtonsoft.Json;
using System.Threading;
using XiaoP.UI.Core.Bolt;
using Pandora.Module.Component;
using Pandora;
using CaptureTool;


namespace XiaoP.Wnds
{
    internal sealed class ChatWnd : LuaBaseView, IMessageFilter
    {
        public  User user = null;
        public Group group = null;

        public event Action<string> OnResultFinish;
        public event Action<string,string,IntPtr> OnHandleFinish;

        public Queue chatQueue = new Queue();
        public Queue imgQueue = new Queue();
        private Thread chatThread = null;

        private bool hasTalked = false;

        private int curPage = 1;
        private int totalPages = 1;

        private System.Timers.Timer CheckTimer;

        public Hashtable ChatWndClasss = new Hashtable();

        public ChatWnd() {

            API.OleInitialize(IntPtr.Zero);
            XLBolt.Instance().AddMessageFilter(this);
          
        }

        public bool PreFilterMessage(ref  Message msg)
        {

            //Console.Write(msg.Msg+"=====" + msg.WParam + "=====" + msg.LParam + "\n");
            bool ret = false;

            if (msg.Msg == API.WM_SYSKEYDOWN) {

                switch ((Keys)msg.WParam.ToInt32())
                {
                    case (Keys.C):
                        if ((API.GetAsyncKeyState((int)Keys.Menu) & 0x8000) != 0)
                        {
                            returnResult("close", "");
                        }
                     
                        ret = true;
                        break;
                    case (Keys.S):
                        if ((API.GetAsyncKeyState((int)Keys.Menu) & 0x8000) != 0)
                        {
                            returnResult("sendChat","");
                            //this.sendChat();
                            ret = true;
                        }
                       
                        break;

                };
            
            }
            else if (msg.Msg == API.WM_KEYDOWN)
            {
                switch ((Keys)msg.WParam.ToInt32())
                {
                    case (Keys.Escape):
                        //returnResult("close", "");
                        ret = true;
                        break;
                    
                          case (Keys.Enter):
                               
                              Console.Write("\nenter\n");

                              if ((API.GetAsyncKeyState((int)Keys.ControlKey) & 0x8000) != 0)
                              {
                                  if (Global.SEND_MODE == "CtrlEnter")
                                  {
                                      returnResult("sendChat", "");
                                      ret = true;
                                  }
                                  Console.Write("\nctrl+enter\n");
                              }
                              else
                              {
                                  if (Global.SEND_MODE == "Enter")
                                  {
                                      returnResult("sendChat", "");
                                      ret = true;
                                  }
                              }

                              break;
                  
                          case (Keys.V):
                               
                              if ((API.GetAsyncKeyState((int)Keys.ControlKey) & 0x8000) != 0)
                              {
                                  this.RichTextBox_Paste();
                                  /*
                                  if (this.ExtRichTextBox_Send.Focused)
                                  {
                                      this.RichTextBox_Paste(this.ExtRichTextBox_Send);
                                      //Console.Write(msg.Msg+"=====" + msg.WParam + "=====" + msg.LParam + "\npaste===\n");
                                      ret = true;
                                  }*/


                                  //returnResult("pasteSendRichEdit","");
                              }
                              break;
                          case (Keys.C):
                                /*
                              if ((API.GetAsyncKeyState((int)Keys.ControlKey) & 0x8000) != 0)
                              {

                                  if (this.ExtRichTextBox_Chat.Focused)
                                  {
                                      this.RichTextBox_Copy(this.ExtRichTextBox_Chat);
                                      ret = true;
                                  }
                                  else if (this.ExtRichTextBox_Send.Focused)
                                  {
                                      this.RichTextBox_Copy(this.ExtRichTextBox_Send);
                                      ret = true;
                                  }

                              }*/
                              break;


                }
            }
            
            return ret;
        }

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


        public void initGroup(string groupId) {

         
            int chatCount = MainWnd.ChatStack.Count("group-"+groupId);
            MainWnd.GetInstance().cancelGroupChatSignal(groupId);
            //Global.CUR_USER = UserService.getInfoById("yangting");
            Thread thread = new Thread(new ThreadStart(
                () =>
                {
                    if (this.group == null)
                        this.group = GroupService.getGroupInfo(groupId);
                    returnResult("info", this.group);

                    List<string> lastestChat = ChatService.getLastestChatHistory(this.group.uuid, chatCount);
                    returnResult("lastestchats", lastestChat);
                   
                    if (this.group.groupType == "dept")
                        this.group.members = GroupService.getDeptGroupMembers(groupId);
                    else if(this.group.groupType == "mail")
                        this.group.members = GroupService.getMailGroupMembers(groupId);

                    for (int i =0;i < this.group.members.Count;i++)
                    {
                        if (this.group.members[i].userNo == this.group.groupManager)
                        {
                            this.group.members[i].isManager = true;
                            break;
                        }
                    }

                    returnResult("members", this.group.members);
                }
             ));

            thread.IsBackground = true;
            thread.Start();


            chatThread = new Thread(new ThreadStart(() =>
            {
                ChatService.receiveGroupChat(this, groupId, returnResult);
            }));
            chatThread.Name = "Thread : " + groupId + ".listen";
            chatThread.IsBackground = true;
            chatThread.Start();


            //线程检查定时器
            CheckTimer = new System.Timers.Timer();
            CheckTimer.Elapsed += new ElapsedEventHandler(Timer_Check_Tick);
            CheckTimer.Interval = 20000;
            CheckTimer.Enabled = true;
            CheckTimer.Start();



            initEmotions();
            this._emotion.EmotionContainer.ItemClick += delegate(object sender1, Pandora.Module.Component.EmotionPanel.EmotionItemMouseClickEventArgs e1)
            {

                TxtMsg txtMsg = new TxtMsg();

                ImgMsg imgMsg = new ImgMsg();
                imgMsg.id = e1.Item.id.ToString();
                imgMsg.pos = -1;
                imgMsg.type = "gif";
                imgMsg.from = "emotion";
                imgMsg.width = 24;
                imgMsg.height = 24;

                txtMsg.imgList.Add(imgMsg);

                returnResult("appendSendRichEdit", txtMsg);

            };

            returnResult("setCharFormat", Global.CUR_FONT.fmt);
        }

        public void init(string userId) {

            //Global.CUR_USER = UserService.getInfoById("yangting");
            returnResult("setCharFormat", Global.CUR_FONT.fmt);

            MainWnd.GetInstance().cancelChatSignal(userId);
           
            Thread thread = new Thread(new ThreadStart(
                () =>
                {
                    if (this.user == null)
                        this.user = UserService.getInfoById(userId);

                    returnResult("info", this.user);
     
                }
             ));

            thread.IsBackground = true;
            thread.Start();

            
            chatThread = new Thread(new ThreadStart(() => {
                ChatService.receiveChat(this,userId,returnResult);
            }));
            chatThread.Name = "Thread : " + userId + ".listen";
            chatThread.IsBackground = true;
            chatThread.Start();


            //线程检查定时器
            CheckTimer = new System.Timers.Timer();
            CheckTimer.Elapsed += new ElapsedEventHandler(Timer_Check_Tick);
            CheckTimer.Interval = 20000;
            CheckTimer.Enabled = true;
            CheckTimer.Start();


            
            initEmotions();
            this._emotion.EmotionContainer.ItemClick += delegate(object sender1, Pandora.Module.Component.EmotionPanel.EmotionItemMouseClickEventArgs e1)
            {
                TxtMsg txtMsg = new TxtMsg();

                ImgMsg imgMsg = new ImgMsg();
                imgMsg.id = e1.Item.id.ToString();
                imgMsg.pos = -1;
                imgMsg.type = "gif";
                imgMsg.from = "emotion";
                imgMsg.width = 24;
                imgMsg.height = 24;

                txtMsg.imgList.Add(imgMsg);

                returnResult("appendSendRichEdit", txtMsg);

            };

            

        }

        public void updateUserInfo(User user ) {
            returnResult("userInfo",user);
        }

        private Pandora.Forms.Im.EmotionDropdown _emotion = new Pandora.Forms.Im.EmotionDropdown();
        public void initEmotions() {

            Thread thread = new Thread(new ThreadStart(
              () =>
              {
                if (Global.EMOTION_LIST.Count == 0) { 
                    for (int i = 1; i < 133; i++)
                    {
                        Global.EMOTION_LIST.Add(
                            new Bitmap(Global.PANDORA_PFOFILE + "system\\emotion\\default\\" + i + ".gif")
                            // new Pandora.Module.Component.EmotionPanel.EmotionItem(i, "EmotionItem1", new Bitmap(PGlobal.PANDORA_PFOFILE + "system\\emotion\\default\\" + i + ".gif"))
                        );
                    }
                }

                int j = 1;
                foreach (System.Drawing.Image img in Global.EMOTION_LIST)
                {
                    this._emotion.EmotionContainer.Items.Add(new Pandora.Module.Component.EmotionPanel.EmotionItem(j, "EmotionItem"+j, (System.Drawing.Image)img.Clone()));
                    j++;
                }

              }
           ));

            thread.IsBackground = true;
            thread.Start();

        }


        /***线程检查****/
        private void Timer_Check_Tick(object sender, ElapsedEventArgs e)
        {
            if (chatThread.ThreadState != (System.Threading.ThreadState.WaitSleepJoin | System.Threading.ThreadState.Background)) {
                while (chatThread.IsAlive)
                {
                    chatThread.Abort();
                }
                chatThread = new Thread(new ThreadStart(() =>
                {
                    if(this.user!=null)
                        ChatService.receiveChat(this, this.user.userId, returnResult);
                    if(this.group!=null)
                        ChatService.receiveGroupChat(this, this.group.groupId, returnResult);
                }));
                chatThread.IsBackground = true;
                if(this.group!=null)
                    chatThread.Name = "Thread : " + this.group.groupId + ".listen";
                else if (this.user != null)
                    chatThread.Name = "Thread : " + this.user.userId + ".listen";
                
                chatThread.Start();
            }
            
        }


        /************************************/
        public void setIcon(IntPtr wnd)
        {
            try
            {   Icon icon = null;
                if(this.user!=null){
                    Bitmap face = new Bitmap(UserService.getFace(this.user.userId));
                    IntPtr ico = face.GetHicon();
                    icon = new Icon(Icon.FromHandle(ico), new Size(32, 32));
                }
                else if (this.group != null) {
                    if (this.group.groupType == "dept")
                        icon = global::XiaoP.Properties.Resources.dept_group;
                    else if (this.group.groupType == "mail")
                        icon = global::XiaoP.Properties.Resources.mail_group;

                }
                    
               
                SystemHelper.setAppIcon(wnd, icon);
            }
            catch (Exception ex) {

                PLog.Exception(ex);
            }
        }

        public void flashWindow(IntPtr wnd,bool flash) {

            if (flash)
            {
                FlashWindow.Start(wnd);
            }
            else
            {

                FlashWindow.Stop(wnd);
            }
        }

        public void popupEmotion(int x,int y) {
            int width = this._emotion.Width;
            int height = this._emotion.Height;
            Point p = new Point(x-width/2,y-height-5);
            this._emotion.Show(p);
        }

        public void captureScreen() {

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

        public void getUserInfo(string userId)
        {
            Thread thread = new Thread(new ThreadStart(
                () =>
                {
                    if (user == null)
                        user = UserService.getInfoById(userId);
                    returnResult("info", user);
                }

             ));

            thread.IsBackground = true;
            thread.Start();

        }

        /***************************************************/
        private List<SendImage> SendImages = new List<SendImage>();
        private List<SendImage> RecGifs = new List<SendImage>();

        public Rectangle addSendImg(IntPtr hBmp, string id, string type)
        {
          
            bool ret = ImgHelper.SaveXLBitmapToFile(hBmp, Global.CUR_USER.profiles + "images\\", id + ".jpg", 100);
            if(ret == false)
                return new Rectangle(0,0,0,0);

            Image img = ImgHelper.getImageFromFile(Global.CUR_USER.profiles + "images\\" + id + ".jpg");

            SendImage sImage = new SendImage();//要发送的图片文件类
            sImage.id = id;
            sImage.from = Global.CUR_USER.userId;

            if (this.user != null)
                sImage.to = this.user.userId;
            else
                sImage.to = this.group.groupId;

            if (type == "gif")
            {
                sImage.isAnimate = true;
            }

            sImage.image = img;
            SendImages.Add(sImage);
            
            return ImgHelper.getScalingRec(img,200,200);
        }
        
        public string sendChat(string richText)
        {

            //标记是否聊过
            hasTalked = true;

            TxtMsg textMsg = new TxtMsg();
            textMsg.fromXJson(richText);
            
            textMsg.from = Global.CUR_USER.userId;
            
            if (this.user != null)
            {
                textMsg.to = this.user.userId;
                textMsg.uuId = ChatService.getRelationId(textMsg.from, textMsg.to);
            }
            else
            {
                textMsg.to = this.group.groupId;
                textMsg.uuId = this.group.uuid;
            }


            textMsg.userName = Global.CUR_USER.userName;
            textMsg.sendTime = DateHelper.getServerTime();//DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");

            textMsg.font = Global.CUR_FONT.font;//获得文本字体
            textMsg.color = Global.CUR_FONT.color;

            //this.appendToTextAreaRecord(textMsg, 0);
            
            Thread thread = new Thread(new ThreadStart(
               () =>
               {
                   ChatService chatService = new ChatService();
                   if (this.group != null)
                   {
                       if (chatService.sendGroupChat(textMsg, this.group))
                       {   //如果有图片补充发
                           this.sendSelfImage();//发送附加的自定义图片图片
                       }

                   }
                   else
                   {
                       if (chatService.sendChat(textMsg))
                           this.sendSelfImage();//发送附加的自定义图片图片

                   }
               }
            ));

            thread.IsBackground = true;
            thread.Start();

            return textMsg.toXJson();
        }

        /*****************************************************/

        public void dequeueChat() {

            if (chatQueue.Count > 0) {
                TxtMsg txtMsg = (TxtMsg)chatQueue.Dequeue();
                returnResult("appendChatRichEdit", txtMsg.toXJson());
            }

            if (imgQueue.Count > 0) {

                SendImage sImg = (SendImage)imgQueue.Dequeue();
                ImgHelper.SaveQuality(sImg.image, Global.CUR_USER.profiles + "images\\", sImg.id + ".jpg");

                OnHandleFinish(sImg.id, "jpg", ImgHelper.getImgHandleFromFile(Global.CUR_USER.profiles + "images\\"+sImg.id + ".jpg"));
            }

        }

        public void updateChatHistory()
        {
            string uuId = "";
            if (this.user != null)
                uuId = ChatService.getRelationId(this.user.userId, Global.CUR_USER.userId);
            else if (this.group != null)
                uuId = this.group.uuid;

            Thread thread = new Thread(new ThreadStart(
               () =>
               {
                   Hashtable[] chatHistory = null;
                   try
                   {
                       chatHistory = ChatService.getChatHistory(uuId, curPage);
                       this.totalPages = int.Parse(chatHistory[chatHistory.Length - 1]["totalPages"].ToString());
                   }
                   catch (Exception ex)
                   {
                       PLog.Exception(ex);
                   }


                   if (chatHistory == null || chatHistory.Length < 2)
                       return;

                   string dateStr = "";
                   List<string> chatList = new List<string>();
                   for (int i = 0; i < chatHistory.Length - 1; i++)
                   {

                       Hashtable chat = chatHistory[i];
                       TxtMsg txtMsg = new TxtMsg(chat);

                       string thisDate = txtMsg.sendTime.Substring(0, 10);

                       if (thisDate != dateStr)
                       {
                           dateStr = thisDate;
                           chatList.Add("{\"spliter\":\"" + dateStr + "\"}");
                       }

                       chatList.Add(txtMsg.toXJson());

                   }

                   returnResult("updateHistoryRichEdit", chatList);
                   this.totalPages = int.Parse(chatHistory[chatHistory.Length - 1]["totalPages"].ToString());
                   if (this.curPage == 0)
                       this.curPage = this.totalPages;

                   Hashtable pageInfo = new Hashtable();
                   pageInfo.Add("curPage",this.curPage);
                   pageInfo.Add("totalPages", this.totalPages);

                   returnResult("history", pageInfo);
               }
            ));

            thread.IsBackground = true;
            thread.Start();
        }

        public void getHistory(string type) {
            switch (type)
            {
                case "first":
                    this.curPage = this.totalPages;
                    break;
                case "prev":
                    this.curPage++;
                    if (this.curPage > this.totalPages)
                        this.curPage = this.totalPages;
                    break;
                case "next":
                    this.curPage--;
                    if (this.curPage <= 0)
                    {
                        this.curPage = 1;
                        return;
                    }
                    break;
                case "last":
                    this.curPage = 1;
                    break;
            }

            this.updateChatHistory();
           
        }

        public void getGroupHistory(string type)
        {
            switch (type) { 
                case "first":
                    this.curPage = this.totalPages;
                    break;
                case "prev":
                    this.curPage++;
                    if (this.curPage > this.totalPages)
                        this.curPage = this.totalPages;
                    break;
                case "next":
                    this.curPage--;
                    if (this.curPage <= 0)
                    {
                        this.curPage = 1;
                        return;
                    }
                    break;
                case "last":
                    this.curPage = 1;
                    break;
            }

            this.updateChatHistory();

        }

        public void destroy()
        {

            XLBolt.Instance().RemoveMessageFilter(this);

            if (this.user != null && this.hasTalked)
                MainWnd.GetInstance().addRecent(this.user);

            if (CheckTimer != null)
                CheckTimer.Stop();


            Thread thread = new Thread(new ThreadStart(
              () =>
              {
                  if (chatThread != null)
                  {
                      while (chatThread.IsAlive)
                      {
                          chatThread.Abort();
                      }
                  }
              }
           ));

            thread.IsBackground = true;
            thread.Start();



        }

        private void sendSelfImage()//发送图片文件
        {
            ChatService chatService = new ChatService();
            foreach (SendImage sImage in this.SendImages)
            {
                if (this.user != null)
                    chatService.sendImgs(sImage);
                else if (this.group != null)
                    chatService.sendGroupImgs(sImage);
            }

            this.SendImages.Clear();
        }
    
     
        private ComboBox Cbx_FStyle_Dialog = new ComboBox();
        public IntPtr getFontStyleCombobox() {

            this.Cbx_FStyle_Dialog.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.Cbx_FStyle_Dialog.FormattingEnabled = true;
            this.Cbx_FStyle_Dialog.IntegralHeight = false;
            this.Cbx_FStyle_Dialog.Items.AddRange(new object[] {
            "方正姚体",
            "黑体"});


            //如何获得系统字体列表
            System.Drawing.Text.InstalledFontCollection fonts = new System.Drawing.Text.InstalledFontCollection();
            foreach (System.Drawing.FontFamily family in fonts.Families)
            {
                if (family.IsStyleAvailable(FontStyle.Regular))
                    this.Cbx_FStyle_Dialog.Items.Add(family.Name);
            }

            Font f = Global.CUR_FONT.font;
            this.Cbx_FStyle_Dialog.Text = f.FontFamily.Name;

            this.Cbx_FStyle_Dialog.SelectedIndexChanged += new System.EventHandler((object sender, EventArgs e) =>
            {
                this.selectFont();
            });
            this.Cbx_FStyle_Dialog.KeyPress += new System.Windows.Forms.KeyPressEventHandler((object sender, KeyPressEventArgs e) =>
            {
                e.Handled = true;
            });

            return this.Cbx_FStyle_Dialog.Handle;
        }

        private ComboBox Cbx_FSize_Dialog = new ComboBox();
        public IntPtr getFontSizeCombobox(){
            this.Cbx_FSize_Dialog.Font = new System.Drawing.Font("Microsoft YaHei", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.Cbx_FSize_Dialog.FormattingEnabled = true;
            this.Cbx_FSize_Dialog.IntegralHeight = false;
            this.Cbx_FSize_Dialog.Items.AddRange(new object[] {
            "9",
            "10",
            "11",
            "12",
            "13",
            "14",
            "15",
            "16",
            "17",
            "18",
            "19",
            "20",
            "21",
            "22"});
           // this.Cbx_FSize_Dialog.Text = "9";
            this.Cbx_FSize_Dialog.SelectedText = ""+Convert.ToInt32(Global.CUR_FONT.font.Size);
            this.Cbx_FSize_Dialog.SelectedIndexChanged += new System.EventHandler((object sender, EventArgs e) =>
            {
                this.selectFont();
            });

            this.Cbx_FSize_Dialog.KeyPress += new System.Windows.Forms.KeyPressEventHandler(
              (object sender, KeyPressEventArgs e) =>
              {
                  e.Handled = true;
              }  
             );

            return this.Cbx_FSize_Dialog.Handle;
        }


        private void selectFont()
        {
            
            FontStyle fontStyle = FontStyle.Regular;
            if (Global.CUR_FONT.font.Underline)
                fontStyle |= FontStyle.Underline;
            if(Global.CUR_FONT.font.Italic)
                fontStyle |= FontStyle.Italic;
            if (Global.CUR_FONT.font.Bold)
                fontStyle |= FontStyle.Bold;
           
            if (this.Cbx_FSize_Dialog.Text != "")
            {
                Global.CUR_FONT.font = new Font(this.Cbx_FStyle_Dialog.Text, float.Parse(this.Cbx_FSize_Dialog.Text), fontStyle);
                //this.ExtRichTextBox_Send.Font = Global.CUR_FONT.font;

                SystemHelper.saveFontProperties();
            }

           // Global.CUR_FONT.toXJson();
            returnResult("setCharFormat", Global.CUR_FONT.fmt);
        }

        public void selectFontStyle(bool isU,bool isI,bool isB) {
            FontStyle fontStyle = FontStyle.Regular;
            if (isU)
                fontStyle |= FontStyle.Underline;
            if (isI)
                fontStyle |= FontStyle.Italic;
            if (isB)
                fontStyle |= FontStyle.Bold;

            if (this.Cbx_FSize_Dialog.Text != "")
            {
                Global.CUR_FONT.font = new Font(Global.CUR_FONT.font.FontFamily, Global.CUR_FONT.font.Size, fontStyle);
                //this.ExtRichTextBox_Send.Font = Global.CUR_FONT.font;

                SystemHelper.saveFontProperties();
            }
            returnResult("setCharFormat", Global.CUR_FONT.fmt);
        }


        public void clickFontColor() {
            System.Windows.Forms.ColorDialog cd = new ColorDialog();
            if (cd.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                //this.ExtRichTextBox_Send.ForeColor = cd.Color;
                Global.CUR_FONT.color = cd.Color;
                SystemHelper.saveFontProperties();
                returnResult("setCharFormat", Global.CUR_FONT.fmt);
            }
        }
         
        /*
        private void RichTextBox_Copy(MyExtRichTextBox richTextBox)
        {
            XmlHelper.RTF2Clipboard(richTextBox);

        }*/

      

        private void RichTextBox_Paste()
        {
            System.Windows.Forms.IDataObject vDataObject = Clipboard.GetDataObject();

            TxtMsg txtMsg = new TxtMsg();
            if (vDataObject.GetData("QQ_Unicode_RichEdit_Format") != null)
            {

                string xml = Encoding.UTF8.GetString(((MemoryStream)vDataObject.GetData("QQ_Unicode_RichEdit_Format")).ToArray());
                //XmlHelper.Xml2RTF(xml, this.ExtRichTextBox_Send);
            }
            else
            {
                Image img = Clipboard.GetImage();
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
                else {

                    txtMsg.content = Clipboard.GetText();
                }
            }

        }

    }
}
