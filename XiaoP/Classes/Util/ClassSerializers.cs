using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;  
namespace XiaoP.Classes.Util
{
    class ClassSerializers
    {
        public ClassSerializers()
        {
            //
            // TODO: 在此处添加构造函数逻辑
            //
        }

        #region Binary Serializers
        public System.IO.MemoryStream SerializeBinary(object request)
        {
            System.Runtime.Serialization.Formatters.Binary.BinaryFormatter serializer = new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter();
            System.IO.MemoryStream memStream = new System.IO.MemoryStream();
            serializer.Serialize(memStream, request);
            return memStream;
        }

        public object DeSerializeBinary(System.IO.MemoryStream memStream)
        {
            memStream.Position = 0;
            System.Runtime.Serialization.Formatters.Binary.BinaryFormatter deserializer = new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter();
            object newobj = deserializer.Deserialize(memStream);
            memStream.Close();
            return newobj;
        }
        #endregion


        public static byte[] IntToByte(int i)
        {

            byte[] shi = System.BitConverter.GetBytes(i);
            return shi;


        }

        public static int BytesToInt(byte[] bytes)
        {

            int sh = System.BitConverter.ToInt32(bytes, 0);
            return sh;

        }


        public static T Clone<T>(T RealObject)
        {
            using (Stream objectStream = new MemoryStream())
            {
                IFormatter formatter = new BinaryFormatter();
                formatter.Serialize(objectStream, RealObject);
                objectStream.Seek(0, SeekOrigin.Begin);
                return (T)formatter.Deserialize(objectStream);
            }
        }  
    }
}
