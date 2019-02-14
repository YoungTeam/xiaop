using System;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;
using System.Text;
using XiaoP.Classes.Util;

namespace XiaoP.Classes.Data
{
    class Department
    {
        public Department() { 
        
        }

        public Department(string deptId,string deptName)
        {
            this._deptId = deptId;
            this._deptName = deptName;
            this._users = new List<User>();
        }

        private string _deptId;

        public string deptId
        {
            get { return _deptId; }
            set { _deptId = value; }
        }

        private string _deptName;

        public string deptName
        {
            get { return _deptName; }
            set { _deptName = value; }
        }

        private bool _expand = false;

        public bool expand
        {
            get { return _expand; }
            set { _expand = value; }
        }

        private List<User> _users;

        public List<User> users
        {
            get { return _users; }
            set { _users = value; }
        }

        public string toJSON(){

            string json = "";
            try
            {
                json = JsonConvert.SerializeObject(this);
            }
            catch (Exception ex)
            {
                PLog.Exception(ex);
            }

            return json;
        }

    }
}
