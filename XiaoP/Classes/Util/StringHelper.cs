using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace XiaoP.Classes.Util
{
    class StringHelper
    {

        public static int AscII(string character)
        {
            if (character.Length >= 1)
            {
                System.Text.ASCIIEncoding asciiEncoding = new System.Text.ASCIIEncoding();
                int intAsciiCode = (int)asciiEncoding.GetBytes(character)[0];
                return (intAsciiCode);
            }
            else
            {
                throw new Exception("Character is not valid.");
            }

        }

        public static string GetDecodingString(byte[] data){
        
            IdentifyEncoding identifyEncoding = new IdentifyEncoding();

            sbyte[] sdata = new sbyte[data.Length];
            Buffer.BlockCopy(data, 0, sdata, 0, data.Length);
            string encodeType = identifyEncoding.GetEncodingName(sdata);

            string returnStr = "";
            if (encodeType == "GB2312")
            {
                returnStr = Encoding.Default.GetString(data);              
            }
            else
            {
                returnStr = Encoding.UTF8.GetString(data);              
            }

            return returnStr;
        }

    }
}
