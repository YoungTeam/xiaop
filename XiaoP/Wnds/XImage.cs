using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using XiaoP.Classes;
using XiaoP.Classes.Data;
using XiaoP.Classes.Service;
using XiaoP.Classes.Util;
using System.Windows.Forms;
using System.Threading;
using XiaoP.UI.Core.Bolt;
using XiaoP.Controls;

namespace XiaoP.Wnds
{
    internal sealed class XImage
    {
        public event Action<IntPtr> OnImgFinish;
        public event Action<IntPtr> OnHQImgFinish;


        public void getHQFace(string userId)
        {

            Thread thread = new Thread(new ThreadStart(
                () =>
                {

                    //Console.Write("\n========"+userId+"\n");
                    System.Drawing.Image img = UserService.getFace(userId);
                    ImageBox ibox = new ImageBox();
                    ibox.BackColor = Color.Transparent;
                    ibox.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
                    //ibox.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
                    ibox.ImageLayout = ImageBox.ImageLayoutStyle.Strench;
                    ibox.Image = img;
                    //ibox.Size = new System.Drawing.Size(88, 88);

                    XLBolt.Instance().Invoke(delegate()
                    {
                        if (OnHQImgFinish != null)
                        {
                            OnHQImgFinish(ibox.Handle);
                        }
                    });
                    
                }));

            thread.IsBackground = true;
            thread.Start();
        
        }


        public void getDefaultFace(int width,int height,int status)
        {
            Thread thread = new Thread(new ThreadStart(
            () =>
            {
                Image img = global::XiaoP.Properties.Resources.default_img;
                img = ImgHelper.geometricScaling(img, width, height);
               
                if (status != 1)
                    img = ImgHelper.transferToGrey(img);

                IntPtr imgHandle = IntPtr.Zero;
                if (img != null)
                {
                    imgHandle = ImgHelper.getImgHandle(img);
                }

                XLBolt.Instance().Invoke(delegate()
                {
                    if (OnImgFinish != null)
                    {
                        OnImgFinish(imgHandle);
                    }
                });

            }));

            thread.IsBackground = true;
            thread.Start();
        }


        public void getFace(string userId,int width,int height,int status)
        {
            Thread thread = new Thread(new ThreadStart(
            () =>
            {

                //Console.Write("\n========"+userId+"\n");
                System.Drawing.Image img = UserService.getFace(userId,width,height);
                if (status != 1)
                    img = ImgHelper.transferToGrey(img);

                IntPtr imgHandle = IntPtr.Zero;
                if (img != null)
                {
                    imgHandle = ImgHelper.getImgHandle(img);
                }

                XLBolt.Instance().Invoke(delegate()
                {
                    if (OnImgFinish != null)
                    {
                        OnImgFinish(imgHandle);
                    }
                });

            }));

            thread.IsBackground = true;
            thread.Start();
        }

        public void getImgByUrl(string url) {
            Thread thread = new Thread(new ThreadStart(
              () =>
              {

                  //Console.Write("\n========"+userId+"\n");
                  System.Drawing.Image img = ImgHelper.getImage(url,500);


                  IntPtr imgHandle = IntPtr.Zero;
                  if (img != null)
                  {

                      imgHandle = ImgHelper.getImgHandle(img);
                  }

                  XLBolt.Instance().Invoke(delegate()
                  {
                      if (OnImgFinish != null)
                      {
                          OnImgFinish(imgHandle);
                      }
                  });

              }));

            thread.IsBackground = true;
            thread.Start();
        
        }

        public void getSuggFace(string userId) {
            Thread thread = new Thread(new ThreadStart(
                () =>
                {

                    IntPtr imgHandle = IntPtr.Zero;

                    imgHandle = UserService.getFaceHandle(userId);
                    
                    XLBolt.Instance().Invoke(delegate()
                    {
                        if (OnImgFinish != null)
                        {
                            OnImgFinish(imgHandle);
                        }
                    });



                }));

            thread.IsBackground = true;
            thread.Start();
        }


        public IntPtr getGifHandleFromFile(string id, string from)
        {
            IntPtr gifHandle = IntPtr.Zero;
            if (from == "emotion")
            {
                string filePath = Global.PANDORA_PFOFILE + "system\\emotion\\default\\" + id + ".gif";

                gifHandle = ImgHelper.getGifHandle(filePath);
            }
            return gifHandle;
        }

        public void getFace(string userId)
        {
            Thread thread = new Thread(new ThreadStart(
            () =>
            {

                //Console.Write("\n========"+userId+"\n");
                int start = Environment.TickCount;
                System.Drawing.Image img = UserService.getFace(userId);
                Console.Write("==" + userId + ":" + (Environment.TickCount - start) + "\n");
               
                IntPtr imgHandle = IntPtr.Zero;
                if (img != null) {

                    imgHandle = ImgHelper.getImgHandle(img);
                }

                XLBolt.Instance().Invoke(delegate()
                {
                    if (OnImgFinish != null)
                    {
                        OnImgFinish(imgHandle);
                    }
                });

              

            }));

            thread.IsBackground = true;
            thread.Start();
        }

        

    }
}
