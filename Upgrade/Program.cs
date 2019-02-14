using System;
using System.Collections.Generic;
using System.Windows.Forms;

namespace Upgrade
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            if (args.Length == 0)
                Application.Run(new MainForm());
            else
                Application.Run(new MainForm(args));
            /*
            if (args.Length == 0)
                Application.Run(new UpdateForm());
            else
                Application.Run(new UpdateForm(args));*/


        }
    }
}