using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using Newtonsoft.Json;
using System.Drawing;
using System.Net;
using System.Collections;
using XiaoP.Classes.RabbitMQ;
using XiaoP.Classes.Util;
using XiaoP.UI.Core.Bolt;
using XiaoP.UI.Core.Bolt.NET;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Threading;
 
namespace XiaoP.LuaClasses
{
    internal sealed class StaffClass
    {
        public event Action<string> OnResultFinish;
        public event Action<IntPtr> OnImgFinish;

        public void getInfo(string userId) {
            Thread thread = new Thread(new ThreadStart(
                            () =>
                            {
                                string response = "";
                                using (RabbitMQHelper rabbitMQ = new RabbitMQHelper("10.14.7.166"))
                                {
                                    rabbitMQ.timeOut = 10000;

                                    RPCRequest rpcRequest = new RPCRequest();
                                    rpcRequest.className = "com.yt.xiaop.service.UserService";
                                    rpcRequest.methodName = "getUserInfoFromUserId";
                                    rpcRequest.args = new object[] { userId };
                                    response = rabbitMQ.sendRequest(rpcRequest.toJson());

                                }

                                XLBolt.Instance().Invoke(delegate()
                                {
                                    if (OnResultFinish != null)
                                    {
                                        OnResultFinish(response);
                                    }
                                });

                            }
                        ));
            thread.IsBackground = true;
            thread.Start();

        }

        public string getRecent(string userId){

            Thread thread = new Thread(new ThreadStart(
                ()=>{
                    string response = "";
                    using (RabbitMQHelper rabbitMQ = new RabbitMQHelper("10.14.7.166"))
                    {
                        rabbitMQ.timeOut = 10000;

                        RPCRequest rpcRequest = new RPCRequest();
                        rpcRequest.className = "com.yt.xiaop.service.FriendService";
                        rpcRequest.methodName = "getRecenFriendListByUserId";
                        rpcRequest.args = new object[] { userId };
                        response = rabbitMQ.sendRequest(rpcRequest.toJson());

                    }


                    XLBolt.Instance().Invoke(delegate()
                    {
                        if (OnResultFinish != null)
                        {
                            OnResultFinish(response);
                        }
                    });

              }
            ));
            thread.IsBackground = true;
            thread.Start();

            return "";
        }

       
    }
}
