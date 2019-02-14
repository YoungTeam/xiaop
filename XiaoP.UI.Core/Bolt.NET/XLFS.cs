using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Linq;
using System.Text;

namespace XiaoP.UI.Core.Bolt.NET
{
    public static class XLFS
    {

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall)]
        public static extern IntPtr XLFS_CreateStreamFromMemory([MarshalAsAttribute(UnmanagedType.LPArray)] byte[] buffer, int size);

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern IntPtr XLFS_CreateStreamFromFile(string fileName, string lpMode);
    
    }
}
