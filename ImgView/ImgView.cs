using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;
namespace Pandora
{
    public partial class ImgView : Form
    {
        private Rectangle currRect = Rectangle.Empty; //所画矩形
        /// <summary>
        /// 遮罩层颜色
        /// </summary>
        private SolidBrush mask = new SolidBrush(Color.FromArgb(100, 0, 0, 0));

        private Image ScreenImage;

        //抓屏Api
        [DllImport("gdi32.dll")]
        static extern bool BitBlt(IntPtr hdcDest, int xDest, int yDest, int wDest, int hDest, IntPtr hdcSource, int xSrc, int ySrc, CopyPixelOperation rop);
        [DllImport("user32.dll")]
        static extern bool ReleaseDC(IntPtr hWnd, IntPtr hDc);
        [DllImport("gdi32.dll")]
        static extern IntPtr DeleteDC(IntPtr hDc);
        [DllImport("gdi32.dll")]
        static extern IntPtr DeleteObject(IntPtr hDc);
        [DllImport("gdi32.dll")]
        static extern IntPtr CreateCompatibleBitmap(IntPtr hdc, int nWidth, int nHeight);
        [DllImport("gdi32.dll")]
        static extern IntPtr CreateCompatibleDC(IntPtr hdc);
        [DllImport("gdi32.dll")]
        static extern IntPtr SelectObject(IntPtr hdc, IntPtr bmp);
        [DllImport("user32.dll")]
        public static extern IntPtr GetDesktopWindow();
        [DllImport("user32.dll")]
        public static extern IntPtr GetWindowDC(IntPtr ptr);


        bool startMove = false;//标识是否开始移动图片
        Point moveStartPoint = Point.Empty;
        //int max

        private string _imgPath;

        public string imgPath
        {
            get { return _imgPath; }
            set { _imgPath = value; }
        }

        private int minImgWidth = 0;
        private int minImgHeight = 0;

     
        public ImgView(Image img){
            if (img == null) {
                return;
            }

            InitializeComponent();
            //双缓冲绘制，避免闪烁
            this.SetStyle(ControlStyles.DoubleBuffer | ControlStyles.AllPaintingInWmPaint | ControlStyles.UserPaint, true);
            //无边框
            this.FormBorderStyle = FormBorderStyle.None;
            //不在任务栏中显示，用户按开始键或Ctrl+Tab时
            this.ShowInTaskbar = false;
            //置于顶层
            this.TopMost = true;
            //窗口布满整个屏幕
            this.StartPosition = FormStartPosition.Manual;
            //this.Bounds = System.Windows.Forms.Screen.PrimaryScreen.Bounds;
            //查看任务管理器时用
            //this.Height -= 30;
            //接受键盘输入，用于快捷键，如Esc
            this.KeyPreview = true;

            //保留原来
            ScreenImage = GetScreenImage();

            //将当前屏做为背景
            Image BackScreen = new Bitmap(ScreenImage);
            Graphics g = Graphics.FromImage(BackScreen);
            //画遮罩
            g.FillRectangle(this.mask, 0, 0, BackScreen.Width, BackScreen.Height);


            //Font font = new Font("宋体", 18f, FontStyle.Bold);
            //g.DrawString("使用滚轮缩放,Esc退出", font, Brushes.Gold, 10, 10);
            //g.DrawString("http://www.our-code.com", font, Brushes.Gold, 10, 35);
            //g.DrawImage(winStudy.Properties.Resources.face1, 550, 5);
           
            //g.DrawImage(global::ImgView.Properties.Resources.close, this.closeRec);
            g.Dispose();
            this.BackgroundImage = BackScreen;

            /*
            //彩色光标
            curRGB = new Cursor(winStudy.Properties.Resources.Arrow_M.Handle);
            Cursor = curRGB;
            toolTip1.SetToolTip(this, "按住左键不放选择截图区域,可重复选择");

             */
            //计算图片大小和屏幕分辨率大小比
            int initMaxWidth = (int)(BackScreen.Width * 0.6);
            int initMaxHeight = (int)(BackScreen.Height * 0.6);

            int imgWidth = img.Width;
            int imgHeight = img.Height;
            if (img.Width > initMaxWidth || img.Height > initMaxHeight) {
                imgWidth = (int)(img.Width * 0.6);
                imgHeight = (int)(img.Height * 0.6);            
            }

            this.minImgWidth = (int)(img.Width * 0.1);
            this.minImgHeight = (int)(img.Height * 0.1);

            this.PictureBox_Img.Image = img;
            this.PictureBox_Img.Size = new Size(imgWidth, imgHeight);

            //this.Opacity = 0.4;
           // this.imgButton1.Parent = this.PictureBox_Img;
            

            

            //this.Paint += new PaintEventHandler(ImgView_Paint);
            this.MouseWheel += new MouseEventHandler(this.ImgView_MouseWheel);
            this.MouseClick += new MouseEventHandler(this.ImgView_MouseClick);

        }

