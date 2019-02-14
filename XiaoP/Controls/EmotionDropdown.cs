using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Text;
using System.Windows.Forms;
using Pandora.Module.Component.EmotionPanel;

namespace Pandora.Forms.Im
{
    public partial class EmotionDropdown : UserControl
    {
        private Popup _popup;

        public EmotionDropdown()
        {
            InitializeComponent();
            _popup = new Popup(this);

            EmotionContainer.ItemClick += 
                new EmotionItemMouseEventHandler(EmotionContainerItemClick);
        }

        void EmotionContainerItemClick(
            object sender, EmotionItemMouseClickEventArgs e)
        {
            _popup.Close();
        }

        public EmotionContainer EmotionContainer
        {
            get { return emotionContainer1; }
        }

        public void Show(Point point)
        {
            _popup.Show(point);//.Show(owner, owner.Location.X -emotionContainer1.Width +100 , owner.Location.Y - emotionContainer1.Height - 5);
        }
    }
}
