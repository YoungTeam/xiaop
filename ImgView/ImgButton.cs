using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Text;
using System.Windows.Forms;
using System.Drawing.Drawing2D;

namespace PSkin.PControl.PButton
{
    public partial class ImgButton : UserControl
    {
       // private Point m_ptMousePos;             //鼠标的位置
        private bool m_MouseOnControl = false;
        private bool m_MouseClickedControl = false;
     

        public ImgButton()
        {
            InitializeComponent();
            this.SetStyle(ControlStyles.DoubleBuffer, true);// 双缓冲
            //this.SetStyle(ControlStyles.ResizeRedraw, true);
            this.SetStyle(ControlStyles.OptimizedDoubleBuffer, true);
            this.SetStyle(ControlStyles.AllPaintingInWmPaint, true);
            //this.SetStyle(ControlStyles.UserPaint, true);
            //this.SetStyle(ControlStyles.SupportsTransparentBackColor, true);
            base.UpdateStyles();
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);
            Graphics g = e.Graphics;

            //Rectangle thisRec = new Rectangle(0,0,this.Width,this.Height);
            g.InterpolationMode = InterpolationMode.HighQualityBilinear;

            //g.FillRectangle(new SolidBrush(Color.FromArgb(255, this.BackColor)),
              //                        this.ClientRectangle);
           
            Image img = this.normalBg;
            if (m_MouseClickedControl)
            {
                if(this.clickedBg != null)
                    img = this.clickedBg;
            }
            else if (m_MouseOnControl)
            {
                if (this.hoverBg != null)
                    img = this.hoverBg;
            }
            else
                img = this.normalBg;

            if (img != null)
            {
                Rectangle thisRec = new Rectangle((this.Width-img.Width)/2, (this.Height-img.Height)/2, img.Width, img.Height);
                g.DrawImage(img, thisRec);       //如果在线根据在想状态绘制小图标
            }

           
        }

        protected override void WndProc(ref Message m)
        {

            if (m.Msg == 0x0014) // 禁掉清除背景消息

                return;

            base.WndProc(ref m);

        }

        private Image normalBg;
        /// <summary>
        /// 获取或者设置正常图片
        /// </summary>
        [DefaultValue(typeof(Image), null), Category("ControlColor")]
        [Description("正常状态下显示的图片")]
        public Image NormalBg
        {
            get { return normalBg; }
            set { normalBg = value; }
        }


        private Image hoverBg;
        /// <summary>
        /// 获取或者设置激活图片
        /// </summary>
        public Image HoverBg
        {
            get { return hoverBg; }
            set { hoverBg = value; }
        }

        private Image clickedBg;
        /// <summary>
        ///  获取或者设置点击后图片
        /// </summary>
        public Image ClickedBg
        {
            get { return clickedBg; }
            set { clickedBg = value; }
        }

        protected override void OnMouseDown(MouseEventArgs e) {

            if (m_MouseOnControl)
            {
                m_MouseClickedControl = true;
                this.Invalidate();
            }
            base.OnMouseDown(e);
        }

        protected override void OnMouseUp(MouseEventArgs e)
        {

            m_MouseClickedControl = false;
            this.Invalidate();
            base.OnMouseUp(e);
        }

        protected override void OnMouseMove(MouseEventArgs e)
        {

                this.Cursor = Cursors.Arrow;
                if (!m_MouseOnControl)
                {
                    m_MouseOnControl = true;
                    this.Invalidate();
                }
                base.OnMouseMove(e);
        }

        protected override void OnMouseLeave(EventArgs e)
        {

            if (m_MouseOnControl)
            {
                m_MouseOnControl = false;
                this.Invalidate();
            }
            base.OnMouseLeave(e);
        }
	
    }
}
