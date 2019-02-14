using System;
using System.Collections.Generic;
using Microsoft.Win32;
using System.Diagnostics;
using System.Reflection;
using System.Collections;
using System.Runtime.InteropServices;
using Pandora.Lib;
using Newtonsoft.Json;


namespace Pandora
{
    class Program
    {
        

        static void Main(string[] args)
        {
           
           Process current = Process.GetCurrentProcess();
           Process[] processes = Process.GetProcessesByName("Pandora");

           bool isRunning = false;
           //遍历正在有相同名字运行的例程  
           foreach (Process process in processes)
           {
               //忽略现有的例程  
               if (process.Id != current.Id)
               {
                   isRunning = true;
                   break;
               }
           }


           if (isRunning) {

               sendToChatSignal(args);
           
           }
           else
           {
   
               RegistryKey RegistryKeyLM = Registry.LocalMachine;
               RegistryKey RegistryKeyPandora = RegistryKeyLM.OpenSubKey(@"Software\Microsoft\Windows\CurrentVersion\App Paths\Pandora.exe");

               try
               {
                   if (RegistryKeyPandora.GetValue("") != null)
                   {
                       sendToChatSignal(args);
                       System.Diagnostics.Process.Start(RegistryKeyPandora.GetValue("").ToString());
                   }
                   else
                       System.Diagnostics.Process.Start("http://oa.yt-inc.com/xiaop/");
               }
               catch (Exception ex)
               {


               }


           }

        }

        static void sendToChatSignal(string[] args) {

            string argsStr = "";//pandora:/f yangting /t wangliying

            foreach (string a in args)
            {
                argsStr += a;
            }

            if (argsStr == "")
                return;

            string toUserId = argsStr.Replace("pandora:", "");

            string from = INIOperation.INIGetStringValue(System.AppDomain.CurrentDomain.BaseDirectory + "\\profiles\\user\\cfg.ini", "Global", "userId", ""); ;
            string to = toUserId;

            if (from == null || from == "" || to == null || to == "")
                return;

            //发送新聊天提醒 10.13.194.187
            using (RabbitMQHelper rabbitMQ1 = new RabbitMQHelper("10.148.96.28", "notice", "pandora", "sogouorz"))
            {
                Exchange exchange = new Exchange("pandora.direct", Exchange.EXCHANGE_DIRECT);
                Hashtable chatSignal = new Hashtable();
                chatSignal.Add("type", "toChat");
                chatSignal.Add("time", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                chatSignal.Add("content", to);
                int startTime = DateTime.Now.Millisecond;

                Pandora.Lib.Queue signalQueue = new Pandora.Lib.Queue(from, true, false, false);
                rabbitMQ1.send(exchange, signalQueue, from, JsonConvert.SerializeObject(chatSignal));

            }
        
        }
    }
}
