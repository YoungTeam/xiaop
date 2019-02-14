using System;
using System.Collections.Generic;
using System.Text;

namespace Pandora.Lib
{
    public class Exchange
    {
        public static String EXCHANGE_FANOUT = "fanout";
        public static String EXCHANGE_DIRECT = "direct";
        public static String EXCHANGE_TOPIC = "topic";

        public Exchange() {
            this._name = "";
            this._type = EXCHANGE_FANOUT;
            this._durable = true;
            this._autoDelete = false;
        }

        public Exchange(string name, string type) {
            this._name = name;
            this._type = type;
            this._durable = false;
            this._autoDelete = false;
        }

        public Exchange(string name, string type,bool durable,bool autoDelete)
        {
            this._name = name;
            this._type = type;
            this._durable = durable;
            this._autoDelete = autoDelete;
        }

        private string _name;

        public string name
        {
            get { return _name; }
            set { _name = value; }
        }

        private string _type;

        public string type
        {
            get { return _type; }
            set { _type = value; }
        }

        private bool _durable;

        public bool durable
        {
            get { return _durable; }
            set { _durable = value; }
        }

        private bool _autoDelete;

        public bool autoDelete
        {
            get { return _autoDelete; }
            set { _autoDelete = value; }
        }
	
    }
}
