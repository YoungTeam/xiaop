using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;

namespace XiaoP.Classes.Data
{
    public class Category {

        private string _id;
        public string id
        {
            get { return _id; }
            set { _id = value; }
        }

        private string _name;
        public string name
        {
            get { return _name; }
            set { _name = value; }
        }

        private bool _expand;
        public bool expand
        {
            get { return _expand; }
            set { _expand = value; }
        }

        private List<Group> _groups;

        public List<Group> groups
        {
            get { return _groups; }
            set { _groups = value; }
        }

    }

    public class Group
    {
        private string _uuid;

        public string uuid
        {
            get
            {
                if (this._groupId != null)
                {
                    MD5 md5 = new MD5CryptoServiceProvider();
                    byte[] output = md5.ComputeHash(Encoding.UTF8.GetBytes(this._groupId));

                    return BitConverter.ToString(output).Replace("-", "");
                }
                return _uuid;
            }
            set { _uuid = value; }
        }
	

        private string _groupId;

        public string groupId
        {
            get { return _groupId; }
            set { _groupId = value; }
        }

        private string _groupName;

        public string groupName
        {
            get { return _groupName; }
            set { _groupName = value; }
        }

        private string _groupManager;

        public string groupManager
        {
            get { return _groupManager; }
            set { _groupManager = value; }
        }

        private string _groupBoard;

        public string groupBoard
        {
            get { return _groupBoard; }
            set { _groupBoard = value; }
        }


        private string _groupType;

        public string groupType
        {
            get { return _groupType; }
            set { _groupType = value; }
        }

        private List<User> _members;

        public List<User> members
        {
            get { return _members; }
            set { _members = value; }
        }
    }
}
