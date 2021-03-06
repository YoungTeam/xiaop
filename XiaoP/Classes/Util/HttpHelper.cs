using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using System.IO;
using System.Net;
using System.Drawing;
using System.IO.Compression;

namespace XiaoP.Classes.Util
{
    class HttpHelper
    {

        /*
        public static bool saveFile(string url,string fileName)
        {   
            WebResponse response = getResponse(url);
            if (response == null)
                return false;
            return  FileHelper.SaveBinaryFile(getResponse(url),fileName);
        }*/

        public static WebResponse getResponse(string url)
        {
            return getResponse(url,200);
        }

        public static HttpWebResponse getResponse(string url,int timeOut) {
            HttpWebResponse response = null;
            try
            {
                WebRequest webreq = WebRequest.Create(url);
                webreq.Proxy = null;
                //1秒超时
                webreq.Timeout = timeOut;
                response = (HttpWebResponse)webreq.GetResponse();
                if (response.StatusCode != HttpStatusCode.OK)
                    return null;               
            }
            catch (Exception ex)
            {
                Console.Write(ex.ToString());
            }

            return response;
        }

        /// <summary>
        /// 模拟 HTTP POST 请求
        /// </summary>
        /// <param name="url"></param>
        /// <param name="args"></param>
        /// <returns></returns>
        public static string httpPost(string url,Hashtable args,int timeOut) {

            System.Net.ServicePointManager.Expect100Continue = false;

            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);  
            request.CookieContainer = new CookieContainer();  
            CookieContainer cookie = request.CookieContainer;//如果用不到Cookie，删去即可  
           
            //以下是发送的http头，随便加，其中referer挺重要的，有些网站会根据这个来反盗链  
            //request.Referer = “http://localhost/index.php”;  
            //request.Accept = "Accept:text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8";  
            /*
                
            request.Headers["Accept-Language"] = "zh-CN,zh;q=0.";  
                request.Headers["Accept-Charset"] = "GBK,utf-8;q=0.7,*;q=0.3";  
                request.UserAgent = "User-Agent:Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.835.202 Safari/535.1";  
                request.KeepAlive = true;  
                */
            //上面的http头看情况而定，但是下面俩必须加  
            request.ContentType = "application/x-www-form-urlencoded";  
            request.Method = "POST";


            string postDataStr = "";
            int i = 0;
            if (args != null) {
                foreach (Object key in args.Keys)
                {
                    if (i != 0)
                        postDataStr += "&";
                    postDataStr += key + "=" + args[key];
                    i++;
                }
            }

            Encoding encoding = Encoding.UTF8;//根据网站的编码自定义  
            byte[] postData = encoding.GetBytes(postDataStr);//postDataStr即为发送的数据，格式还是和上次说的一样  
            request.ContentLength = postData.Length;  
            Stream requestStream = request.GetRequestStream();  
            requestStream.Write(postData, 0, postData.Length);

            StreamReader streamReader = null;
            Stream responseStream = null;

            string retString = "";
            try
            {
                HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                responseStream = response.GetResponseStream();
                //如果http头中接受gzip的话，这里就要判断是否为有压缩，有的话，直接解压缩即可  
                if (response.Headers["Content-Encoding"] != null && response.Headers["Content-Encoding"].ToLower().Contains("gzip"))
                {
                    responseStream = new GZipStream(responseStream, CompressionMode.Decompress);
                }

                streamReader = new StreamReader(responseStream, encoding);
                retString = streamReader.ReadToEnd();


            }
            catch (Exception ex)
            {
                PLog.Exception(ex);
            }
            finally { 
                if(streamReader !=null)
                    streamReader.Close();  
                if(responseStream!=null)
                    responseStream.Close();  

            }
          
              
            return retString;  
        
        }

    }
}
