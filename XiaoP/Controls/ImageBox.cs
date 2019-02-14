using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Text;
using System.Windows.Forms;
using System.Drawing.Drawing2D;
using XiaoP.Classes.Util;

namespace XiaoP.Controls
{
    public partial class ImageBox : UserControl
    {
        public ImageBox()
        {
            InitializeComponent();
            this.SetStyle(ControlStyles.ResizeRedraw, true);
            this.SetStyle(ControlStyles.OptimizedDoubleBuffer, true);
            this.SetStyle(ControlStyles.AllPaintingInWmPaint, true);
            this.SetStyle(ControlStyles.UserPaint, true);
            this.SetStyle(ControlStyles.SupportsTransparentBackColor, true);
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics g = e.Graphics;

            Rectangle thisRec = new Rectangle(this.Padding.Left, this.Padding.Top,
                    this.Width - this.Padding.Left - this.Padding.Right,
                    this.Height - this.Padding.Top - this.Padding.Bottom);


            /*= new Rectangle(0,0,this.Width,this.Height);
           
            if (this.imageLayout == ImageLayoutStyle.Strench)
            {
                thisRec = 
             */
            new Rectangle(this.Padding.Left, this.Padding.Top,
                this.Width - this.Padding.Left - this.Padding.Right,
                this.Height - this.Padding.Top - this.Padding.Bottom);
            //}
            if (this.imageLayout == ImageLayoutStyle.Center)
            {

                //Color pixelColor = this.BackColor;

                //if (this._image != null)
                //    pixelColor = ((Bitmap)this._image).GetPixel(2,2);

                SolidBrush br = new SolidBrush(Color.White);

                g.FillRectangle(br, thisRec);

                br.Dispose();
                thisRec = new Rectangle((this.Width - this._image.Width) / 2,
                    (this.Height - this._image.Height) / 2,
                       this._image.Width,
                       this._image.Height);
            }

            g.InterpolationMode = InterpolationMode.HighQualityBilinear;

            g.DrawImage(this._image, thisRec);


            /*
            try
            {
                Bitmap Backbmp = global::PSkin.Properties.Resources.UserNull;

                float w = (float)(Backbmp.Width * 0.2);

                using (Graphics g = Graphics.FromImage(Backbmp))
                {

                    using (Brush brush = new SolidBrush(Color.FromArgb(0, 156, 255)))
                    {
                        using (Pen pen = new Pen(brush, w))
                        {
                            pen.DashStyle = DashStyle.Custom;



                            g.DrawEllipse(pen, new Rectangle(0, 0, Math.Abs(Backbmp.Width), Math.Abs(Backbmp.Height)));

                            g.Dispose();

                            this.BackgroundImage = Backbmp;
                        }
                    }
                }
            }
            catch (Exception)
            {
            }*/
            //g.Dispose();
            base.OnPaint(e);
        }

        private Image _image = null;//global::PSkin.Properties.Resources.UserNull;
        /// <summary>
        /// 
        /// </summary> 
        [DefaultValue(typeof(Image), null), Category("ControlColor")]
        [Description("显示的图片")]

        public Image Image
        {
            get { return _image; }
            set
            {
                if (value != null)
                {
                    this._image = ImgHelper.geometricScaling(value, this.Width - this.Padding.Left - this.Padding.Right,
                        this.Height - this.Padding.Top - this.Padding.Bottom
                        );
                    //ImageHelper.Square(value, this.Width - this.Padding.Left - this.Padding.Right,
                    //this.Height - this.Padding.Top - this.Padding.Bottom
                    //);
                }
            }
        }

        private ImageLayoutStyle imageLayout = ImageLayoutStyle.Strench;

        public ImageLayoutStyle ImageLayout
        {
            get { return imageLayout; }
            set { imageLayout = value; }
        }


        //枚举系统按钮状态
        public enum ImageLayoutStyle
        {
            Center = 0,
            Strench = 1
        }  
	
    }
}
