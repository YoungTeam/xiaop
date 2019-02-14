using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;
using Newtonsoft.Json;
using XiaoP.Classes.Data;
using XiaoP.Classes.RabbitMQ;
using XiaoP.Classes.Util;

namespace XiaoP.Classes.Service
{
    class StaffService
    {

        private static Hashtable contactTable = new Hashtable();

        public static bool isInContact(string userId) {

            if (contactTable.ContainsKey(userId))
                return true;
            return false;
        }

        public static bool addContact(string userId, string staffId)
        {
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
            {
                rabbitMQ.timeOut = 10000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.FriendService";
                rpcRequest.methodName = "addUserToFriend";
                rpcRequest.args = new object[] { userId, staffId };
                //Console.Write(s.toJson());

                string response = rabbitMQ.sendRequest(rpcRequest.toJson());

                Hashtable nt = JsonConvert.DeserializeObject<Hashtable>(response);
                if (nt["succ"].ToString() == "true")
                {
                    if (!contactTable.Contains(staffId))
                        contactTable.Add(staffId, 0);
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        public static bool removeContact(string userId, string staffId)
        {
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
            {
                rabbitMQ.timeOut = 10000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.FriendService";
                rpcRequest.methodName = "delUserFromFriend";
                rpcRequest.args = new object[] { userId, staffId };
                //Console.Write(s.toJson());

                string response = rabbitMQ.sendRequest(rpcRequest.toJson());

                Hashtable nt = JsonConvert.DeserializeObject<Hashtable>(response);
                if (nt["succ"].ToString() == "true")
                {
                    if (contactTable.Contains(staffId))
                        contactTable.Remove(staffId);
                    return true;
                }
                else
                {
                    return false;
                }

            }
        }

        public static List<Department> getDept(string userId)
        {
           

            string response = "";
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
            {
                rabbitMQ.timeOut = 10000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.FriendService";
                rpcRequest.methodName = "getUsualFriendListByUserId";
                rpcRequest.args = new object[] { userId };
                response = rabbitMQ.sendRequest(rpcRequest.toJson());
            }

            Hashtable nt = JsonConvert.DeserializeObject<Hashtable>(response);

            List<Department> deptUserslist = new List<Department>();
            if (nt != null)
            {
                int i = 0;
                foreach (DictionaryEntry groupEntry in nt)
                {

                    string[] orgInfo = groupEntry.Key.ToString().Split('|');
                    if (orgInfo.Length < 2)
                        continue;
                    Department dept = new Department(orgInfo[0],orgInfo[1]);

                    if (i == 0)
                      dept.expand = true;
                 
                     Hashtable[] staffHash = JsonConvert.DeserializeObject<Hashtable[]>(groupEntry.Value.ToString());



                     foreach (Hashtable userHash in staffHash)
                     {
                         if (userHash == null)
                             continue;

                         User user = new User(userHash);
                         dept.users.Add(user);
                         if(!contactTable.ContainsKey(user.userId)) 
                            contactTable.Add(user.userId, 0);
                     }

                     deptUserslist.Add(dept);
                  
                }

            }

            return deptUserslist;
        }

        public static List<User> getRecent(string userId){
            string response = "";
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
            {
                rabbitMQ.timeOut = 10000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.FriendService";
                rpcRequest.methodName = "getRecenFriendListByUserId";
                rpcRequest.args = new object[] { userId };
                response = rabbitMQ.sendRequest(rpcRequest.toJson());
            }

            Hashtable[] nt = JsonConvert.DeserializeObject<Hashtable[]>(response);
            List<User> staffList = new List<User>();
            if (nt != null)
            {
                foreach (Hashtable userTable in nt)
                {
                    if (userTable == null)
                        continue;

                    User staff = new User(userTable);

                    staffList.Add(staff);
                   
                }
            }

            return staffList;

        }
    }
}
