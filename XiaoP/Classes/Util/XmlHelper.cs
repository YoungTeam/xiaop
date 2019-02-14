using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml;
using Pandora.Module.Component;
using System.Drawing;
using System.Windows.Forms;
using System.IO;

namespace XiaoP.Classes.Util
{
    class XmlHelper
    {
        /*
        public static void RTF2Clipboard(MyExtRichTextBox richTextBox)
        {
            if (richTextBox.SelectedText == null || richTextBox.SelectedText.Length == 0)
                return;
            DataObject vDataObject = new DataObject();
            vDataObject.SetText(richTextBox.SelectedText);

            int start = richTextBox.SelectionStart, length = richTextBox.SelectedText.Length;
            string xmlStr = "<QQRichEditFormat><Info version=\"1001\"></Info>";

            bool isText = false;
            for (int i = start; i < start + length; i++)
            {

                richTextBox.Select(i, 1);
                RichTextBoxSelectionTypes rt = richTextBox.SelectionType;


                if (rt == RichTextBoxSelectionTypes.Object)
                {
                    REOBJECT reObject = new REOBJECT();
                    int objCount = richTextBox.GetRichEditOleInterface().GetObjectCount();
                    for (int n = 0; n < objCount; n++)
                    {
                        try
                        {
                            richTextBox.GetRichEditOleInterface().GetObject(n, reObject, GETOBJECTOPTIONS.REO_GETOBJ_ALL_INTERFACES);
                        }
                        catch (Exception ex)
                        {
                            PLog.Exception(ex);
                        }

                        if (reObject.dwUser != null)//如果发送的图片是自带的，则已知尺寸
                        {
                            if (isText)
                            {
                                xmlStr += "]]></EditElement>";

                            }

                            isText = false;
                            if (reObject.cp == i)
                            {
                                if (RegexHelper.IsNumber(reObject.dwUser.ToString()))
                                    xmlStr += "<EditElement type=\"2\" sysfaceindex=\"" + reObject.dwUser.ToString() + "\" filepath=\"\" shortcut=\"\"></EditElement>";
                                else
                                {
                                    PandoraPicture pic = (PandoraPicture)Marshal.GetObjectForIUnknown(reObject.poleobj);
                                    string filePath = Global.CUR_USER.profiles + "images\\" + pic.Tag + ".gif";
                                    xmlStr += "<EditElement type=\"1\" filepath=\"" + filePath + "\" shortcut=\"\" fileid=\"" + pic.Tag + "\"></EditElement>";
                                }
                            }

                        }

                    }
                }
                else
                {

                    if (isText == false)
                    {
                        xmlStr += "<EditElement type=\"0\"><![CDATA[" + richTextBox.Text[i];  //;<![CDATA[可以停薪留职]]></EditElement>";
                    }
                    else
                    {
                        xmlStr += richTextBox.Text[i];
                    }
                    if (i == start + length - 1)
                    {
                        xmlStr += "]]></EditElement>";
                    }
                    isText = true;
                    //Console.Write(richTextBox.Text[i]);

                }
            }

            xmlStr += "</QQRichEditFormat>";

            //Console.Write("====="+richTextBox.SelectedRtf.ToString()+"\n");


            //System.Windows.Forms.IDataObject = new DataObject();
            vDataObject.SetData("QQ_Unicode_RichEdit_Format", new MemoryStream(System.Text.Encoding.UTF8.GetBytes(xmlStr)));
            Clipboard.SetDataObject(vDataObject);

            richTextBox.Select(start, length);
        }

        public static void Xml2RTF(string xml, MyExtRichTextBox richTextBox)
        {

            XmlElement root = null;
            XmlDocument xmldoc = new XmlDocument();
            try
            {
                xmldoc.LoadXml(xml);
                root = xmldoc.DocumentElement;

                XmlNodeList nodeList = root.SelectNodes("/QQRichEditFormat/EditElement");

                XmlElement node;
                for (int i = 0; i < nodeList.Count; i++)
                {
                    node = (XmlElement)nodeList[i];
                    if (node.GetAttribute("type") == "0")
                    {
                        richTextBox.AppendText(node.InnerText);
                    }
                    else if (node.GetAttribute("type") == "1")
                    {

                        Guid guid = Guid.NewGuid();
                        PandoraPicture pic = new PandoraPicture();

                        pic.IsSent = true;
                        pic.Tag = guid.ToString().Replace("-", "");

                        pic.SizeMode = PictureBoxSizeMode.AutoSize;
                        pic.BackColor = richTextBox.BackColor;

                        Image img = Image.FromFile(node.GetAttribute("filepath"));
                        if (node.GetAttribute("filepath").ToLower().EndsWith(".gif"))
                        {
                            pic.Image = img;
                            pic.playGif();
                        }
                        else
                            pic.oriImg = img;

                        richTextBox.InsertMyControl(pic);

                    }
                    else if (node.GetAttribute("type") == "2")
                    {
                        //int sysfaceindex = node.GetAttribute("sysfaceindex");
                        PandoraPicture pic = new PandoraPicture();
                        pic.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize;
                        pic.BackColor = richTextBox.BackColor;
                        pic.Tag = node.GetAttribute("sysfaceindex");
                        int tag = int.Parse(pic.Tag.ToString()) - 1;
                        pic.Image = (Image)(Global.EMOTION_LIST[tag].Clone());
                        richTextBox.InsertMyControl(pic);
                        pic.playGif();

                    }
                    else if (node.GetAttribute("type") == "5")
                    {
                        Guid guid = Guid.NewGuid();
                        PandoraPicture pic = new PandoraPicture();

                        pic.IsSent = true;
                        pic.Tag = guid.ToString().Replace("-", "");
                        pic.SizeMode = PictureBoxSizeMode.AutoSize;
                        pic.BackColor = richTextBox.BackColor;

                        Image img = Image.FromFile(node.GetAttribute("filepath"));
                        pic.Image = img;
                        pic.playGif();

                        richTextBox.InsertMyControl(pic);
                    }
                    //Console.Write("\n"+node.GetAttribute("type")+"||"+node.InnerText);
                    // someBooks.Item(i).ParentNode.RemoveChild(someBooks.Item(i));
                }

            }
            catch (Exception ex)
            {
                Console.Write(ex.ToString());
            }


        }*/
    }
}
