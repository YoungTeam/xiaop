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

namespace XiaoP.Classes.Service
{
    class GroupService
    {

        /// <summary>
        /// 获取邮件组列表
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        public static List<Category> getGroupListByUserId(string userId)
        {
            string response = "";
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
            {
                rabbitMQ.timeOut = 10000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.GroupService";
                rpcRequest.methodName = "getGroupListByUserId";
                rpcRequest.args = new object[] { userId };
                response = rabbitMQ.sendRequest(rpcRequest.toJson());

            }

            Hashtable nt = JsonConvert.DeserializeObject<Hashtable>(response);
            List<Category> cateList = new List<Category>();
            foreach (DictionaryEntry groupEntry in nt)
            {

                string groupType = groupEntry.Key.ToString();
                Category cate = new Category();
                cate.id = groupType;
                
                if (groupType == "mail")
                {
                    cate.name = "邮件组";
                }
                else
                {
                   cate.name = "部门组";
                   cate.expand = true;

                }

                Hashtable[] groupsArray = JsonConvert.DeserializeObject<Hashtable[]>(groupEntry.Value.ToString());
                cate.groups = new List<Group>();
                foreach (Hashtable groupHash in groupsArray)
                {
                    if (groupHash == null)
                        continue;

                    Group group;
                    if (groupType == "mail")
                    {
                        string mailGroup = groupHash["mail_group_id"].ToString().ToLower();
                        if (mailGroup == "happy" || mailGroup == "all")
                            continue;

                        group = new Group();
                        group.groupId = groupHash["mail_group_id"].ToString();
                        group.groupName = groupHash["mail_group_id"].ToString();
                        group.groupType = groupType;

                        if (groupHash["manager"] != null)
                            group.groupManager = groupHash["manager"].ToString();
                    }
                    else
                    {
                        if (groupHash["groupName"].ToString() == "搜狗")
                            continue;

                        group = new Group();
                        group.groupId = groupHash["groupId"].ToString();
                        group.groupName = groupHash["groupName"].ToString();
                        group.groupType = groupType;
                       
                        if (groupHash["groupManager"] != null)
                             group.groupManager = groupHash["groupManager"].ToString();
                    }

                    cate.groups.Add(group);
                }
                cateList.Add(cate);
            }

            return cateList;
        }

        public static Group getGroupInfo(string groupId)
        {

            string response = "";
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
            {
                rabbitMQ.timeOut = 3000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.GroupService";
                rpcRequest.methodName = "getGroupInfoById";
                rpcRequest.args = new object[] { groupId };
                //Console.Write(s.toJson());

                response = rabbitMQ.sendRequest(rpcRequest.toJson());
            }

            Group group = null;
            if (response != "")
            {
                group = new XiaoP.Classes.Data.Group();
                Hashtable groupTable = JsonConvert.DeserializeObject<Hashtable>(response);
                //group = new Group(userTable);

                if (System.Text.RegularExpressions.Regex.IsMatch(groupId, @"^D[0-9]{4}$"))
                {
                    group.groupId = groupTable["deptId"].ToString();
                    group.groupName = groupTable["deptName"].ToString();

                    if (groupTable["deptManageUserNo"] != null)
                        group.groupManager = groupTable["deptManageUserNo"].ToString();
                    group.groupType = "dept";
                }
                else
                {
                    group.groupId = groupTable["mailGroupId"].ToString();
                    group.groupName = groupTable["mailGroupId"].ToString();
                    if (groupTable["mailManager"] != null)
                        group.groupManager = groupTable["mailManager"].ToString();
                    group.groupType = "mail";
                }

            }

            if (group != null)
            {
                using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
                {
                    rabbitMQ.timeOut = 3000;

                    RPCRequest rpcRequest = new RPCRequest();
                    rpcRequest.className = "com.yt.xiaop.service.GroupService";
                    rpcRequest.methodName = "getGroupBoardById";
                    rpcRequest.args = new object[] { group.uuid };
                    //Console.Write(s.toJson());

                    response = rabbitMQ.sendRequest(rpcRequest.toJson());

                    if (response != null && response != "")
                    {
                        Hashtable groupTable = JsonConvert.DeserializeObject<Hashtable>(response);
                        if (groupTable["board"] != null)
                            group.groupBoard = groupTable["board"].ToString();

                    }
                }
            }

            return group;

        }


        public static List<User> getDeptGroupMembers(string groupId)
        {
            string response = "";
            
            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
            {
                rabbitMQ.timeOut = 10000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.GroupService";
                rpcRequest.methodName = "getDeptGroupMembersByGroupId";
                rpcRequest.args = new object[] { groupId };

                response = rabbitMQ.sendRequest(rpcRequest.toJson());
            }

            List<User> userList = new List<User>();
            Hashtable[] nt = null;
            if (response != null)
            {
                try
                {
                    nt = JsonConvert.DeserializeObject<Hashtable[]>(response);
                }
                catch (Exception ex)
                {
                    PLog.Exception(ex);
                }
            }
            if (nt != null)
            {
                foreach (Hashtable userTable in nt)
                {
                    if (userTable == null)
                        continue;
                    User user = new User(userTable,false);
                    if (user != null)
                        userList.Add(user);
                }
            }

            return userList;
        }


         /// <summary>
        /// 获取邮件组成员列表
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        public static List<User> getMailGroupMembers(string groupId)
        {
            string response = "";// CacheService.read("Group", groupId, "");

            using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
            {
                rabbitMQ.timeOut = 10000;

                RPCRequest rpcRequest = new RPCRequest();
                rpcRequest.className = "com.yt.xiaop.service.GroupService";
                rpcRequest.methodName = "getMailGroupMembersByGroupId";
                rpcRequest.args = new object[] { groupId };

                response = rabbitMQ.sendRequest(rpcRequest.toJson());
            }

            List<User> userList = new List<User>();
            Hashtable[] nt = null;
            if (response != null)
            {
                try
                {
                    nt = JsonConvert.DeserializeObject<Hashtable[]>(response);
                }
                catch (Exception ex)
                {
                    PLog.Exception(ex);
                }
            }
            if (nt != null)
            {
                foreach (Hashtable userTable in nt)
                {
                    if (userTable == null)
                        continue;
                    User user = new User(userTable, false);
                    if (user != null)
                        userList.Add(user);
                }
            }

            return userList;
              
        }

    }
}
