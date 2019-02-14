using System;
using System.Collections.Generic;
using System.Linq;
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
    class NovaService
    {
        /// <summary>
        /// 获取待办事项列表
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        public static int getNovaToDo(string userId)
        {
            string response = "";
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER, null, null, null))
            {
                rabbitMQ.timeOut = 10000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.TaskService";
                rpcRequest.methodName = "getTaskTodoListFromUserId";
                rpcRequest.args = new object[] { userId };
                //Console.Write(s.toJson());

                response = rabbitMQ.sendRequest(rpcRequest.toJson());
            }

            
            if (response != "")
            {
                Hashtable[] taskTable = new Hashtable[]{};
                try
                {
                    taskTable = JsonConvert.DeserializeObject<Hashtable[]>(response);
                }
                catch (Exception ex)
                {
                    Console.Write(ex.ToString());
                }

                return taskTable.Length;
            }

            return 0;

        }



          /// <summary>
        /// 获取个人申请列表
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        public static int getNovaMine(string userId)
        {
            string response = "";
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
            {

                rabbitMQ.timeOut = 10000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.TaskService";
                rpcRequest.methodName = "getApplyTodoListFromUserId";
                rpcRequest.args = new object[] { userId };
                //Console.Write(s.toJson());

                response = rabbitMQ.sendRequest(rpcRequest.toJson());
            }

            if (response != "")
            {
                Hashtable[] taskTable = new Hashtable[] { };
                try
                {
                    taskTable = JsonConvert.DeserializeObject<Hashtable[]>(response);
                }
                catch (Exception ex)
                {
                    Console.Write(ex.ToString());
                }

                return taskTable.Length;
            }

            return 0;
        }

    }
}