                //重绘窗口
        protected override void OnPaint(PaintEventArgs e)
        {

            /*
            //try
           // {
                Graphics g = e.Graphics;
                g.SmoothingMode = SmoothingMode.HighQuality; //高质量

                this.closeRec = new Rectangle(this.PictureBox_Img.Location.X + this.PictureBox_Img.Width - 5, this.PictureBox_Img.Location.Y - 24,27,29);
                g.DrawImage(global::ImgView.Properties.Resources.close, this.closeRec);
               
            // }*/
        }

        public ImgView(string imgPath)
        {
            InitializeComponent();
            //双缓冲绘制，避免闪烁
            this.SetStyle(ControlStyles.DoubleBuffer | ControlStyles.AllPaintingInWmPaint | ControlStyles.UserPaint, true);
            //无边框
            this.FormBorderStyle = FormBorderStyle.None;
            //不在任务栏中显示，用户按开始键或Ctrl+Tab时
            this.ShowInTaskbar = false;
            //置于顶层
            this.TopMost = true;
            //窗口布满整个屏幕
            this.StartPosition = FormStartPosition.Manual;
            //this.Bounds = System.Windows.Forms.Screen.PrimaryScreen.Bounds;
            //查看任务管理器时用
            //this.Height -= 30;
            //接受键盘输入，用于快捷键，如Esc
            this.KeyPreview = true;

            //保留原来
            ScreenImage = GetScreenImage();
            //将当前屏做为背景
            Image BackScreen = new Bitmap(ScreenImage);
            Graphics g = Graphics.FromImage(BackScreen);
            //画遮罩
            g.FillRectangle(this.mask, 0, 0, BackScreen.Width, BackScreen.Height);
           
            /*
            Font font = new Font("宋体", 18f, FontStyle.Bold);
            g.DrawString("使用滚轮缩放,Esc退出", font, Brushes.Gold, 10, 10);
            //g.DrawString("http://www.our-code.com", font, Brushes.Gold, 10, 35);
            //g.DrawImage(winStudy.Properties.Resources.face1, 550, 5);
            
             */
            
            g.Dispose();
            this.BackgroundImage = BackScreen;

            /*
            //彩色光标
            curRGB = new Cursor(winStudy.Properties.Resources.Arrow_M.Handle);
            Cursor = curRGB;
            toolTip1.SetToolTip(this, "按住左键不放选择截图区域,可重复选择");

             */

            if (imgPath != null)
            {
                Image img = null;
                try
                {
                    img = Image.FromFile(imgPath);
                    if (img == null)
                    {
                        MessageBox.Show("加载图片失败！");
                        return;
                    }
                }catch(Exception ex){
                    Console.Write(ex.Message);
                    MessageBox.Show("图片文件不存在！");
                    return;
                }

                this.PictureBox_Img.Image = img;
                this.PictureBox_Img.Size = new Size(img.Width, img.Height);

            }

            //this.Paint += new PaintEventHandler(ImgView_Paint);
            this.MouseWheel +=new MouseEventHandler(this.ImgView_MouseWheel);
            this.MouseClick +=new MouseEventHandler(this.ImgView_MouseClick);
        }

        private Image GetScreenImage()
        {
            //可以抓悬浮窗等LayeredWindow
            //出自http://social.msdn.microsoft.com/forums/en-US/winforms/thread/474450b9-e260-4369-9efb-0d57a5b2e06d/
            Size sz = Screen.PrimaryScreen.Bounds.Size;
            IntPtr hDesk = GetDesktopWindow();
            IntPtr hSrce = GetWindowDC(hDesk);
            IntPtr hDest = CreateCompatibleDC(hSrce);
            IntPtr hBmp = CreateCompatibleBitmap(hSrce, sz.Width, sz.Height);
            IntPtr hOldBmp = SelectObject(hDest, hBmp);
            bool b = BitBlt(hDest, 0, 0, sz.Width, sz.Height, hSrce, 0, 0, CopyPixelOperation.SourceCopy | CopyPixelOperation.CaptureBlt);
            Bitmap bmp = Bitmap.FromHbitmap(hBmp);
            SelectObject(hDest, hOldBmp);
            DeleteObject(hBmp);
            DeleteDC(hDest);
            ReleaseDC(hDesk, hSrce);
            return bmp;
        }

        /*
        void ImgView_Paint(object sender, PaintEventArgs e)
        {
            if (bb)
            {
                // this.panel2.Refresh();

                // if (zoom)
                {
                    Graphics g = this.panel2.CreateGraphics();
                    g.DrawImage(image1, (float)x, (float)y, a, b);

                }
                //else
                //{
                //     DrawImageRect4IntAtrrib2(e);

                //}


            }
            bb = false;
        }*/


