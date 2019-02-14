using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;
using System.IO;
using Newtonsoft.Json;
using System.Threading;
using XiaoP.Classes.RabbitMQ;
using XiaoP.Classes.Data;
using XiaoP.Classes.Util;
using System.Drawing;
using System.Security.Cryptography;
using XiaoP.Wnds;

namespace XiaoP.Classes.Service
{
    class ChatService
    {

        public static string getRelationId(string userId1, string userId2)
        {

            string[] twoArr = new string[] { userId1, userId2 };
            Array.Sort(twoArr);

            byte[] result = Encoding.UTF8.GetBytes(twoArr[0] + twoArr[1]);
            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] output = md5.ComputeHash(result);

            return BitConverter.ToString(output).Replace("-", "");

        }


        /// <summary>
        /// 发送聊天内容
        /// </summary>
        /// <param name="txtMsg"></param>
        /// <returns></returns>
        public bool sendChat(TxtMsg txtMsg)
        {
            Exchange exchange = new Exchange("pandora.direct", Exchange.EXCHANGE_DIRECT);
            XiaoP.Classes.RabbitMQ.Queue queue = new XiaoP.Classes.RabbitMQ.Queue(txtMsg.from + "-" + txtMsg.to, false, false, true);


            Exchange mexchange = new Exchange("pandora.mobile.direct", Exchange.EXCHANGE_DIRECT);
            XiaoP.Classes.RabbitMQ.Queue mqueue = new XiaoP.Classes.RabbitMQ.Queue(txtMsg.from + "-" + txtMsg.to + "-IOS", false, false, true);


            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER, "chat", "xiaop_chat", "sogouorz"))
            {
                //发送新消息信号
                if (rabbitMQ.send(exchange, queue, queue.name, txtMsg.toJson()))
                {
                    //发移动端消息
                    rabbitMQ.send(mexchange, mqueue, mqueue.name, txtMsg.toJson(), "utf-8");

                    //发送新聊天提醒
                    Thread broadcastThread = new Thread(new ThreadStart(delegate()
                    {

                        //存储数据库
                        using (RabbitMQHelper rabbitMQDB = new RabbitMQHelper(Global.RABBITMQ_SERVER))
                        {
                            rabbitMQDB.timeOut = 1000;

                            RPCRequest rpcRequest = new RPCRequest();
                            rpcRequest.className = "com.yt.xiaop.service.ChatService";
                            rpcRequest.methodName = "saveChat";
                            rpcRequest.args = new object[] {
                                txtMsg.uuId,
                                txtMsg.from,
                                txtMsg.to,
                                txtMsg.sendTime,
                                txtMsg.toBase64()
                            };
                            string response = rabbitMQDB.sendRequest(rpcRequest.toJson());

                        }

                        //发送新聊天提醒
                        XiaoP.Classes.RabbitMQ.Queue signalQueue = new XiaoP.Classes.RabbitMQ.Queue(txtMsg.to, true, false, false);

                        XiaoP.Classes.RabbitMQ.Queue mSignalQueue = new XiaoP.Classes.RabbitMQ.Queue(txtMsg.to + "-IOS", true, false, false);


                        using (RabbitMQHelper rabbitMQ1 = new RabbitMQHelper(Global.RABBITMQ_SERVER, "notice", "pandora", "sogouorz"))
                        {

                            Hashtable chatSignal = new Hashtable();
                            chatSignal.Add("type", "chat");
                            chatSignal.Add("time", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                            chatSignal.Add("content", txtMsg.from);

                            rabbitMQ1.send(exchange, signalQueue, txtMsg.to, JsonConvert.SerializeObject(chatSignal));

                            Hashtable mobileChatSignal = new Hashtable();
                            mobileChatSignal.Add("chat_user_id", txtMsg.from);
                            mobileChatSignal.Add("chat_user_name", txtMsg.userName);
                            mobileChatSignal.Add("notice_content", txtMsg.content);
                            mobileChatSignal.Add("notice_time", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                            mobileChatSignal.Add("notice_type", "CHAT");

                            rabbitMQ1.send(mexchange, mSignalQueue, txtMsg.to + "-IOS", JsonConvert.SerializeObject(mobileChatSignal), "utf-8");
                        }

                    }));

                    broadcastThread.IsBackground = true;
                    broadcastThread.Start();
                    return true;
                }
            }

            return false;

        }

        /// <summary>
        /// 发送图片
        /// </summary>
        /// <returns></returns>
        public  bool sendImgs(SendImage sImg)
        {

            Exchange exchange = new Exchange("pandora.direct", Exchange.EXCHANGE_DIRECT);
            XiaoP.Classes.RabbitMQ.Queue queue = new XiaoP.Classes.RabbitMQ.Queue(sImg.from + "-" + sImg.to, false, false, true);

            bool succ = false;
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER, "chat", "xiaop_chat", "sogouorz"))
            {
                succ = rabbitMQ.send(exchange, queue, queue.name, sImg.toByte());
                //存数据库
                if (succ)
                    succ = this.saveSnap(sImg);
            }
            return succ;

        }

        public bool sendGroupImgs(SendImage sImg)
        {
            bool succ = false;

            Exchange exchange = new Exchange("group.fanout." + sImg.to, Exchange.EXCHANGE_FANOUT, false, true);

            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER, "chat", "xiaop_chat", "sogouorz"))
            {
                succ = rabbitMQ.send(exchange, sImg.toByte());
                //存数据库
                if (succ)
                {
                    succ = this.saveSnap(sImg);
                    //Exchange exchange = new Exchange("group.fanout." + sImg.to, Exchange.EXCHANGE_FANOUT, false, true);

                    //RabbitMQHelper rabbitMQ = new RabbitMQHelper(PGlobal.RABBITMQ_SERVER, "chat", "xiaop_chat", "sogouorz");
                    //succ = rabbitMQ.send(exchange, sImg.toByte());
                }
            }

            return succ;
        }



        public static void receiveChat(ChatWnd chatWnd, string userId,Action<string, object> handler)
        {
            string queueName = userId + "-" + Global.CUR_USER.userId;

            Exchange exchange = new Exchange("pandora.direct", Exchange.EXCHANGE_DIRECT);
            XiaoP.Classes.RabbitMQ.Queue queue = new XiaoP.Classes.RabbitMQ.Queue(queueName, false, false, true);

            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER, "chat", "xiaop_chat", "sogouorz"))
            {

                rabbitMQ.receive(exchange, queue, queue.name, delegate(byte[] data)
                {


                    IdentifyEncoding identifyEncoding = new IdentifyEncoding();

                    sbyte[] sdata = new sbyte[data.Length];
                    Buffer.BlockCopy(data, 0, sdata, 0, data.Length);
                    string encodeType = identifyEncoding.GetEncodingName(sdata);

                    string chatStr = "";
                    if (encodeType == "GB2312")
                    {
                        chatStr = Encoding.Default.GetString(data);// messageText(ev);                   
                    }
                    else
                    {
                        chatStr = Encoding.UTF8.GetString(data);// messageText(ev);                   

                    }

                    //如果是普通文本
                    if (chatStr.StartsWith("{"))
                    {
                        try
                        {
                            PLog.Info(chatStr);
                            TxtMsg txtMsg = new TxtMsg(chatStr);
                            chatWnd.chatQueue.Enqueue(txtMsg);
                            //this.appendToTextAreaRecord(txtMsg, 1);
                        }
                        catch (Exception ex)
                        {
                            PLog.Exception(ex);
                        }
                    }//如果是图片
                    else
                    {
                        try
                        {
                            SendImage sImg = SendImage.fromByte(data);
                            chatWnd.imgQueue.Enqueue(sImg);
                        }
                        catch (Exception ex)
                        {
                            PLog.Exception(ex);
                        }
                    }

                    handler("newmsg", userId);

                });
            }

        }


        public static void receiveGroupChat(ChatWnd chatWnd, string groupId, Action<string, object> handler)
        {
            string queueName = Global.CUR_USER.userId + "-" + groupId;

            Exchange exchange = new Exchange("group.fanout." + groupId, Exchange.EXCHANGE_FANOUT, false, true);
            XiaoP.Classes.RabbitMQ.Queue queue = new XiaoP.Classes.RabbitMQ.Queue(queueName, false, false, true);

            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER, "chat", "xiaop_chat", "sogouorz"))
            {
                //rabbitMQ.receive(exchange,delegate(byte[] data)
                rabbitMQ.receive(exchange, queue, "", delegate(byte[] data)
                {
                    IdentifyEncoding identifyEncoding = new IdentifyEncoding();

                    sbyte[] sdata = new sbyte[data.Length];
                    Buffer.BlockCopy(data, 0, sdata, 0, data.Length);
                    string encodeType = identifyEncoding.GetEncodingName(sdata);

                    string chatStr = "";
                    if (encodeType == "GB2312")
                    {
                        chatStr = Encoding.Default.GetString(data);// messageText(ev);                   
                    }
                    else
                    {
                        chatStr = Encoding.UTF8.GetString(data);// messageText(ev);                   

                    }

                    //如果是普通文本
                    if (chatStr.StartsWith("{"))
                    {
                        try
                        {
                            PLog.Info(chatStr);
                            TxtMsg txtMsg = new TxtMsg(chatStr);
                            if (txtMsg.from != Global.CUR_USER.userId)
                            {
                                chatWnd.chatQueue.Enqueue(txtMsg);
                                handler("newmsg", groupId);
                            }
                            //this.appendToTextAreaRecord(txtMsg, 1);
                        }
                        catch (Exception ex)
                        {
                            PLog.Exception(ex);
                        }
                    }//如果是图片
                    else
                    {
                        try
                        {
                            SendImage sImg = SendImage.fromByte(data);
                            chatWnd.imgQueue.Enqueue(sImg);
                        }
                        catch (Exception ex)
                        {
                            PLog.Exception(ex);
                        }
                        handler("newmsg", groupId);
                    }

                   
                });

            }

        }

        /// <summary>
        /// 发送群组聊天内容
        /// </summary>
        /// <param name="txtMsg"></param>
        /// <returns></returns>
        public bool sendGroupChat(TxtMsg txtMsg, Group group)
        {
            Exchange exchange = new Exchange("group.fanout." + group.groupId, Exchange.EXCHANGE_FANOUT, false, true);
            //Pandora.Module.Data.RabbitMQ.Queue queue = new Pandora.Module.Data.RabbitMQ.Queue(txtMsg.from + "-" + txtMsg.to, false, false, true);

            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER, "chat", "xiaop_chat", "sogouorz"))
            {
                //发送新消息
                if (rabbitMQ.send(exchange, Encoding.UTF8.GetBytes(txtMsg.toJson())))
                {


                    Thread broadcastThread = new Thread(new ThreadStart(delegate()
                    {

                        //存储数据库
                        using (RabbitMQHelper rabbitMQDB = new RabbitMQHelper(Global.RABBITMQ_SERVER))
                        {

                            rabbitMQDB.timeOut = 1000;

                            RPCRequest rpcRequest = new RPCRequest();
                            rpcRequest.className = "com.yt.xiaop.service.ChatService";
                            rpcRequest.methodName = "saveChat";
                            rpcRequest.args = new object[] {
                                txtMsg.uuId,
                                txtMsg.from,
                                txtMsg.to,
                                txtMsg.sendTime,
                                txtMsg.toBase64()
                            };
                            string response = rabbitMQDB.sendRequest(rpcRequest.toJson());
                        }

                        //发送新聊天提醒
                        using (RabbitMQHelper rabbitMQ1 = new RabbitMQHelper(Global.RABBITMQ_SERVER, "notice", "pandora", "sogouorz"))
                        {
                            Exchange exchange1 = new Exchange("pandora.direct", Exchange.EXCHANGE_DIRECT);
                            Hashtable chatSignal = new Hashtable();
                            chatSignal.Add("type", "groupchat");
                            chatSignal.Add("time", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                            chatSignal.Add("content", "group-" + group.groupId);
                            int startTime = DateTime.Now.Millisecond;
                            foreach (User user in group.members)
                            {
                                if (user.userId == Global.CUR_USER.userId)
                                    continue;
                                //Console.Write(guItem.userId+"=============\n");
                                XiaoP.Classes.RabbitMQ.Queue signalQueue = new XiaoP.Classes.RabbitMQ.Queue(user.userId, true, false, false);
                                rabbitMQ1.send(exchange1, signalQueue, user.userId, JsonConvert.SerializeObject(chatSignal));

                            }

                            //Console.Write("\nTime Spend :" + (DateTime.Now.Millisecond - startTime) + "\n");
                        }



                    }));

                    broadcastThread.IsBackground = true;
                    broadcastThread.Start();

                    return true;
                }
            }
            return false;

        }


        public static List<string> getLastestChatHistory(string uuid, int limit)
        {
           List<string> chatList = new List<string>();
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER, null, null, null))
            {
                rabbitMQ.timeOut = 10000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.ChatService";
                rpcRequest.methodName = "getLastestChatHistory";
                rpcRequest.args = new object[] { uuid, limit };
                //Console.Write(s.toJson());

                string response = rabbitMQ.sendRequest(rpcRequest.toJson());


                if (response != "")
                {
                    try
                    {
                        Hashtable[] chatTable = JsonConvert.DeserializeObject<Hashtable[]>(response);
                        
                        for (int i = 0; i < chatTable.Length; i++)
                         {

                              Hashtable chat = chatTable[i];
                              TxtMsg txtMsg = new TxtMsg(chat);

                              chatList.Add(txtMsg.toXJson());

                        }
                        return chatList;
                    }
                    catch (Exception ex)
                    {
                        Console.Write(ex.ToString());
                        // return chatList;
                    }

                }
            }
            return chatList;

        }

        /// <summary>
        /// 获取聊天记录列表
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        public static Hashtable[] getChatHistory(string uuId, int curPage)
        {
            Hashtable[] chatTable = null;
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER, null, null, null))
            {
                rabbitMQ.timeOut = 10000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.ChatService";
                rpcRequest.methodName = "getChatHistory";
                rpcRequest.args = new object[] { uuId, curPage };
                //Console.Write(s.toJson());

                string response = rabbitMQ.sendRequest(rpcRequest.toJson());

                if (response != "")
                {
                    try
                    {
                        chatTable = JsonConvert.DeserializeObject<Hashtable[]>(response);
                    }
                    catch (Exception ex)
                    {
                        Console.Write(ex.ToString());
                        // return chatList;
                    }
                }
            }

            return chatTable;

        }

        public bool saveSnap(SendImage sImg)
        {
            string response = "";
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
            {
                rabbitMQ.timeOut = 10000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.ImgService";
                rpcRequest.methodName = "saveData";
                rpcRequest.args = new object[] { sImg.id, ImgHelper.toByteArray(sImg.image, System.Drawing.Imaging.ImageFormat.Bmp) };

                //Console.Write(s.toJson());
                response = Encoding.UTF8.GetString(rabbitMQ.sendRequest(rpcRequest.toByte()));

            }

            Hashtable nt = null;
            try
            {
                nt = JsonConvert.DeserializeObject<Hashtable>(response);

            }
            catch (Exception ex)
            {
                PLog.Exception(ex);
            }

            if (nt != null && nt["succ"].ToString() == "true")
                return true;
            else
            {
                return false;
            }

        }

        public static System.Drawing.Image getImgData(string id)
        {
            System.Drawing.Image img;
            if (!Directory.Exists(Global.CUR_USER.profiles + "images"))
                Directory.CreateDirectory(Global.CUR_USER.profiles + "images");

            if (File.Exists(Global.CUR_USER.profiles + "images\\" + id + ".gif"))
            {

                img = System.Drawing.Image.FromFile(Global.CUR_USER.profiles + "images\\" + id + ".gif");

            }
            else
            {

                byte[] response = null;
                using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
                {
                    rabbitMQ.timeOut = 10000;

                    RPCRequest rpcRequest = new RPCRequest();
                    rpcRequest.className = "com.yt.xiaop.service.ImgService";
                    rpcRequest.methodName = "getData";
                    rpcRequest.args = new object[] { id };

                    //Console.Write(s.toJson());

                    response = rabbitMQ.sendRequest(rpcRequest.toByte());

                }

                if (response != null)
                {

                    FileStream fs = null;
                    try
                    {

                        fs = File.OpenWrite(Global.CUR_USER.profiles + "images\\" + id + ".gif");
                        fs.Write(response, 0, response.Length);
                    }
                    catch (Exception ex)
                    {

                        PLog.Exception(ex);
                    }
                    finally
                    {

                        if (fs != null)
                            fs.Close();
                    }
                }

                img = System.Drawing.Image.FromFile(Global.CUR_USER.profiles + "images\\" + id + ".gif");
            }

            return img;
        }

    }
}
