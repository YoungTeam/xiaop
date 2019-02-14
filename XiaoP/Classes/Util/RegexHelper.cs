using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace XiaoP.Classes.Util
{
    class RegexHelper
    {

        public static bool IsNumber(string strNumber)
        {
            Regex regex = new Regex("[^0-9]");
            return !regex.IsMatch(strNumber);
        }


        public static bool IsIP(string ip)
        {
            if (string.IsNullOrEmpty(ip))
                return false;

            return Regex.IsMatch(ip, @"^((\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.){3}(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$");
        }

    }
}
