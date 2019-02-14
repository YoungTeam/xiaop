using System;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;

namespace XiaoP.Classes.Util
{
    class PLog
    {
        public static void Info(string str) {
            Console.Write(str);
        }

        public static void Exception(Exception e){
            /*
            if (Global.XIAOP_DEBUG)
            {
                CommonHelper.sendMail(

                    Global.CUR_USER.userId + "@yt-inc.com",
                    Global.CUR_USER.userName,
                    "yangting@yt-inc.com",
                    "【小P问题报告】" + DateTime.Now.ToString("yyyy-MM-dd"),
                    e.ToString()

                    );
            }
            else*/
                Console.Write(e.Message);
        }

        public static void Error(string err) { 
        

        
        }
    }
}
