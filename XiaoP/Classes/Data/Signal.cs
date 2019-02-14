using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO; 
using XiaoP.Classes.Util;

namespace XiaoP.Classes.Data
{
    /// <summary>
    /// 消息信号
    /// </summary>
    [Serializable]
    public class Signal
    {

        public SendUser from = null;

        public string type = "image";//发送的消息类别(0表示GIF图片)

        public DateTime time = DateTime.Now;//发送消息的时间

        public byte[] content = null;//发送消息二进制序列化后生成的字节数组数据


        public Signal(string type, DateTime time, byte[] content)
        {

            this.type = type;
            this.time = time;
            this.content = content;
        }

        public Signal(SendUser from, string type, DateTime time, byte[] content)
        {
            this.from = from;
            this.type = type;
            this.time = time;
            this.content = content;
        }

        public byte[] toByte()
        {

            return new ClassSerializers().SerializeBinary(this).ToArray();
        }

        public static Signal fromByte(byte[] signalData)
        {   

            return new ClassSerializers().DeSerializeBinary(new MemoryStream(signalData)) as Signal;
        }

    }

    /// <summary>
    /// 
    /// </summary>
    [Serializable]
    public class SendImage
    {
        public string from;
        public string to;
        public string id;
        public bool isAnimate = false;
        public System.Drawing.Image image;

        public SendImage()
        {
            //
            // TODO: 在此处添加构造函数逻辑
            //
        }

        public byte[] toByte()
        {

            return new ClassSerializers().SerializeBinary(this).ToArray();
        }

        public static SendImage fromByte(byte[] imgData)
        {
            return new ClassSerializers().DeSerializeBinary(new MemoryStream(imgData)) as SendImage;
        }
    }


    /// <summary>
    /// 
    /// </summary>
    [Serializable]
    public class SendUser
    {
        public string userId;
        public string userName;
        public string userNo;

        public SendUser(string userId, string userNo, string userName)
        {
            this.userId = userId;
            this.userNo = userNo;
            this.userName = userName;
        }

        public byte[] toByte()
        {

            return new ClassSerializers().SerializeBinary(this).ToArray();
        }


        public static SendUser fromByte(byte[] userData)
        {
            return new ClassSerializers().DeSerializeBinary(new MemoryStream(userData)) as SendUser;
        }
    }
}
