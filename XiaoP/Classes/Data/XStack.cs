using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;

namespace XiaoP.Classes.Data
{
    class XStack
    {
        private List<string> list;
      
        public XStack()
        {
            list = new List<string>();
        }

        public void Push(string obj)
        {
            list.Add(obj);
        }

        public int Count() {
            return list.Count;
        }

        public int Count(string chatId)
        {
            int count = 0;
            foreach(string id in list){
                if (id == chatId) {
                    count++;
                }
            }

            return count;
        }

        public string Pop()
        {
            string obj = "";
            if (list.Count > 0){
                obj = list[list.Count - 1];
                Remove(obj);
                //list.RemoveAt(list.Count - 1);
            }

            return obj;
        }

        public string Top()
        {
            string obj = "";
            if (list.Count > 0)
            {
                obj = list[list.Count - 1];
            }

            return obj;
        }

        public void Remove(string value)
        {
            list.RemoveAll(x => { return x.Equals(value); });
        }
    }
}
