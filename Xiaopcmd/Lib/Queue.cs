using System;
using System.Collections.Generic;
using System.Text;

namespace Pandora.Lib
{
    public class Queue
    {
        public Queue() {
            this._name = "";
            this._durable = false;
            this._exclusive = false;
            this._autoDelete = true;
        }

        public Queue(string name, bool durable, bool exclusive,bool autoDelete) {
            this._name = name;
            this._durable = durable;
            this._exclusive = exclusive;
            this._autoDelete = autoDelete;
        }

        private string _name;

        public string name
        {
            get { return _name; }
            set { _name = value; }
        }

        private bool _durable;

        public bool durable
        {
            get { return _durable; }
            set { _durable = value; }
        }

        private bool _exclusive;

        public bool exclusive
        {
            get { return _exclusive; }
            set { _exclusive = value; }
        }

        private bool _autoDelete;

        public bool autoDelete
        {
            get { return _autoDelete; }
            set { _autoDelete = value; }
        }
	
    }
}
