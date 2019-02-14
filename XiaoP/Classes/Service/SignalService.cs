using System;
using System.Collections.Generic;
using System.Text;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using RabbitMQ.Client.MessagePatterns;
using Newtonsoft.Json;
using System.Collections;
using System.Threading;
using System.Drawing;
using System.Windows.Forms;
using System.Globalization;
using XiaoP.Classes.RabbitMQ;
using XiaoP.Classes.Data;
using XiaoP.Classes.Util;
using XiaoP.UI.Core.Bolt;
using XiaoP.Wnds;

namespace XiaoP.Classes.Service
{
    class SignalService
    {

        private static RabbitMQHelper heartbeatMQ = null;
        public static void sendHeartBeat() {
            Exchange exchange = new Exchange("heartbeat", Exchange.EXCHANGE_FANOUT, false, true);
            if (heartbeatMQ == null)
                heartbeatMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER, "heartbeat", "xiaop", "sogouorz");       
            heartbeatMQ.send(exchange, Encoding.UTF8.GetBytes(Global.CUR_USER.userId + "|" + Global.CUR_USER.version + "|" + Global.CUR_USER.loginIP));

        }

        public static void receive(Action<string,object> handler)
        {

            Exchange exchange = new Exchange("pandora.direct", Exchange.EXCHANGE_DIRECT);
            XiaoP.Classes.RabbitMQ.Queue queue = new XiaoP.Classes.RabbitMQ.Queue(Global.CUR_USER.userId, true, false, false);
            
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER, "notice", "pandora", "sogouorz"))
            {
                rabbitMQ.receive(exchange, queue, queue.name, (byte[] data) => {
                    try
                    {
                        string json = "";

                        IdentifyEncoding identifyEncoding = new IdentifyEncoding();

                        sbyte[] sdata = new sbyte[data.Length];
                        Buffer.BlockCopy(data, 0, sdata, 0, data.Length);
                        string encodeType = identifyEncoding.GetEncodingName(sdata);

                        if (encodeType == "GB2312")
                        {
                            json = Encoding.Default.GetString(data);// messageText(ev);                   
                        }
                        else
                        {
                            json = Encoding.UTF8.GetString(data);// messageText(ev);                   

                        }

                        Signal signal = null;
                        //如果是普通文本
                        if (json.StartsWith("{"))
                        {
                            Hashtable signalTable = JsonConvert.DeserializeObject<Hashtable>(json);

                            if (signalTable.ContainsKey("type"))
                            {
                                signal = new Signal(
                                signalTable["type"].ToString(),
                                Convert.ToDateTime(signalTable["time"].ToString(), CultureInfo.InvariantCulture),
                                Encoding.UTF8.GetBytes(signalTable["content"].ToString())
                                    );
                            }

                        }
                        else
                        {
                            signal = Signal.fromByte(data);
                        }

                        Console.Write("\n" + json + "" + Global.CUR_USER.loginTime + "\n\n");
                        if (signal != null)
                        {
                            signalDispatch(signal,handler);
                        }
                    }
                    catch (Exception ex)
                    {
                        PLog.Exception(ex);
                    }

                });
            }

        }

        private static bool isChatWndOpen(string content) {
            bool isChatWndOpen = false;
            foreach (IMessageFilter filter in XLBolt.Instance().GetMessageFilter())
            {
                if (filter.GetType().FullName == "XiaoP.Wnds.ChatWnd")
                {
                    ChatWnd chatWnd = (ChatWnd)filter;
                    if (content.StartsWith("group"))
                    {
                        if (chatWnd.group != null && ("group-" + chatWnd.group.groupId) == content)
                        {
                            isChatWndOpen = true;
                            break;
                        }

                    }
                    else
                    {
                        if (chatWnd.user != null && chatWnd.user.userId == content)
                        {

                            isChatWndOpen = true;
                            break;
                        }
                    }
                }
            }
            return isChatWndOpen;
        }


        private static void signalDispatch(Signal signal,Action<string,object> handler){
            string content = Encoding.UTF8.GetString(signal.content);
            Hashtable nt;
            Pop pop;

            switch (signal.type)
            {
                case "auth":

                    //如果消息提醒来自于登陆前
                    if (DateTime.Compare(Global.CUR_USER.loginTime, signal.time) >= 0)
                        break;

                    //Console.Write("\n" + PGlobal.CUR_USER.loginTime.ToString() + "=======" + content + "========" + signal.time.ToString() + "\n");
                    //Console.Write("\n=======" + content + "========\n");
                    if (content == "conflict")
                    {
                        handler(signal.type, content);
                    }
                    break;

                case "chat":
                    if (!isChatWndOpen(content))
                        MainWnd.ChatStack.Push(content);

                    if(MainWnd.ChatStack.Count(content)==1)
                        SystemHelper.PlayAudio(Application.StartupPath + @"/sounds/msg.wav");

                    handler(signal.type, content);
                    break;

                case "groupchat":
            
                    if (!isChatWndOpen(content))
                        MainWnd.ChatStack.Push(content);
                   
                    if(MainWnd.ChatStack.Count(content) == 1)                    
                        SystemHelper.PlayAudio(Application.StartupPath + @"/sounds/msg.wav");

                    handler(signal.type, content);
                    break;

                case "txt":
                    //如果消息提醒来自于登陆前
                    if (DateTime.Compare(Global.CUR_USER.loginTime, signal.time) > 0)
                        break;

                    nt = JsonConvert.DeserializeObject<Hashtable>(content);
                    pop = new TxtPop(nt);

                    //如果notice不为空
                    if (pop != null)
                    {
                        handler(signal.type, pop);
                        //发声音
                        if (pop.delayCancel >= 0)
                            SystemHelper.PlayAudio(Application.StartupPath + @"/sounds/notice.wav");
                    }
                    break;
                case "imgtxt":
                    //如果消息提醒来自于登陆前
                    if (DateTime.Compare(Global.CUR_USER.loginTime, signal.time) > 0)
                        break;

                    nt = JsonConvert.DeserializeObject<Hashtable>(content);
                    pop = new ImgTxtPop(nt);

                    //如果notice不为空
                    if (pop != null)
                    {
                        handler(signal.type, pop);
                        //发声音
                        if (pop.delayCancel >= 0)
                            SystemHelper.PlayAudio(Application.StartupPath + @"/sounds/notice.wav");
                    }
                    break;

                case "task":

                    //如果消息提醒来自于登陆前
                    if (DateTime.Compare(Global.CUR_USER.loginTime, signal.time) > 0)
                        break;
                   // string noticeType = INIOperation.INIGetStringValue(PGlobal.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "noticeType", "Always");
                    //if (noticeType == "Never")
                      //  break;

                    nt = JsonConvert.DeserializeObject<Hashtable>(content);
                    pop = new NovaPop(nt);

                    if (pop != null)
                    {

                        handler(signal.type, pop);
                        //发声音
                        if (pop.delayCancel >= 0)
                            SystemHelper.PlayAudio(Application.StartupPath + @"/sounds/notice.wav");
                    }

                    System.Threading.Thread.Sleep(2000);
                    break;

                case "userInfo":
                    Hashtable userTable = JsonConvert.DeserializeObject<Hashtable>(content);
                    User user = new User(userTable);
                    foreach(ChatWnd chatWnd in SystemHelper.getOpenChatWnds()){
                        chatWnd.updateUserInfo(user);
                    }
                       
                    handler(signal.type, user);
                    break;
                case "nova":
                    if (MainWnd.GetInstance() != null)
                    {
                        MainWnd.GetInstance().getNovaTodo(Global.CUR_USER.userId);
                        MainWnd.GetInstance().getNovaMine(Global.CUR_USER.userId);
                    }
                    break;
                case "toChat":
                    handler(signal.type, content);
                    break;

            }                
        
        }
    }
}
