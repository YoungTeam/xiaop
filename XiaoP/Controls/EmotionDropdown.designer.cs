﻿
using Pandora.Module.Component.EmotionPanel;

namespace Pandora.Forms.Im
{
    partial class EmotionDropdown
    {
        /// <summary> 
        /// 必需的设计器变量。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// 清理所有正在使用的资源。
        /// </summary>
        /// <param name="disposing">如果应释放托管资源，为 true；否则为 false。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region 组件设计器生成的代码

        /// <summary> 
        /// 设计器支持所需的方法 - 不要
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            this.emotionContainer1 = new EmotionContainer();
            this.SuspendLayout();
            // 
            // emotionContainer1
            // 
            this.emotionContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.emotionContainer1.GridSize = 30;
            this.emotionContainer1.Row = 15;
            this.emotionContainer1.Columns = 9;

            //this.emotionContainer1.Size.Width = 360;

            this.emotionContainer1.Location = new System.Drawing.Point(0, 0);
            this.emotionContainer1.Name = "emotionContainer1";
            this.emotionContainer1.TabIndex = 0;
            // 
            // EmotionDropdown
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.emotionContainer1);
            this.Name = "EmotionDropdown";
            this.Size = new System.Drawing.Size(450, 270);
            this.ResumeLayout(false);

        }

        #endregion

        private EmotionContainer emotionContainer1;




    }
}
