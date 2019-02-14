namespace Pandora
{
    partial class ImgView
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.PictureBox_Img = new System.Windows.Forms.PictureBox();
            this.imgButton1 = new PSkin.PControl.PButton.ImgButton();
            ((System.ComponentModel.ISupportInitialize)(this.PictureBox_Img)).BeginInit();
            this.SuspendLayout();
            // 
            // PictureBox_Img
            // 
            this.PictureBox_Img.Cursor = System.Windows.Forms.Cursors.Hand;
            this.PictureBox_Img.Location = new System.Drawing.Point(89, 88);
            this.PictureBox_Img.Name = "PictureBox_Img";
            this.PictureBox_Img.Size = new System.Drawing.Size(100, 50);
            this.PictureBox_Img.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.PictureBox_Img.TabIndex = 0;
            this.PictureBox_Img.TabStop = false;
            this.PictureBox_Img.MouseLeave += new System.EventHandler(this.PictureBox_Img_MouseLeave);
            this.PictureBox_Img.MouseMove += new System.Windows.Forms.MouseEventHandler(this.PictureBox_Img_MouseMove);
            this.PictureBox_Img.MouseDown += new System.Windows.Forms.MouseEventHandler(this.PictureBox_Img_MouseDown);
            this.PictureBox_Img.MouseHover += new System.EventHandler(this.PictureBox_Img_MouseHover);
            this.PictureBox_Img.MouseUp += new System.Windows.Forms.MouseEventHandler(this.PictureBox_Img_MouseUp);
            // 
            // imgButton1
            // 
            this.imgButton1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.imgButton1.BackColor = System.Drawing.Color.Transparent;
            this.imgButton1.ClickedBg = global::ImgView.Properties.Resources.close_hover;
            this.imgButton1.Cursor = System.Windows.Forms.Cursors.Hand;
            this.imgButton1.HoverBg = global::ImgView.Properties.Resources.close_hover;
            this.imgButton1.Location = new System.Drawing.Point(218, -1);
            this.imgButton1.Name = "imgButton1";
            this.imgButton1.NormalBg = global::ImgView.Properties.Resources.close;
            this.imgButton1.Size = new System.Drawing.Size(66, 69);
            this.imgButton1.TabIndex = 1;
            this.imgButton1.Click += new System.EventHandler(this.imgButton1_Click);
            this.imgButton1.MouseHover += new System.EventHandler(this.imgButton1_MouseHover);
            // 
            // ImgView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(284, 262);
            this.Controls.Add(this.imgButton1);
            this.Controls.Add(this.PictureBox_Img);
            this.Name = "ImgView";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "�鿴ͼƬ";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.Load += new System.EventHandler(this.ImgView_Load);
            this.Resize += new System.EventHandler(this.ImgView_Resize);
            ((System.ComponentModel.ISupportInitialize)(this.PictureBox_Img)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.PictureBox PictureBox_Img;
        private PSkin.PControl.PButton.ImgButton imgButton1;
    }
}