        private void ExitForm(bool isMouse)
        {
            if (this.currRect == Rectangle.Empty)
            {
                
                this.Close();
                //this.DialogResult = DialogResult.Cancel;
            }
            else
            {   
                /*
                //右键在矩形区中，显示快捷菜单
                if (isMouse && currRect.Contains(Cursor.Position))
                {
                    cmenuRect.Show(Cursor.Position);
                }
                else
                {
                    this.currRect = Rectangle.Empty;
                    this.Invalidate();
                }*/
            }
        }


        private void ImgView_MouseClick(object sender,MouseEventArgs e) { 
        
                            //右键在矩形区中，显示快捷菜单
                if (!this.PictureBox_Img.Bounds.Contains(Cursor.Position))
                {
                    this.Close();
                }
            
        }


        #region 快捷键

        protected override void OnKeyUp(KeyEventArgs e)
        {
            if (e.KeyData == Keys.Escape)
            {
               
                ExitForm(false);
            }
            base.OnKeyUp(e);
        }
        #endregion

        Point rectangleCenter = Point.Empty; 

        private void ImgView_Resize(object sender, EventArgs e)
        {
            rectangleCenter = new Point(this.Width/2,this.Height/2);
            this.PictureBox_Img.Location = this.GetRectangleLeftTopPoint(rectangleCenter,this.PictureBox_Img.Width,this.PictureBox_Img.Height);
        }


        private Point GetRectangleLeftTopPoint(Point center, int width, int height) {
            int halfWidth = (int)(width/2);
            int halfHeight = (int)(height / 2);
            Point leftTop = new Point(center.X - halfWidth,center.Y-halfHeight);
            return leftTop;
        }

        private void ImgView_MouseWheel(object sender, MouseEventArgs e)
        {
           

            double scale = 1;

            if (this.PictureBox_Img.Height > 0)
            {

                scale = (double)this.PictureBox_Img.Width / (double)this.PictureBox_Img.Height;

            }

            int newWidth = this.PictureBox_Img.Width + (int)(e.Delta * scale);
            int newHeight = this.PictureBox_Img.Height + e.Delta;

            if (newWidth < this.minImgWidth || newHeight < this.minImgHeight)
                return;

            if (newWidth > this.BackgroundImage.Width * 1.5 || newHeight > this.BackgroundImage.Height * 1.5)
                return;

            this.PictureBox_Img.Width = newWidth;

            this.PictureBox_Img.Height = newHeight;

            this.PictureBox_Img.Location = this.GetRectangleLeftTopPoint(rectangleCenter, this.PictureBox_Img.Width, this.PictureBox_Img.Height);

            //this.imgButton1.Invalidate();
            this.Invalidate();
        }

        private void PictureBox_Img_MouseHover(object sender, EventArgs e)
        {
            Cursor = Cursors.Hand;

            this.PictureBox_Img.Focus();
        }

        private void PictureBox_Img_MouseLeave(object sender, EventArgs e)
        {
            Cursor = Cursors.Default;
        }

        private void PictureBox_Img_MouseMove(object sender, MouseEventArgs e)
        {
            if (startMove)
            {

                //移动向量

                Point vector = new Point(e.X - moveStartPoint.X, e.Y - moveStartPoint.Y);

                Point original = this.PictureBox_Img.Location;

                this.PictureBox_Img.Location = new Point(original.X + vector.X, original.Y + vector.Y);

                rectangleCenter = new Point(rectangleCenter.X + vector.X, rectangleCenter.Y + vector.Y);

                this.Invalidate();
               

            }
        }

        private void PictureBox_Img_MouseDown(object sender, MouseEventArgs e)
        {
            startMove = true;

            moveStartPoint = e.Location;  
        }

        private void PictureBox_Img_MouseUp(object sender, MouseEventArgs e)
        {
            startMove = false;
        }

        private void ImgView_Load(object sender, EventArgs e)
        {

            System.Drawing.Drawing2D.GraphicsPath myGraphicsPath = new System.Drawing.Drawing2D.GraphicsPath();
            //myGraphicsPath.AddEllipse(new Rectangle(0, 0, 125, 125));
            //myGraphicsPath.AddEllipse(new Rectangle(75, 75, 20, 20));
            myGraphicsPath.AddEllipse(new Rectangle(2, -30, 96, 94));
            //myGraphicsPath.AddEllipse(new Rectangle(145, 75, 20, 20));
            this.imgButton1.Region = new Region(myGraphicsPath);

        }

        private void ImgButton_Close_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void imgButton1_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void imgButton1_MouseHover(object sender, EventArgs e)
        {
            this.Cursor = Cursors.Hand;
        }


    }
}