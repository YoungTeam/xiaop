using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Net;
using System.Drawing;
using XiaoP.Classes.RabbitMQ;
using XiaoP.Classes.Data;
using XiaoP.Classes.Util;
using System.Drawing.Imaging;
using XiaoP.UI.Core.Bolt;
using XiaoP.UI.Core.Bolt.NET;

namespace XiaoP.Classes.Util
{
    class ImgHelper
    {


        public static byte[] toByteArray(Image img,ImageFormat format)
        {

            System.IO.MemoryStream ms = new System.IO.MemoryStream();
            img.Save(ms, format);
            byte[] imagedata = ms.GetBuffer();

            return imagedata;

        }

        public static Icon getIcon(Image img)
        {
            Icon ion = null;
            IntPtr ii = IntPtr.Zero;
            try
            {
                Bitmap bmp = new Bitmap(img);
                ii = bmp.GetHicon();
                ion = new Icon(Icon.FromHandle(ii), new Size(16, 19));
             
            }
            catch (Exception ex)
            {
                PLog.Exception(ex);
            }

            return ion;
        }


        public static IntPtr getData(string id, string type)
        {
            IntPtr img = IntPtr.Zero;
            if (!Directory.Exists(Global.CUR_USER.profiles + "images"))
                Directory.CreateDirectory(Global.CUR_USER.profiles + "images");

            if (File.Exists(Global.CUR_USER.profiles + "images\\" + id + "." + type))
            {
                img = ImgHelper.getImgHandleFromFile(Global.CUR_USER.profiles + "images\\" + id + "." + type);
                //img = Image.FromFile(Global.CUR_USER.profiles + "images\\" + id + "." + type);
            }
            else
            {

                byte[] response = null;
                using (RabbitMQHelper rabbitMQ = new RabbitMQHelper(Global.RABBITMQ_SERVER))
                {
                    rabbitMQ.timeOut = 10000;

                    RPCRequest rpcRequest = new RPCRequest();
                    rpcRequest.className = "com.yt.xiaop.service.ImgService";
                    rpcRequest.methodName = "getData";
                    rpcRequest.args = new object[] { id };

                    //Console.Write(s.toJson());
                    response = rabbitMQ.sendRequest(rpcRequest.toByte());
                }

                if (response != null)
                {
                    FileStream fs = null;
                    try
                    {
                        fs = File.OpenWrite(Global.CUR_USER.profiles + "images\\" + id + "." + type);
                        fs.Write(response, 0, response.Length);
                    }
                    catch (Exception ex)
                    {
                        PLog.Exception(ex);
                    }
                    finally
                    {
                        if (fs != null)
                            fs.Close();
                    }
                }

                img = ImgHelper.getImgHandleFromFile(Global.CUR_USER.profiles + "images\\" + id + "." + type);
                    //Image.FromFile(Global.CUR_USER.profiles + "images\\" + id + "." + type);
            }

            return img;
        }

        /// <summary>
        /// 把图片转换成灰色
        /// </summary>
        /// <param name="img"></param>
        /// <returns></returns>
        public static Bitmap transferToGrey(Image img)
        {
            if (img == null)
                return null;
            Bitmap copy = new Bitmap((Bitmap)img);
            BitmapGrey bg = new BitmapGrey(copy);

            bg.MakeGreyUnsafeFaster();
            return bg.Bitmap;
        }

        public static string getImgType(Image img)
        {

            string imgType = "bmp";
            if (img.RawFormat.Equals(System.Drawing.Imaging.ImageFormat.Jpeg))
            {
                imgType = "jpg";
            }
            else if (img.RawFormat.Equals(System.Drawing.Imaging.ImageFormat.Bmp))
            {
                imgType = "bmp";
            }
            else if (img.RawFormat.Equals(System.Drawing.Imaging.ImageFormat.Gif))
            {
                imgType = "gif";
            }
            else if (img.RawFormat.Equals(System.Drawing.Imaging.ImageFormat.Png))
            {
                imgType = "png";
            }
            return imgType;

        }

        public static Image smallPic(Image oldPic, int intWidth, int intHeight)
        {
            System.Drawing.Bitmap objNewPic;
            try
            {
                //objPic = new System.Drawing.Bitmap(strOldPic);
                objNewPic = new System.Drawing.Bitmap(oldPic, intWidth, intHeight);


            }
            catch (Exception exp)
            {
                throw exp;
            }
            finally
            {
                oldPic = null;
                //objNewPic = null;
            }

            return objNewPic;
        }

        public static Rectangle getScalingRec(Image oldPic, int intWidth, int intHeight)
        {
            if (oldPic == null)
                return new Rectangle(0,0,0,0);

            int newWidth = 100, newHeight = 100;
            try
            {
                
                if (intWidth != -1 && oldPic.Width > intWidth)
                {
                    newHeight = Convert.ToInt32((float)intWidth / (float)oldPic.Width * (float)oldPic.Height);
                    newWidth = intWidth;
                }

                if (intHeight != -1 && oldPic.Height > intHeight)
                {
                    newWidth = Convert.ToInt32((float)intHeight / (float)oldPic.Height * (float)oldPic.Width);
                    newHeight = intHeight;
                }
            }
            catch (Exception ex) {
                return new Rectangle(0, 0, 0, 0);
            }

            return new Rectangle(0, 0, newWidth, newHeight);
        }

