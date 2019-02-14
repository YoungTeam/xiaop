using System;
using System.Collections.Generic;
using System.Text;
using Newtonsoft.Json;
using System.IO;

namespace XiaoP.Classes.RabbitMQ
{
    [Serializable]
    class RPCRequest
    {
        private string _className;

        public string className
        {
            get { return _className; }
            set { _className = value; }
        }


        private string _methodName;

        public string methodName
        {
            get { return _methodName; }
            set { _methodName = value; }
        }

        private object[] _args;

        public object[] args
        {
            get { return _args; }
            set { _args = value; }
        }

        public string toJson()
        {
            return JsonConvert.SerializeObject(this);
        }

        /// <summary>
        /// 自定义序列化格式
        /// head //必须为"xiaop"
        /// cb    // 本数据结构的大小，不包括最初的8个字节（fcc和cb两个域）
        /// cn //类名
        /// mn //方法名
        /// ac //参数个数
        /// //参数内容
        /// args1
        ///     type
        ///     size
        ///     data
        /// args2
        ///     type
        ///     size
        ///     data
        /// </summary>
        /// <returns></returns>
        public byte[] toByte()
        {
            //文件头
            byte[] head = Encoding.UTF8.GetBytes("xiaop");
            //类名
            byte[] cn = new byte[50];//Encoding.UTF8.GetBytes("com.yt.pandora.service.ImgService");
            //方法名
            byte[] mn = new byte[30];//Encoding.UTF8.GetBytes("saveData");
            //参数数量
            byte[] ac = System.BitConverter.GetBytes(this._args.Length); //2; 

            Buffer.BlockCopy(Encoding.UTF8.GetBytes(this.className), 0, cn, 0, this.className.Length);
            Buffer.BlockCopy(Encoding.UTF8.GetBytes(this.methodName), 0, mn, 0, this.methodName.Length);

            int size = 0;

            Stream s = new MemoryStream();
            s.Write(head, 0, 5);
            s.Write(cn, 0, cn.Length);
            s.Write(mn, 0, mn.Length);
            s.Write(ac, 0, ac.Length);

            size += 5 + cn.Length + mn.Length + ac.Length;
            
            foreach(object arg in this._args)
            {
                byte[] dataBuffer = null;
                byte[] dataType = new byte[4];

             

                if (arg is int) {
                    Buffer.BlockCopy(Encoding.UTF8.GetBytes("int"), 0, dataType, 0, "int".Length);
                    //typeStr = "int";
                    dataBuffer = System.BitConverter.GetBytes((int)arg);
                }
                else if (arg is byte[])
                {
                    Buffer.BlockCopy(Encoding.UTF8.GetBytes("img"), 0, dataType, 0, "img".Length);
                    dataBuffer = (byte[])arg;
                }
                else {
                    Buffer.BlockCopy(Encoding.UTF8.GetBytes("str"), 0, dataType, 0, "str".Length);
                    dataBuffer = Encoding.UTF8.GetBytes((string)arg);
                }

                byte[] dataSize = System.BitConverter.GetBytes(dataBuffer.Length);
                
                //参数大小
                s.Write(dataSize, 0, dataSize.Length);
                //参数类型
                s.Write(dataType, 0, dataType.Length);
                //参数值
                s.Write(dataBuffer, 0, dataBuffer.Length);

                size += dataSize.Length + dataType.Length + dataBuffer.Length;
                
            }

            s.Position = 0;

            byte[] full = new byte[size];
            int r = s.Read(full, 0, full.Length);
            if (r > 0)
            {
                s.Close();
                /*
                FileStream fs2 = new FileStream(@"D:\love.wma", FileMode.Create);
                fs2.Write(full, 0, full.Length);
                fs2.Flush();*/

                /*
                Console.WriteLine(Encoding.Default.GetString(full));   
                Console.WriteLine(full.Length);   
                Console.WriteLine(full[0].ToString());   
                Console.WriteLine(full[1].ToString());   
                Console.WriteLine(full[9].ToString());   
                Console.Read();
                 */
            }

            return full;
        }
    }
}
