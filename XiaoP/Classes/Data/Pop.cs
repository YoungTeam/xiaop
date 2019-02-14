using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using XiaoP.Classes.Util;

namespace XiaoP.Classes.Data
{
    public class Pop
    {
        public Pop(Hashtable nt)
        {
            this._title = nt["title"].ToString();
            this._link = nt["link"].ToString();
        }

        private string _title;

        public string title
        {
            get { return _title; }
            set { _title = value; }
        }

        private string _link;

        public string link
        {
            get { return _link; }
            set { _link = value; }
        }

        private int _delayCancel = 0;//0 always ,-1 no pop ,>0 ...
        public int delayCancel
        {
            get {

                string noticeType = INIOperation.INIGetStringValue(Global.PANDORA_PFOFILE + "user\\cfg.ini", "Global", "noticeType", "Always");
                if (noticeType == "Never")
                    _delayCancel = -1;
                else if (noticeType == "2minutes")
                    _delayCancel = 60*2*1000;
              
                return _delayCancel; 
            
            
            }
            set { _delayCancel = value; }
        }

    }

    public class TxtPop : Pop {

        public TxtPop(Hashtable nt)
            : base(nt)
        {
            if (nt["txtTitle"] != null)
                this._txtTitle = nt["txtTitle"].ToString();
            else
                this._txtTitle = "";

            if (nt["txtContent"] != null)
                this._txtContent = nt["txtContent"].ToString();
            else
                this._txtContent = "";
        }

        private string _txtTitle;

        public string txtTitle
        {
            get { return _txtTitle; }
            set { _txtTitle = value; }
        }

        private string _txtContent;

        public string txtContent
        {
            get { return _txtContent; }
            set { _txtContent = value; }
        }

    }

    public class ImgTxtPop : TxtPop
    {

        public ImgTxtPop(Hashtable nt): base(nt)
        {
 
            if (nt["imgUrl"] != null)
                this._imgUrl = nt["imgUrl"].ToString();
            else
                this._imgUrl = "";

        }

        private string _imgUrl;

        public string imgUrl
        {
            get { return _imgUrl; }
            set { _imgUrl = value; }
        }
    
    }

    public class NovaPop : Pop
    {

        public NovaPop(Hashtable nt)
            : base(nt)
        {

            this.beginnerName = nt["beginnerName"].ToString();
            if (nt["beginnerPhone"] != null)
                this.beginnerPhone = nt["beginnerPhone"].ToString();
            else
                this.beginnerPhone = "";

            this.arriveTime = nt["arriveTime"].ToString();
            this.serialNum = nt["serialNum"].ToString();
            this.draftNo = nt["draftNo"].ToString();
            if (nt["draftId"] != null)
                this.draftId = nt["draftId"].ToString();

            this.actTitle = nt["actTitle"].ToString();
            this.propName = nt["propName"].ToString();
    
            this.entryTitle = nt["entryTitle"].ToString();
            this.handlerName = nt["handlerName"].ToString();
        
        }

        private string _beginnerName;

        public string beginnerName
        {
            get { return _beginnerName; }
            set { _beginnerName = value; }
        }


        private string _draftNo;

        public string draftNo
        {
            get { return _draftNo; }
            set { _draftNo = value; }
        }

        private string _draftId;

        public string draftId
        {
            get { return _draftId; }
            set { _draftId = value; }
        }

        private string _serialNum;

        public string serialNum
        {
            get { return _serialNum; }
            set { _serialNum = value; }
        }

        private string _entryId;

        public string entryId
        {
            get { return _entryId; }
            set { _entryId = value; }
        }


        private string _entryTitle;

        public string entryTitle
        {
            get { return _entryTitle; }
            set { _entryTitle = value.Trim(); }
        }

        private string _propName;

        public string propName
        {
            get { return _propName; }
            set { _propName = value.Trim(); }
        }

        private string _handlerName;

        public string handlerName
        {
            get { return _handlerName; }
            set { _handlerName = value; }
        }

        private string _actTitle;

        public string actTitle
        {
            get { return _actTitle; }
            set { _actTitle = value; }
        }

        private string _arriveTime;

        public string arriveTime
        {
            get { return _arriveTime; }
            set { _arriveTime = value; }
        }

        private string _beginnerPhone;

        public string beginnerPhone
        {
            get { return _beginnerPhone; }
            set { _beginnerPhone = value; }
        }
    }



}
