using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using Newtonsoft.Json;
using System.Collections;
using XiaoP.Classes.Util;

namespace XiaoP.Classes.Data
{
    class ImgMsg {

        public ImgMsg() { 
        
        }

        public ImgMsg(Hashtable data) {

            if (data["id"] != null)
                this._id = data["id"].ToString();

            if (data["pos"] != null)
                this._pos = int.Parse(data["pos"].ToString());

            if (data["type"] != null)
                this._type = data["type"].ToString();

            if (data["width"] != null)
                this._width = int.Parse(data["width"].ToString());

            if (data["height"] != null)
                this._height = int.Parse(data["height"].ToString());

            if (data["from"] != null)
                this._from = data["from"].ToString();

        }

        private string _id;

        public string id
        {
            get { return _id; }
            set { _id = value; }
        }

        private int _pos;

        public int pos
        {
            get { return _pos; }
            set { _pos = value; }
        }

        private string _type="jpg";

        public string type
        {
            get { return _type; }
            set { _type = value; }
        }

        private string _from = "file";
        public string from
        {
            get { return _from; }
            set { _from = value; }
        }

        private int _width = 0;

        public int width
        {
            get { return _width; }
            set { _width = value; }
        }


        private int _height = 0;

        public int height
        {
            get { return _height; }
            set { _height = value; }
        }
    }

    class TxtMsg
    {
        //Bold|Underline|Italic
        private static int FONT_STYLE_BOLD = 1 << 2;
        private static int FONT_STYLE_UNDERLINE = 1 << 1;
        private static int FONT_STYLE_ITALIC = 1;


        private string _from;

        public string from
        {
            get { return _from; }
            set { _from = value; }
        }

        private string _to;

        public string to
        {
            get { return _to; }
            set { _to = value; }
        }

        private string _uuId;

        public string uuId
        {
            get { return _uuId; }
            set { _uuId = value; }
        }

        private string _userName;

        public string userName
        {
            get { return _userName; }
            set { _userName = value; }
        }

        private string _sendTime;

        public string sendTime
        {
            get { return _sendTime; }
            set { _sendTime = value; }
        }


        private Font _font = new Font("宋体", 9);

        public Font font
        {
            get { return _font; }
            set { _font = value; }
        }


        private Color _color = Color.FromArgb(0, 0, 0);

        public Color color
        {
            get { return _color; }
            set { _color = value; }
        }


        private string _content = "";

        public string content
        {
            get { return _content; }
            set { _content = value; }
        }

        private string _imgInfo = "";

        public string imgInfo
        {
            get { return _imgInfo; }
            set {
                _imgInfo = value; 
            
            }
        }

        private Hashtable _fmt = new Hashtable() { };
        public Hashtable fmt
        {
            get {

                Hashtable fmt = new Hashtable();
                fmt.Add("height", SystemHelper.SizeToPixelsWidth(this.font.Size));
                fmt.Add("facename", this.font.FontFamily.Name);
                fmt.Add("textcolor", this.color.ToArgb());

                if (this._font.Bold)
                    fmt.Add("weight", 700);
                else
                    fmt.Add("weight", 400);

                if (this._font.Underline)
                {
                    fmt.Add("underline", true);
                }
                else
                    fmt.Add("underline", false);

                if (this._font.Italic)
                {
                    fmt.Add("italic", true);
                }
                else
                    fmt.Add("italic", false);

                return fmt; 
            
            }
            set { _fmt = value; }
        }

        private List<ImgMsg> _imgList = new List<ImgMsg>();

        public List<ImgMsg> imgList
        {
            get
            {
                if (this._imgInfo != "")
                {
                    string[] imagePos = this._imgInfo.Split('|');

                    for (int i = 0; i < imagePos.Length - 1; i++)
                    {
                        string[] imageContent = imagePos[i].Split(',');//获得图片所在的位置、图片名称、图片宽、高
                        ImgMsg imgMsg = new ImgMsg();
                        imgMsg.pos = int.Parse(imageContent[0]);
                        imgMsg.id = imageContent[1];
                        imgMsg.width = int.Parse(imageContent[2]);
                        imgMsg.height = int.Parse(imageContent[3]);

                        this._imgList.Add(imgMsg);
                    }
                }
                return _imgList;
            }
        }




        private string _mobile;

        public string mobile
        {
            get { return _mobile; }
            set { _mobile = value; }
        }


        public TxtMsg()
        {

        }

        public TxtMsg(string data)
        {

            if (data == null || data == "")
                return;

            try
            {
                Hashtable tm = JsonConvert.DeserializeObject<Hashtable>(data);
                init(tm);


            }
            catch (Exception ex)
            {
                PLog.Exception(ex);
            }

        }

        public TxtMsg(Hashtable tm)
        {
            this.init(tm);
        }

