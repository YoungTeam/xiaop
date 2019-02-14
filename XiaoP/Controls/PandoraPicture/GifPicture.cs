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
    /// MyPicture ��ժҪ˵����
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
        /// ����������������
        /// </summary>
        private System.ComponentModel.Container components = null;

        public PandoraPicture()
        {
            // �õ����� Windows.Forms ���������������ġ�
            InitializeComponent();

            //            this.SizeMode=System.Windows.Forms.PictureBoxSizeMode.AutoSize;
            // TODO: �� InitializeComponent ���ú�����κγ�ʼ��

        }

        /// <summary> 
        /// ������������ʹ�õ���Դ��
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

        #region �����������ɵĴ���
        /// <summary> 
        /// �����֧������ķ��� - ��Ҫʹ�ô���༭�� 
        /// �޸Ĵ˷��������ݡ�
        /// </summary>
        private void InitializeComponent()
        {
            components = new System.ComponentModel.Container();
        }
        #endregion

        private string fileUrl = "";//GIFͼƬ�ļ��ľ���·��
        public string FileUrl
        {
            set { fileUrl = value; }
            get { return fileUrl; }
        }
    

        private string filename = "";//GIFͼƬ�ļ��ľ���·��
        public string FileName
        {
            set { filename = value; }
            get { return filename; }
        }

        public bool IsSent = false;//��ʶ��ͼƬ�Ƿ���Ҫ���͵��Է�,Ĭ�ϲ�����

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

    #region ��ǰ�û�������ӵ�ͼƬ������ClassGifs
    public class GifList : System.Collections.CollectionBase
    {
        public GifList()
        {
            //
            // TODO: �ڴ˴���ӹ��캯���߼�
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

        #region ��Gifs�в���ͼƬ�ؼ�
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