        public static Image geometricScaling(Image oldPic, int intWidth, int intHeight)
        {
            if (oldPic == null)
                return null;
          
            int newWidth = 100, newHeight = 100;
            if (intWidth != -1 && oldPic.Width > intWidth)
            {
                newHeight = Convert.ToInt32((float)intWidth / (float)oldPic.Width * (float)oldPic.Height);
                newWidth = intWidth;
            }

            if (intHeight != -1 && oldPic.Height > intHeight)
            {
                newWidth = Convert.ToInt32((float)intHeight / (float)oldPic.Height * (float)oldPic.Width);
                newHeight = intHeight;
            }

            //截图对象 
            System.Drawing.Image pickedImage = null;
            System.Drawing.Graphics pickedG = null;
            //对象实例化
            pickedImage = new System.Drawing.Bitmap(newWidth, newHeight);
            pickedG = System.Drawing.Graphics.FromImage(pickedImage);
            //设置质量 
            pickedG.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
            pickedG.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
            //定位 
            Rectangle fromR = new Rectangle(0, 0, oldPic.Width, oldPic.Height);
            Rectangle toR = new Rectangle(0, 0, newWidth, newHeight);
            //画图 
            pickedG.DrawImage(oldPic, toR, fromR, System.Drawing.GraphicsUnit.Pixel);


            return (System.Drawing.Image)pickedImage.Clone();

        }

        public static Image getImageFromFile(string filePath) {
            return Image.FromFile(filePath);
        }

        public static Image getImage(string url,int timeOut)
        {   
            /*
            using (var webClient = new WebClient())
            {
                using (var stream = new MemoryStream(webClient.DownloadData(url)))
                {
                    return Image.FromStream(stream);
                }
                //return ByteArrayToImage(webClient.DownloadData(url));
            }*/
            
            
            Image image = null;
            try
            {

                HttpWebResponse webres = HttpHelper.getResponse(url, timeOut);
                //Stream stream = webres.GetResponseStream();
                //image = new Bitmap(stream);
                //image = Image.FromStream(stream);
                if (webres == null)
                    return null;

                using (Stream ms = new MemoryStream())
                {
                    webres.GetResponseStream().CopyTo(ms);
                    image = Image.FromStream(ms);
                }

                webres.Close();
            }
            catch (Exception ex)
            {
                Console.Write(ex.ToString());
            }

            return image;

        }

        public static void SaveQuality(Image image, string dirPath,string file)
        {

            System.IO.DirectoryInfo dInfo = new System.IO.DirectoryInfo(dirPath);
            if (!dInfo.Exists)
                dInfo.Create();

            System.Drawing.Imaging.ImageCodecInfo myImageCodecInfo;
            System.Drawing.Imaging.Encoder myEncoder;
            System.Drawing.Imaging.EncoderParameter myEncoderParameter;
            System.Drawing.Imaging.EncoderParameters myEncoderParameters;
            myImageCodecInfo = System.Drawing.Imaging.ImageCodecInfo.GetImageEncoders()[0];
            myEncoder = System.Drawing.Imaging.Encoder.Quality;
            myEncoderParameters = new System.Drawing.Imaging.EncoderParameters(1);
            myEncoderParameter = new System.Drawing.Imaging.EncoderParameter(myEncoder, 100L); // 0-100
            myEncoderParameters.Param[0] = myEncoderParameter;
            try
            {
                image.Save(dirPath + file, myImageCodecInfo, myEncoderParameters);
            
            }catch(Exception ex){
                PLog.Exception(ex);
            }
            finally
            {
                myEncoderParameter.Dispose();
                myEncoderParameters.Dispose();
            }
        }

        public static bool SaveXLBitmapToFile(IntPtr imgHandle, string fileDir,string fileName,int quantity)
        {
            if (!Directory.Exists(fileDir))
            {
                Directory.CreateDirectory(fileDir);
            }
           return  XLGraphics.XLGP_SaveXLBitmapToJpegFile(imgHandle, fileDir+fileName, quantity);
        }

        public static void SaveGif(Image image, string dirPath, string file)
        {
            try
            {
                image.Save(dirPath + file, ImageFormat.Gif);
            }
            catch (Exception ex)
            {
                PLog.Exception(ex);
            }
        }

        public static IntPtr getGifHandle(string filePath){
            if (File.Exists(filePath))
                return XLGraphics.XLGP_LoadGifFromFile(filePath);
            else
                return IntPtr.Zero;
        
        }

        public static IntPtr getImgHandle(Image image) {
            try
            {
                byte[] images = toByteArray(image, System.Drawing.Imaging.ImageFormat.Bmp);
                IntPtr xlfsStream = XLFS.XLFS_CreateStreamFromMemory(images, images.Length);
                IntPtr imgPtr = XLGraphics.XLGP_LoadOriginBmpFromStream(xlfsStream);
                return imgPtr;
            }
            catch (Exception ex) {
                PLog.Exception(ex);
            }

            return IntPtr.Zero;
        }

