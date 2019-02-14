using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;
using System.IO;
using Newtonsoft.Json;
using XiaoP.Classes.RabbitMQ;
using XiaoP.Classes.Data;
using XiaoP.Classes.Util;
using System.Drawing;

namespace XiaoP.Classes.Service
{
    class UserService
    {

        public static Image getFace(string userId, int width, int height) {
            Image img = getFace(userId);
            img = ImgHelper.geometricScaling(img, width, height);
            return img;
        }

        //private static Image DEFAULT_IMG = global::XiaoP.Properties.Resources.default_img;

        public static IntPtr getFaceHandle(string userId) {
            if (userId == null)
                return IntPtr.Zero;

            string userLogoDir = Global.PANDORA_PFOFILE + "system\\userLogo\\";//System.Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + "\\Pandora\\userLogo\\";

            if (!Directory.Exists(userLogoDir))
            {
                Directory.CreateDirectory(userLogoDir);
            }

            string userLogoFile = userLogoDir + userId + ".jpg";
            try
            {
                if (FileHelper.isExists(userLogoFile))
                {
                    return ImgHelper.getImgHandleFromFile(userLogoFile);
                }
                else {
                    string url = Global.PANDORA_HOME + "/api/user/userHeader.jspa?f=xiaop&userId=" + userId;
                    return ImgHelper.getImgHandle(url);           
                }
                
            }
            catch (Exception ex) { 
            
            }

            return IntPtr.Zero;
        }

        public static Image getFace(string userId)
        {
            if (userId == null)
                return null;

            Image img = null;

            string userLogoDir = Global.PANDORA_PFOFILE + "system\\userLogo\\";//System.Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + "\\Pandora\\userLogo\\";

            if (!Directory.Exists(userLogoDir))
            {
                Directory.CreateDirectory(userLogoDir);
            }

            string userLogoFile = userLogoDir + userId + ".jpg";

            Image imgTmp = null;
            try
            {

                if (FileHelper.isExists(userLogoFile))
                {

                    imgTmp = Image.FromFile(userLogoFile);
                    if (imgTmp != null)
                        img = (Image)imgTmp.Clone();
                }
                else
                {

                    //string url = "http://pub.oa.yt-inc.com/moa/sylla/mapi/img?id=yangting&s=1&w=100&h=100";
                    //string url = "http://oa.yt-inc.com/moa/sylla/mapi/img?id=jiajiping&s=1&w=200&h=200";
                    string url = Global.PANDORA_HOME+"/api/user/userHeader.jspa?f=xiaop&userId=" +userId;
                    imgTmp = ImgHelper.getImage(url,1000);

                    if (imgTmp != null)
                    {
                        imgTmp = ImgHelper.geometricScaling(imgTmp, 80, 80);
                        imgTmp.Save(userLogoFile);
                        img = (Image)imgTmp.Clone();
                    }
                }
            }
            catch (Exception ex)
            {
                if (img != null)
                {
                    img.Dispose();
                    img = null;
                    FileHelper.delete(userLogoFile);
                }
                PLog.Exception(ex);
            }
            finally
            {
                if (imgTmp != null)
                    imgTmp.Dispose();
            }

            if (img == null)
                img = global::XiaoP.Properties.Resources.default_img;

            return img;


        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="userName"></param>
        /// <returns></returns>
        public static User loginUser(string userId)
        {

            string ip = SystemHelper.GetLocalIp();
            AssemblyInfo assemblyInfo = new AssemblyInfo();
            string version = assemblyInfo.Version;

            string response = "";
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
            {
                rabbitMQ.timeOut = 3000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.UserService";
                rpcRequest.methodName = "loginUser";
                rpcRequest.args = new object[] { userId, ip, version };

                response = rabbitMQ.sendRequest(rpcRequest.toJson());
            }

            //Console.Write(ip+"==========" + userId);
            if (response != "")
            {
                //Console.Write("=========="+response);
                Hashtable userTable = JsonConvert.DeserializeObject<Hashtable>(response);

                User user = new User(userTable);
                user.loginIP = ip;

                return user;
            }

            return null;

        }

        public static void logoutUser(string userId)
        {
            string ip = SystemHelper.GetLocalIp();
            AssemblyInfo assemblyInfo = new AssemblyInfo();
            string version = assemblyInfo.Version;

            string response = "";
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
            {

                rabbitMQ.timeOut = 3000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.UserService";
                rpcRequest.methodName = "logoutUser";
                rpcRequest.args = new object[] { userId, ip, version };

                response = rabbitMQ.sendRequest(rpcRequest.toJson());
            }
        }

        /// <summary>
        /// 根据用户ID获取用户信息
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        public static User getInfoById(string userId)
        {
            string response = "";
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
            {
                rabbitMQ.timeOut = 3000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.UserService";
                rpcRequest.methodName = "getUserInfoFromUserId";
                rpcRequest.args = new object[] { userId };
                //Console.Write(s.toJson());

                response = rabbitMQ.sendRequest(rpcRequest.toJson());
            }

            if (response != "")
            {
                Hashtable userTable = JsonConvert.DeserializeObject<Hashtable>(response);
                User user = new User(userTable);
                if (user.userId != null)
                    return user;
            }

            return null;

        }

        /// <summary>
        /// 根据查询词获取用户列表
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        public static List<User> getUserListByQuery(string query)
        {
            int start = Environment.TickCount;
            string response = "";
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
            {
                rabbitMQ.timeOut = 3000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.UserService";
                rpcRequest.methodName = "getUserListByQuey";
                rpcRequest.args = new object[] { query };
               
                response = rabbitMQ.sendRequest(rpcRequest.toJson());
            }


            List<User> userList = new List<User>();
            if (response != "")
            { 
                Hashtable[] userTable = null;
                try
                {
                    userTable = JsonConvert.DeserializeObject<Hashtable[]>(response);
                }
                catch (Exception ex)
                {
                    Console.Write(ex.ToString());
                }

                if (userTable != null) {
                    foreach (Hashtable user in userTable)
                    {
                        userList.Add(new User(user));
                    }
                }
            }

            Console.Write(query + "====:" + (Environment.TickCount - start)+"\n");
            return userList;

        }

        public static void setUserShowMobile(string userId, int show)
        {
            string response = "";
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
            {

                rabbitMQ.timeOut = 3000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.UserService";
                rpcRequest.methodName = "setUserShowMobile";
                rpcRequest.args = new object[] { userId, show };

                response = rabbitMQ.sendRequest(rpcRequest.toJson());
            }
        }

  

    }
}
