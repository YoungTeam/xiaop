using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace XiaoP.Classes.Util
{
    class FileHelper
    {
        public static byte[] StreamToBytes(Stream stream)
        {
            byte[] bytes = new byte[stream.Length];
            stream.Read(bytes, 0, bytes.Length);
            // 设置当前流的位置为流的开始   
            stream.Seek(0, SeekOrigin.Begin);
            return bytes;
        }

        public static bool isExists(string fileName)
        {
            return File.Exists(fileName);

        }

        public static void delete(string fileName)
        {
            try
            {
                if (isExists(fileName))
                    File.Delete(fileName);

            }
            catch (Exception ex) {

                PLog.Exception(ex);
            }
        }
    }
}
