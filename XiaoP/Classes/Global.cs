using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using XiaoP.Classes.Data;
using System.Windows.Forms;

namespace XiaoP.Classes
{
    class Global
    {
        public static bool Debug = false;

        public static string XIAOP_SERVER = "127.0.0.1";
        public static string RABBITMQ_SERVER = "127.0.0.1";;
        
        public static string PANDORA_HOME = "http://xiaop.com/";
        public static User CUR_USER = null;

        public static string SEND_MODE = "Enter";
        public static string PANDORA_PFOFILE = Application.StartupPath + "\\profiles\\";
        //public static Hashtable IMG_CACHE_UPDATE = new Hashtable();

        public static List<System.Drawing.Image> EMOTION_LIST = new List<System.Drawing.Image>();
        public static TxtMsg CUR_FONT = new TxtMsg();
    }
}