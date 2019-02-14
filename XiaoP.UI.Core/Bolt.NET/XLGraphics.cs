using System;
using System.Runtime.InteropServices;
using System.IO;

namespace XiaoP.UI.Core.Bolt
{
    public static class XLGraphics
    {
        [StructLayout(LayoutKind.Sequential)]
        public struct tagXLGraphicPlusParam{
            public bool bInitLua;
        }

        //XLGP_LoadJpegFromStream
        [DllImport("XLUE.dll", EntryPoint = "XL_LoadBitmapFromMemory", CallingConvention = CallingConvention.StdCall)]
        public static extern IntPtr XL_LoadBitmapFromMemory([MarshalAsAttribute(UnmanagedType.LPArray)] byte[] buffer, long size, ulong colorType);

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall,CharSet = CharSet.Unicode)]
        public static extern IntPtr XL_LoadBitmapFromFile([MarshalAs(UnmanagedType.LPWStr)]string lpFileName, int colorType);

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern IntPtr XLGP_LoadGifFromFile(string lpFileName);

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern IntPtr XLGP_GifGetFrame(IntPtr hGif, int uFrameIndex);

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern IntPtr  XLGP_GifGetFirstFrame(IntPtr hGif);

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern IntPtr  XLGP_GifGetNextFrame(IntPtr hGif);

        public static IntPtr XLGP_LoadFirstGifFrame(string lpFileName)
        {
            var gif=XLGP_LoadGifFromFile(lpFileName);
            return XLGP_GifGetFirstFrame(gif);
        }

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall)]
        public static extern IntPtr XLGP_LoadJpegFromStream(IntPtr hStream);

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall,CharSet = CharSet.Unicode)]
        public static extern IntPtr XLGP_LoadJpegFromFile(string lpFileName);

        [DllImport("XLUE.dll",CallingConvention = CallingConvention.StdCall,CharSet = CharSet.Unicode)]
        public static extern IntPtr XLGP_LoadBmpFromFile(string lpFileName);

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall)]
        public static extern IntPtr XLGP_LoadOriginBmpFromStream(IntPtr hStream);
        

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall,CharSet = CharSet.Unicode)]
        public static extern IntPtr XL_LoadPngFromFile(string lpFileName);

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall)]
        public static extern int XL_ReleaseBitmap(IntPtr hBitmap);

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall)]
        public static extern bool XLGP_PushBitmap(IntPtr luaState, IntPtr hBitmap);

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall)]
        public static extern bool XLGP_PushGif(IntPtr luaState, IntPtr hGif);
        

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall)]
        public static extern bool XLGP_CheckBitmap(IntPtr luaState, int index,ref IntPtr lpBitmap);

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall)]
        public static  extern IntPtr XL_StretchBitmap(IntPtr hBitmap,int newWidth,int newHeight);

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall)]
        public static extern long XLGP_InitGraphicPlus(IntPtr theParam);


        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern bool XLGP_SaveXLBitmapToBmpFile(IntPtr hBitmap,string lpFileName,int quality);


        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern bool XLGP_SaveXLBitmapToJpegFile(IntPtr hBitmap, string lpFileName, int quality);

        [DllImport("XLUE.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern bool XLGP_SaveXLBitmapToPngFile(IntPtr hBitmap, string lpFileName, int quality);

    }
}