        public static IntPtr getImgHandleFromFile(string filePath) {
            if (File.Exists(filePath))
                return XLGraphics.XLGP_LoadJpegFromFile(filePath);
            else
                return IntPtr.Zero;
        }

        public static IntPtr getImgHandle(string url){

            WebResponse webres = null;
            try
            {
                webres = HttpHelper.getResponse(url, 300);
                Stream stream = webres.GetResponseStream();

                System.IO.MemoryStream memoryStream = new System.IO.MemoryStream();
                byte[] buffer = new byte[32 * 1024];
                int bytes;
                while ((bytes = stream.Read(buffer, 0, buffer.Length)) > 0)
                {
                    memoryStream.Write(buffer, 0, bytes);
                }
                byte[] images = memoryStream.GetBuffer();
              
                IntPtr xlfsStream = XLFS.XLFS_CreateStreamFromMemory(images, images.Length);
                IntPtr imgPtr = XLGraphics.XLGP_LoadJpegFromStream(xlfsStream);

                return imgPtr;
            }
            catch (Exception ex)
            {
                Console.Write(ex.ToString());
            }
            finally {
                if (webres != null)
                    webres.Close();
            }

            return IntPtr.Zero;
        
        }

    }


    public unsafe class BitmapGrey
    {
        Bitmap bitmap;

        // three elements used for MakeGreyUnsafe
        int width;
        BitmapData bitmapData = null;
        Byte* pBase = null;

        public BitmapGrey(Bitmap bitmap)
        {
            this.bitmap = bitmap;
        }

        public void Save(string filename)
        {
            bitmap.Save(filename, ImageFormat.Jpeg);
        }

        public void Dispose()
        {
            bitmap.Dispose();
        }

        public Bitmap Bitmap
        {
            get
            {
                return (bitmap);
            }
        }

        public Point PixelSize
        {
            get
            {
                GraphicsUnit unit = GraphicsUnit.Pixel;
                RectangleF bounds = bitmap.GetBounds(ref unit);

                return new Point((int)bounds.Width, (int)bounds.Height);
            }
        }

        public void MakeGrey()
        {
            Point size = PixelSize;

            for (int x = 0; x < size.X; x++)
            {
                for (int y = 0; y < size.Y; y++)
                {
                    Color c = bitmap.GetPixel(x, y);
                    int value = (c.R + c.G + c.B) / 3;
                    bitmap.SetPixel(x, y, Color.FromArgb(value, value, value));
                }
            }
        }

        public void MakeGreyUnsafe()
        {
            Point size = PixelSize;

            LockBitmap();

            for (int x = 0; x < size.X; x++)
            {
                for (int y = 0; y < size.Y; y++)
                {
                    PixelData* pPixel = PixelAt(x, y);

                    int value = (pPixel->red + pPixel->green + pPixel->blue) / 3;
                    pPixel->red = (byte)value;
                    pPixel->green = (byte)value;
                    pPixel->blue = (byte)value;
                }
            }
            UnlockBitmap();
        }

        public void MakeGreyUnsafeFaster()
        {
            Point size = PixelSize;

            LockBitmap();

            for (int y = 0; y < size.Y; y++)
            {
                PixelData* pPixel = PixelAt(0, y);
                for (int x = 0; x < size.X; x++)
                {
                    byte value = (byte)((pPixel->red + pPixel->green + pPixel->blue) / 3);
                    pPixel->red = value;
                    pPixel->green = value;
                    pPixel->blue = value;
                    pPixel++;
                }
            }
            UnlockBitmap();
        }


        public void LockBitmap()
        {
            GraphicsUnit unit = GraphicsUnit.Pixel;
            RectangleF boundsF = bitmap.GetBounds(ref unit);
            Rectangle bounds = new Rectangle((int)boundsF.X,
                (int)boundsF.Y,
                (int)boundsF.Width,
                (int)boundsF.Height);

            // Figure out the number of bytes in a row
            // This is rounded up to be a multiple of 4
            // bytes, since a scan line in an image must always be a multiple of 4 bytes
            // in length. 
            width = (int)boundsF.Width * sizeof(PixelData);
            if (width % 4 != 0)
            {
                width = 4 * (width / 4 + 1);
            }

            bitmapData =
                bitmap.LockBits(bounds, ImageLockMode.ReadWrite, PixelFormat.Format24bppRgb);

            pBase = (Byte*)bitmapData.Scan0.ToPointer();
        }

        public PixelData* PixelAt(int x, int y)
        {
            return (PixelData*)(pBase + y * width + x * sizeof(PixelData));
        }

        public void UnlockBitmap()
        {
            bitmap.UnlockBits(bitmapData);
            bitmapData = null;
            pBase = null;
        }
    }

    public struct PixelData
    {
        public byte blue;
        public byte green;
        public byte red;
    }



}
