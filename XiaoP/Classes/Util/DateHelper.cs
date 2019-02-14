using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using XiaoP.Classes;

namespace XiaoP.Classes.Util
{
    class DateHelper
    {
        public static string getServerTime()
        {

            string time = HttpHelper.httpPost(Global.PANDORA_HOME + "api/xiaop/index.jspa?act=time", null, 1000).Trim();
            if (time == null || time == "")
                return DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            return time;
        }

        ///   /// C#日期比较计算两个日期的时间间隔         
        ///   /// 第一个日期和时间  /// 第二个日期和时间  ///   
        public static TimeSpan DateDiff(DateTime DateTime1, DateTime DateTime2)
        {
            //string dateDiff = null;
            TimeSpan ts1 = new TimeSpan(DateTime1.Ticks);
            TimeSpan ts2 = new TimeSpan(DateTime2.Ticks);
            TimeSpan ts = ts1.Subtract(ts2).Duration();
            // dateDiff = ts.Days.ToString() + "天" + ts.Hours.ToString() + "小时" + ts.Minutes.ToString() + "分钟" + ts.Seconds.ToString() + "秒";

            return ts;

        }

        public static DateTime ToDateTime(string dtStr)
        {

            try
            {
                return Convert.ToDateTime(dtStr);
            }
            catch (Exception ex)
            {
                Console.Write(ex.Message);
                return Convert.ToDateTime("1970-01-01 00:00:00");
            }

        }


    }
}
