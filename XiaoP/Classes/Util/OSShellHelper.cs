using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.Drawing;
namespace XiaoP.Classes.Util
{
    class OSShellHelper
    {
        [DllImport("user32.dll")]
        static extern bool OpenClipboard(IntPtr hWndNewOwner);
        [DllImport("user32.dll")]
        static extern bool EmptyClipboard();
        [DllImport("user32.dll")]
        static extern IntPtr SetClipboardData(uint uFormat, IntPtr hMem);
        [DllImport("user32.dll")]
        static extern IntPtr GetClipboardData(uint uFormat);
        [DllImport("user32.dll")]
        static extern bool IsClipboardFormatAvailable(uint uFormat);
        [DllImport("user32.dll")]
        static extern bool CloseClipboard();
        [DllImport("gdi32.dll")]
        static extern IntPtr CopyEnhMetaFile(IntPtr hemfSrc, IntPtr hNULL);
        [DllImport("gdi32.dll")]
        static extern IntPtr CopyEnhMetaFileA(IntPtr hemfSrc, string filename);
        [DllImport("gdi32.dll")]
        static extern bool DeleteEnhMetaFile(IntPtr hemf);        // Metafile mf is set to a state that is not valid inside this function.


        [DllImport("user32.dll")]
        // GetCursorPos() makes everything possible
        static extern bool GetCursorPos(ref Point lpPoint);

        /*
        static public bool PutEnhMetafileOnClipboard(IntPtr hWnd, Metafile mf)
        {
            bool bResult = false;
            IntPtr hEMF, hEMF2;
            hEMF = mf.GetHenhmetafile(); // invalidates mf
            if (!hEMF.Equals(new IntPtr(0)))
            {
                hEMF2 = CopyEnhMetaFile(hEMF, new IntPtr(0));
                if (!hEMF2.Equals(new IntPtr(0)))
                {
                    if (OpenClipboard(hWnd))
                    {
                        if (EmptyClipboard())
                        {
                            IntPtr hRes = SetClipboardData(14 , hEMF2);
                            bResult = hRes.Equals(hEMF2);
                            CloseClipboard();
                        }
                    }
                }
                DeleteEnhMetaFile(hEMF);
            }
            return bResult;
        }
        static public Metafile GetEnhMetafileOnClipboard(IntPtr hWnd)
        {
            if (OpenClipboard(hWnd))
            {
                uint format = 14; //CF_ENHMETAFILE;
                if (IsClipboardFormatAvailable(format))
                {
                    IntPtr hRes = GetClipboardData(format); CloseClipboard(); if (!hRes.Equals(new IntPtr(0)))
                    {
                        IntPtr hEMF = CopyEnhMetaFile(hRes, new IntPtr(0));
                        Metafile mf = new Metafile(hEMF, true);
                        return mf;
                    }
                }
            }
            return null;
        }*/

        
        static public bool checkClipboardFormatAvailable(int format,IntPtr hWnd)
        {
            
            if (OpenClipboard(hWnd))
            {
                
                if (IsClipboardFormatAvailable((uint)format))
                {
                    CloseClipboard();
                    return true;
                }
            }

            CloseClipboard();
            return false;
        }

        public static Point getCursorPos() {
            Point p = new Point();
            GetCursorPos(ref p);

            return p;
        }

       
         [DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
        private static extern int SystemParametersInfo(int uAction, int uParam, ref Rectangle lpvParam, int fuWinIni);

        [DllImport("user32")]
        public static extern int GetSystemMetrics(int nIndex);
        
        public static Rectangle getWorkArea()
        {
            Rectangle rWorkArea = new Rectangle();
            SystemParametersInfo(API.SPI_GETWORKAREA, Marshal.SizeOf(rWorkArea), ref rWorkArea, 0);            
            return new Rectangle(rWorkArea.Left, rWorkArea.Top, rWorkArea.Right - rWorkArea.Left, rWorkArea.Bottom - rWorkArea.Top);
        }

        public static Rectangle getScreenArea() {
            int cx = GetSystemMetrics(API.SM_CXSCREEN);
            int cy = GetSystemMetrics(API.SM_CYSCREEN);

            return new Rectangle(0, 0, cx, cy);
        }

    }
}