        private void init(Hashtable tm)
        {

            if (tm == null)
                return;
            try
            {
                if (tm["from"] != null)
                    this.from = tm["from"].ToString();
                if (tm["to"] != null)
                    this.to = tm["to"].ToString();
                if (tm["userName"] != null)
                    this._userName = tm["userName"].ToString();
                if (tm["sendTime"] != null)
                    this._sendTime = tm["sendTime"].ToString();
                if (tm["uuId"] != null)
                    this._uuId = tm["uuId"].ToString();


                this._color = Color.FromArgb(int.Parse(tm["fontColor"].ToString()));

                if (tm["content"] != null)
                    this._content = tm["content"].ToString();
                else
                    this._content = "";
                if (tm["imgInfo"] != null)
                {
                    this._imgInfo = tm["imgInfo"].ToString();

                    string[] images = this._imgInfo.Split('|');

                    foreach (string imageStr in images)
                    {
                        string[] imgInfo = imageStr.Split(',');
                        ImgMsg imgMsg = new ImgMsg();

                        imgMsg.pos = int.Parse(imgInfo[0]);
                        imgMsg.id = imgInfo[1];

                        if (imgInfo.Length > 2)
                        {
                            imgMsg.width = int.Parse(imgInfo[2]);
                            imgMsg.height = int.Parse(imgInfo[3]);
                        }
                        if (imgInfo.Length > 4)
                        {
                            imgMsg.type = imgInfo[4];
                            imgMsg.from = imgInfo[5];
                        }
                        else if (RegexHelper.IsNumber(imgMsg.id))
                        {
                            imgMsg.type = "gif";
                            imgMsg.from = "emotion";
                        }

                        

                        this._imgList.Add(imgMsg);

                    }
                }

                int style = int.Parse(tm["fontStyle"].ToString());

                FontStyle fontStyle = FontStyle.Regular;
                if ((style & 4) == 4)
                {
                    fontStyle |= FontStyle.Bold;
                   
                }
                
                if ((style & 2) == 2)
                {
                    fontStyle |= FontStyle.Underline;
            
                }
                 


                if ((style & 1) == 1)
                {
                    fontStyle |= FontStyle.Italic;
                 
                }
                


                this._font = new Font(tm["fontFamily"].ToString(), float.Parse(tm["fontSize"].ToString()), fontStyle);
                if (tm.ContainsKey("mobile"))
                {
                    if (tm["mobile"] != null)
                        this._mobile = tm["mobile"].ToString();
                }


               
            }
            catch (Exception ex)
            {

                PLog.Exception(ex);
            }

        }

        public void fromXJson(string xJson) {
            Hashtable tm = JsonConvert.DeserializeObject<Hashtable>(xJson);

            if(tm["content"]!=null)
                this._content = tm["content"].ToString();

            this.imgInfo = "";
            if (tm["imgList"] != null)
            {
                Hashtable[] nt = JsonConvert.DeserializeObject<Hashtable[]>(tm["imgList"].ToString());
                foreach (Hashtable imgTable in nt)
                {
                    if (imgTable == null)
                        continue;
                    ImgMsg imgMsg = new ImgMsg(imgTable);
                    this._imgList.Add(imgMsg);
                    string info = imgMsg.pos + "," + imgMsg.id + "," + imgMsg.width + "," + imgMsg.height + "," + imgMsg.type + "," + imgMsg.from;
                    this.imgInfo += info + "|";
                } 
            }
        }

        public string toXJson() {

            Hashtable txtMsg = new Hashtable();

            txtMsg.Add("uuId", this._uuId);
            txtMsg.Add("from", this._from);
            txtMsg.Add("to", this._to);
            txtMsg.Add("userName", this._userName);
            txtMsg.Add("sendTime", this._sendTime);
            txtMsg.Add("content", this._content);
            txtMsg.Add("imgList", this._imgList);

            Hashtable fmt = new Hashtable();
            fmt.Add("height", SystemHelper.SizeToPixelsWidth(this.font.Size));
            fmt.Add("facename", this.font.FontFamily.Name);
            fmt.Add("textcolor", this.color.ToArgb());

            if (this._font.Bold)
                fmt.Add("weight", 700);
            else
                fmt.Add("weight", 400);

            if (this._font.Underline) {
                fmt.Add("underline", true);
            }else
                fmt.Add("underline", false);

            if (this._font.Italic) {
                fmt.Add("italic", true);
            }else
                fmt.Add("italic", false);


            txtMsg.Add("fmt", fmt);
            
            string json = "";
            try
            {
                json = JsonConvert.SerializeObject(txtMsg);
            }
            catch (Exception ex)
            {
                PLog.Exception(ex);
            }

            return json;
        
        }


        public string toJson()
        {

            int style = 0;
            if (this._font.Bold)
                style |= FONT_STYLE_BOLD;
            if (this._font.Underline)
                style |= FONT_STYLE_UNDERLINE;
            if (this._font.Italic)
                style |= FONT_STYLE_ITALIC;

            Hashtable txtMsg = new Hashtable();

            txtMsg.Add("uuId", this._uuId);
            txtMsg.Add("from", this._from);
            txtMsg.Add("to", this._to);
            txtMsg.Add("userName", this._userName);
            txtMsg.Add("sendTime", this._sendTime);

            txtMsg.Add("fontFamily", this._font.FontFamily.Name);
            txtMsg.Add("fontSize", this._font.Size);
            txtMsg.Add("fontColor", this._color.ToArgb());//this._color.A+","+this._color.R+","+this._color.G+","+this._color.B);
            txtMsg.Add("fontStyle", style);

            txtMsg.Add("content", this._content);
            txtMsg.Add("imgInfo", this._imgInfo);
            txtMsg.Add("mobile", this._mobile);

            string json = "";
            try
            {
                json = JsonConvert.SerializeObject(txtMsg);
            }
            catch (Exception ex)
            {
                PLog.Exception(ex);
            }

            return json;
        }

        public string toBase64()
        {

            byte[] bytes = Encoding.UTF8.GetBytes(this.toJson());
            return Convert.ToBase64String(bytes);

        }
	

    }
}
