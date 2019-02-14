using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using System.Collections;
using XiaoP.Classes.Util;
using XiaoP.Classes.Service;

namespace XiaoP.Classes.Data
{
    public class User
    {
        public static int USER_STATUS_ONLINE = 1;//在线
        public static int USER_STATUS_OFFLINE = 0;//离线


        public static int USER_TYPE_USUAL = 1;//通用联系人
        public static int USER_TYPE_RECENT = 2;//最近联系人


        public User(Hashtable userTable,bool database)
        {
            this._userId = userTable["userId"].ToString();
            this._userNo = userTable["userNo"].ToString();
            this._userName = userTable["userName"].ToString();
            if (userTable["userNamePinyin"] != null)
                this._userNamePinyin = userTable["userNamePinyin"].ToString();
            if (userTable["sex"] != null)
                this._sex = userTable["sex"].ToString();
            if (userTable["birthday"] != null)
                this._birthday = userTable["birthday"].ToString();
            if (userTable["masterUserId"] != null)
                this._masterUserId = userTable["masterUserId"].ToString();
            if (userTable["introduction"] != null)
                this._introduction = userTable["introduction"].ToString();
            if (userTable["telExt"] != null)
                this._telExt = userTable["telExt"].ToString();

            if (userTable["deptFullpathIds"] != null)
            {
                string[] ids = userTable["deptFullpathIds"].ToString().Split(',');
                if (ids.Length < 2)
                    this._deptId = 2 + "";
                else if (ids.Length <= 3)
                    this._deptId = ids[1];
                else if (ids.Length >= 4)
                    this._deptId = ids[2];

                if (ids.Length >= 5)
                {
                    this._miniDeptId = ids[3];
                }
            }

            if (userTable["deptFullpathNames"] != null)
            {
                string[] names = userTable["deptFullpathNames"].ToString().Split(',');
                if (names.Length < 2)
                    this._deptName = "搜狗公司";
                else if (names.Length <= 3)
                    this._deptName = names[1];
                else if (names.Length >= 4)
                    this._deptName = names[2];

                if (names.Length >= 5)
                {
                    this._miniDeptName = names[3];
                }
            }

            if (userTable["telMobile"] != null && userTable["telMobile"].ToString().ToLower() != "null" && userTable["telMobile"].ToString() != "")
            {

                this._mobile = userTable["telMobile"].ToString();
            }

            if (userTable["xiaopStatus"] != null)
                this._userStatus = System.Int32.Parse(userTable["xiaopStatus"].ToString());



            if (userTable["xiaopLoginTime"] != null)
            {
             //   this._loginTime = DateHelper.ToDateTime(userTable["xiaop_login_time"].ToString());
            }

            if (userTable["xiaopLoginIp"] != null)
            {
                this._loginIP = userTable["xiaopLoginIp"].ToString();
            }



            if (userTable["xiaopPoint"] != null)
            {
                int point = System.Int32.Parse(userTable["xiaopPoint"].ToString());

                double delta = 16 + point / 5;

                this.level = (int)(-2 + Math.Sqrt(delta) / 2);
            }

            if (userTable["xiaopShowMobile"] != null)
            {

                this._showMobile = System.Int32.Parse(userTable["xiaopShowMobile"].ToString());

            }

            /*
            if (userTable["last_login_time"] != null)
            {
                this._lastLoginTime = userTable["last_login_time"].ToString();
            }*/

            if (userTable["userType"] != null)
            {
                //this._userType = System.Int32.Parse(userTable["userType"].ToString());

            }

            if (userTable["xiaopVersion"] != null)
            {
                this._version = userTable["xiaopVersion"].ToString();
            }
        }

        public User(Hashtable userTable)
        {

            //string friendId = "", userNo = "", userName = "", telExt = "", fullpathNames = "";
            if (userTable["user_id"] != null)
                this._userId = userTable["user_id"].ToString();

            if (userTable["user_no"] != null)
                this._userNo = userTable["user_no"].ToString();

            if (userTable["user_name"] != null)
                this._userName = userTable["user_name"].ToString();

            if (userTable["user_name_pinyin"] != null)
                this._userNamePinyin = userTable["user_name_pinyin"].ToString();

            if (userTable["sex"] != null)
                this._sex = userTable["sex"].ToString();

            if (userTable["birthday"] != null)
                this._birthday = userTable["birthday"].ToString();

            if (userTable["master_user_id"] != null)
                this._masterUserId = userTable["master_user_id"].ToString();

            if (userTable["introduction"] != null)
                this._introduction = userTable["introduction"].ToString();

            if (userTable["tel_ext"] != null && userTable["tel_ext"].ToString().ToLower() != "null")
                this._telExt = userTable["tel_ext"].ToString();

            if (userTable["fullpath_ids"] != null)
            {
                string[] ids = userTable["fullpath_ids"].ToString().Split(',');
                if (ids.Length < 2)
                    this._deptId = 2 + "";
                else if (ids.Length <= 3)
                    this._deptId = ids[1];
                else if (ids.Length >= 4)
                    this._deptId = ids[2];

                if (ids.Length >= 5)
                {
                    this._miniDeptId = ids[3];
                }
            }

            if (userTable["fullpath_names"] != null)
            {
                string[] names = userTable["fullpath_names"].ToString().Split(',');
                if (names.Length < 2)
                    this._deptName = "搜狗公司";
                else if (names.Length <= 3)
                    this._deptName = names[1];
                else if (names.Length >= 4)
                    this._deptName = names[2];

                if (names.Length >= 5)
                {
                    this._miniDeptName = names[3];
                }
            }

            if (userTable["tel_mobile"] != null && userTable["tel_mobile"].ToString().ToLower() != "null" && userTable["tel_mobile"].ToString() != "")
            {

                this._mobile = userTable["tel_mobile"].ToString();
            }

            if (userTable["xiaop_status"] != null)
                this._userStatus = System.Int32.Parse(userTable["xiaop_status"].ToString());



            if (userTable["xiaop_login_time"] != null)
            {
                this._loginTime = DateHelper.ToDateTime(userTable["xiaop_login_time"].ToString());
            }

            if (userTable["xiaop_login_ip"] != null)
            {
                this._loginIP = userTable["xiaop_login_ip"].ToString();
            }



            if (userTable["xiaop_point"] != null)
            {
                int point = System.Int32.Parse(userTable["xiaop_point"].ToString());

                double delta = 16 + point / 5;

                this.level = (int)(-2 + Math.Sqrt(delta) / 2);
            }

            if (userTable["xiaop_show_mobile"] != null)
            {

                this._showMobile = System.Int32.Parse(userTable["xiaop_show_mobile"].ToString());

            }

            if (userTable["last_login_time"] != null)
            {
                this._lastLoginTime = userTable["last_login_time"].ToString();
            }

            if (userTable["user_type"] != null)
            {

                this._userType = System.Int32.Parse(userTable["user_type"].ToString());

            }

            if (userTable["logo_photo_flag"] != null)
            {
                this._logoPhotoFlag = System.Int32.Parse(userTable["logo_photo_flag"].ToString());
            
            }

            if (userTable["xiaop_version"] != null)
            {
                this._version = userTable["xiaop_version"].ToString();
            }

        }


