using System;
using System.ComponentModel;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;
using System.Drawing;
using XiaoP.Classes.Util;

namespace Pandora.Module.Component
{

    /// <summary> 
    /// MyPicture 的摘要说明。
    /// </summary>
    public partial class PandoraPicture : System.Windows.Forms.PictureBox
    {

        private Image _oriImg;
        
        public Image oriImg
        {
            get {
                //if (this._oriImg == null)
                //    return this.Image;
                //else
                    return _oriImg; 
            
            }
            set { 
                
                _oriImg = value;

              
                int picWidth = _oriImg.Width;
                int picHeight = _oriImg.Height;


                if (picWidth > 300)
                {
                    picHeight = Convert.ToInt32((float)300 / (float)picWidth * (float)picHeight);
                    picWidth = 300;
                }

                this.Image = ImgHelper.smallPic(_oriImg, picWidth, picHeight);
                this.Size = new Size(picWidth, picHeight);
                
            }
        }

        /// <summary> 
        /// 必需的设计器变量。
        /// </summary>
        private System.ComponentModel.Container components = null;

        public PandoraPicture()
        {
            // 该调用是 Windows.Forms 窗体设计器所必需的。
            InitializeComponent();

            //            this.SizeMode=System.Windows.Forms.PictureBoxSizeMode.AutoSize;
            // TODO: 在 InitializeComponent 调用后添加任何初始化

        }

        /// <summary> 
        /// 清理所有正在使用的资源。
        /// </summary>
        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                if (components != null)
                {
                    components.Dispose();
                }
            }
            base.Dispose(disposing);
        }

        #region 组件设计器生成的代码
        /// <summary> 
        /// 设计器支持所需的方法 - 不要使用代码编辑器 
        /// 修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            components = new System.ComponentModel.Container();
        }
        #endregion

        private string fileUrl = "";//GIF图片文件的绝对路径
        public string FileUrl
        {
            set { fileUrl = value; }
            get { return fileUrl; }
        }
    

        private string filename = "";//GIF图片文件的绝对路径
        public string FileName
        {
            set { filename = value; }
            get { return filename; }
        }

        public bool IsSent = false;//标识此图片是否需要发送到对方,默认不发送

        public void playGif()
        {
            System.Drawing.ImageAnimator.Animate(this.Image, new System.EventHandler(delegate(object sender, EventArgs e)
            {

                this.OnFrameChanged(sender,e);
            }));
        }



        private void OnFrameChanged(object sender, EventArgs e)
        {
            if (this.InvokeRequired)
            {
                this.BeginInvoke(new EventHandler(this.OnFrameChanged), new object[] { sender, e });
            }
            else
            {
                this.Invalidate();
            }
            //Force a call to the Paint event handler.
            //this.Invalidate();
            //this.Refresh();
        }



    }

    #region 当前用户自行添加的图片集合类ClassGifs
    public class GifList : System.Collections.CollectionBase
    {
        public GifList()
        {
            //
            // TODO: 在此处添加构造函数逻辑
            //
        }
        public void add(PandoraPicture tempGif)
        {
            foreach(PandoraPicture pic in base.InnerList){
                if (tempGif.Tag == pic.Tag)
                    return;
            }
            base.InnerList.Add(tempGif);
        }

        public void Romove(PandoraPicture tempGif)
        {
            base.InnerList.Remove(tempGif);
        }

        #region 在Gifs中查找图片控件
        public static PandoraPicture findPic(string ID, GifList gifs)
        {
            foreach (PandoraPicture pic in gifs)
                if (Convert.ToString(pic.Tag) == ID)
                    return pic;
            return null;
        }
        #endregion 
    }

    #endregion

}