        private string _userId;

        public string userId
        {
            get { return _userId; }
            set { _userId = value; }
        }

        private string _userName;

        public string userName
        {
            get { return _userName; }
            set { _userName = value; }
        }

        private string _userNamePinyin;

        public string userNamePinyin
        {
            get { return _userNamePinyin; }
            set { _userNamePinyin = value; }
        }

        private string _userNo;

        public string userNo
        {
            get { return _userNo; }
            set { _userNo = value; }
        }


        private string _sex;

        public string sex
        {
            get { return _sex; }
            set { _sex = value; }
        }


        private string _birthday;

        public string birthday
        {
            get { return _birthday; }
            set { _birthday = value; }
        }


        private string _masterUserId;

        public string masterUserId
        {
            get { return _masterUserId; }
            set { _masterUserId = value; }
        }

        private string _introduction = "";

        public string introduction
        {
            get { return _introduction; }
            set { _introduction = value; }
        }

        private string _lastLoginTime;

        public string lastLoginTime
        {
            get { return _lastLoginTime; }
            set { _lastLoginTime = value; }
        }


        private DateTime _loginTime;

        public DateTime loginTime
        {
            get { return _loginTime; }
            set { _loginTime = value; }
        }

        private int _userStatus;

        public int userStatus
        {
            get { return _userStatus; }
            set { _userStatus = value; }
        }

        private string _telExt = "";

        public string telExt
        {
            get { return _telExt; }
            set { _telExt = value; }
        }


        private string _deptId = "";

        public string deptId
        {
            get { return _deptId; }
            set { _deptId = value; }
        }


        private string _deptName = "";

        public string deptName
        {
            get { return _deptName; }
            set { _deptName = value; }
        }

        private string _miniDeptId = "";

        public string miniDeptId
        {
            get { return _miniDeptId; }
            set { _miniDeptId = value; }
        }

        private string _miniDeptName = "";

        public string miniDeptName
        {
            get { return _miniDeptName; }
            set { _miniDeptName = value; }
        }

        private DateTime _attenceTime;

        public DateTime attenceTime
        {
            get { return _attenceTime; }
            set { _attenceTime = value; }
        }

        private string _mobile;

        public string mobile
        {
            get { return _mobile; }
            set { _mobile = value; }
        }

        private int _userType = USER_TYPE_RECENT;

        public int userType
        {
            get { return _userType; }
            set { _userType = value; }
        }


        //用户关系ID
        private string _uuId;

        public string uuId
        {
            get { return _uuId; }
            set { _uuId = value; }
        }


        private string _loginIP;

        public string loginIP
        {
            get { return _loginIP; }
            set { _loginIP = value; }
        }

        private string _version;
        public string version
        {
            get
            {
                return _version;
            }
            set
            {
                _version = value;
            }
        }

        private int _level = 0;
        public int level
        {
            set
            {
                _level = value;
            }
            get
            {
                return this._level;
            }
        }

        private int _logoPhotoFlag = 0;
        public int logoPhotoFlag
        {
            set
            {
                _logoPhotoFlag = value;
            }
            get
            {
                return this._logoPhotoFlag;
            }
        }


        private int _showMobile;
        public int showMobile
        {
            get
            {
                return _showMobile;
            }
            set
            {
                _showMobile = value;
            }
        }

        public int userWeight {
            get
            {
                int thisWeight = 0;
                if(this._userNamePinyin == null || this._userNamePinyin.Length == 0)
                    thisWeight = StringHelper.AscII(this._userId);
                else
                    thisWeight = StringHelper.AscII(this._userNamePinyin);

                if (this._userStatus != 0)
                    thisWeight += 100;

                return thisWeight;
            }
        }

        public bool isInContact
        {
            get
            {
                if (Global.CUR_USER != null && this._userId == Global.CUR_USER.userId)
                    return true;
                return StaffService.isInContact(this._userId);
            }
        }

        private bool _isManager = false;
        public bool isManager
        {
            get
            {
                return _isManager;
            }
            set
            {
                _isManager = value;
            }
        }

        public string profiles
        {
            get { return Global.PANDORA_PFOFILE + "\\user\\" + this._userId + "\\"; }
            //set { _profiles = value; }
        }


    }
}
