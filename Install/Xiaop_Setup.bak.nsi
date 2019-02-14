;7Z打开空白
!system '>blank set/p=MSCF<nul'
!packhdr temp.dat 'cmd /c Copy /b temp.dat /b +blank&&del blank'

Var MSG     ;MSG变量必须定义，而且在最前面，否则WndProc::onCallback不工作，插件中需要这个消息变量,用于记录消息信息
Var Dialog  ;Dialog变量也需要定义，他可能是NSIS默认的对话框变量用于保存窗体中控件的信息

Var BGImage  ;背景大图
Var MiddleImage
Var ImageHandle
Var BCSJ

Var WarningForm

Var Txt_Browser

Var CheckShortCut
Var CheckShortCut_Lable
Var CheckShortCut_State

Var CheckAutoStart
Var CheckAutoStart_Lable
Var CheckAutoStart_State

;---------------------------全局编译脚本预定义的常量-----------------------------------------------------
!define PRODUCT_NAME "Pandora 助手"
!define PRODUCT_DIR "Pandora"
!define PRODUCT_VERSION "4.0.0.0"
!define PRODUCT_PUBLISHER "yt-OP OP-INFO"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\Pandora.exe" ;请自行修改
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\Pandora"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"


VIProductVersion "${PRODUCT_VERSION}"
VIAddVersionKey /LANG=2052  "ProductName" "${PRODUCT_NAME}"   ;产品名称
;VIAddVersionKey /LANG=2052  "Comments" "NSIS图文教程集锦 By 大白菜"  ;备注
VIAddVersionKey /LANG=2052  "CompanyName" "${PRODUCT_PUBLISHER}"   ;公司
VIAddVersionKey /LANG=2052  "Pandora" "oa.yt-inc.com"   ;WEB
VIAddVersionKey /LANG=2052  "LegalTrademarks" "OP-INFO"
VIAddVersionKey /LANG=2052  "LegalCopyright" "(C) 2014 oa.yt-inc.com YoungTeam" ;版权
VIAddVersionKey /LANG=2052  "FileDescription" "Pandora Assist" ;描述
VIAddVersionKey /LANG=2052  "FileVersion" "${PRODUCT_VERSION}"


ShowInstDetails nevershow ;设置是否显示安装详细信息。
ShowUnInstDetails nevershow ;设置是否显示删除详细信息。

;应用程序显示名字
Name "Pandora_${PRODUCT_VERSION}"
;应用程序输出文件名
OutFile "Pandora_${PRODUCT_VERSION}.exe"
;默认安装目录
InstallDir "$PROGRAMFILES\${PRODUCT_DIR}"
InstallDirRegKey HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"

; MUI 预定义常量
;!define MUI_ABORTWARNING ;退出提示
;安装图标的路径名字
!define MUI_ICON "Icon\Xiaop Setup.ico"
;卸载图标的路径名字
!define MUI_UNICON "Icon\unst.ico"
;使用的UI
!define MUI_UI "UI\mod.exe"

;!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP

;---------------------------设置软件压缩类型（也可以通过外面编译脚本控制）------------------------------------
SetCompressor lzma
SetCompress force
XPStyle on
; ------ MUI 现代界面定义 (1.67 版本以上兼容) ------
!include "MUI2.nsh"
!include "WinCore.nsh"
!include "nsWindows.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"
!include "x64.nsh"
;!include "LoadRTF.nsh"

!define MUI_CUSTOMFUNCTION_GUIINIT onGUIInit

;自定义页面
Page custom Page.1

Page custom Page.2 Page.2leave
; 许可协议页面
;!define MUI_LICENSEPAGE_CHECKBOX

; 安装目录选择页面

;!insertmacro MUI_PAGE_DIRECTORY
; 安装过程页面
;!define MUI_PAGE_CUSTOMFUNCTION_PRO InstFilesPagePRO
!define MUI_PAGE_CUSTOMFUNCTION_SHOW InstFilesPageShow
!insertmacro MUI_PAGE_INSTFILES

Page custom Page.3

Page custom Page.4
; 安装完成页面
;!insertmacro MUI_PAGE_FINISH
; 安装卸载过程页面
UninstPage custom un.Page.5

UninstPage instfiles un.InstFiles.PRO un.InstFiles.Show

UninstPage custom un.Page.6

UninstPage custom un.Page.7


; 安装界面包含的语言设置
!insertmacro MUI_LANGUAGE "SimpChinese"
RequestExecutionLevel admin
;------------------------------------------------------MUI 现代界面定义以及函数结束------------------------

Function .onInit
    InitPluginsDir

    StrCpy $CheckShortCut_State ${BST_CHECKED}
    StrCpy $CheckAutoStart_State ${BST_CHECKED}
    

    File `/ONAME=$PLUGINSDIR\bg.bmp` `images\welcome_bg.bmp`
    File `/ONAME=$PLUGINSDIR\select.bmp` `images\select_bg.bmp`
    File `/oname=$PLUGINSDIR\installation.bmp` `images\installation_bg.bmp`
    File `/oname=$PLUGINSDIR\success.bmp` `images\success_bg.bmp`
    File `/ONAME=$PLUGINSDIR\quit.bmp` `images\quit.bmp`
    File `/ONAME=$PLUGINSDIR\welcome.bmp` `images\welcome.bmp`
    File `/ONAME=$PLUGINSDIR\btn_next.bmp` `images\btn_next.bmp`  
    File `/oname=$PLUGINSDIR\btn_close.bmp` `images\btn_close.bmp`
    File `/oname=$PLUGINSDIR\btn_cancel.bmp` `images\btn_cancel.bmp`
    File `/oname=$PLUGINSDIR\btn_quit.bmp` `images\btn_quit.bmp`

    File `/oname=$PLUGINSDIR\btn_agreement1.bmp` `images\btn_agreement1.bmp`
    File `/oname=$PLUGINSDIR\btn_agreement2.bmp` `images\btn_agreement2.bmp`
    File `/oname=$PLUGINSDIR\license.rtf` `license\license.rtf`
    File `/oname=$PLUGINSDIR\btn_install.bmp` `images\btn_install.bmp`
    File `/oname=$PLUGINSDIR\btn_change.bmp` `images\btn_change.bmp`

    File `/oname=$PLUGINSDIR\btn_complete.bmp` `images\btn_complete.bmp`

    SkinBtn::Init "$PLUGINSDIR\btn_next.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_close.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_cancel.bmp" 
    SkinBtn::Init "$PLUGINSDIR\btn_quit.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_agreement1.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_agreement2.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_install.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_change.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_complete.bmp"

    ;进度条皮肤
    File `/oname=$PLUGINSDIR\Progress.bmp` `images\Progress.bmp`
    File `/oname=$PLUGINSDIR\ProgressBar.bmp` `images\ProgressBar.bmp`


FunctionEnd

Function onGUIInit

    ;消除边框
    System::Call `user32::SetWindowLong(i$HWNDPARENT,i${GWL_STYLE},0x9480084C)i.R0`
    ;隐藏一些既有控件
    GetDlgItem $0 $HWNDPARENT 1034
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1035
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1036
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1037
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1038    
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1039
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1256
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1028
    ShowWindow $0 ${SW_HIDE}

    ${NSW_SetWindowSize} $HWNDPARENT 514 355 ;改变主窗体大小
    System::Call User32::GetDesktopWindow()i.R0
    ;圆角
    System::Alloc 16
  	System::Call user32::GetWindowRect(i$HWNDPARENT,isR0)
  	System::Call *$R0(i.R1,i.R2,i.R3,i.R4)
  	IntOp $R3 $R3 - $R1
  	IntOp $R4 $R4 - $R2
  	System::Call gdi32::CreateRoundRectRgn(i0,i0,iR3,iR4,i4,i4)i.r0
  	System::Call user32::SetWindowRgn(i$HWNDPARENT,ir0,i1)
  	System::Free $R0
	;Call UninstallSoft
FunctionEnd

;处理无边框移动
Function onGUICallback
  ${If} $MSG = ${WM_LBUTTONDOWN}
    SendMessage $HWNDPARENT ${WM_NCLBUTTONDOWN} ${HTCAPTION} $0
  ${EndIf}
FunctionEnd
;弹出对话框移动
Function onWarningGUICallback
  ${If} $MSG = ${WM_LBUTTONDOWN}
    SendMessage $WarningForm ${WM_NCLBUTTONDOWN} ${HTCAPTION} $0
  ${EndIf}
FunctionEnd


Function Page.1

    GetDlgItem $0 $HWNDPARENT 1
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 2
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 3
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1990
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1991
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1992
    ShowWindow $0 ${SW_HIDE}
    
    nsDialogs::Create 1044
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}
    SetCtlColors $0 ""  transparent ;背景设成透明

    ${NSW_SetWindowSize} $0 514 355 ;改变Page大小

   ;下一步
    ${NSD_CreateButton} 320 315 88 25 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_next.bmp $0
    GetFunctionAddress $3 onClickNext
    SkinBtn::onClick $0 $3
   
    ;取消
    ${NSD_CreateButton} 417 315 88 25 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_cancel.bmp $0
    GetFunctionAddress $3 onCancel
    SkinBtn::onClick $0 $3

   ;关闭按钮
    ${NSD_CreateButton}} 490 8 15 15 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_close.bmp $0
    GetFunctionAddress $3 onCancel
    SkinBtn::onClick $0 $3
 
   ;贴小图
    ${NSD_CreateBitmap} 1 31 511 226 ""
    Pop $MiddleImage
    ${NSD_SetImage} $MiddleImage $PLUGINSDIR\welcome.bmp $ImageHandle
    ;ShowWindow $MiddleImage ${SW_HIDE}
 
    ;贴背景大图
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\bg.bmp $ImageHandle

    GetFunctionAddress $0 onGUICallback
    WndProc::onCallback $BGImage $0 ;处理无边框窗体移动
    nsDialogs::Show
    ${NSD_FreeImage} $ImageHandle
FunctionEnd

Function Page.2

    GetDlgItem $0 $HWNDPARENT 1
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 2
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 3
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1990
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1991
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1992
    ShowWindow $0 ${SW_HIDE}
    nsDialogs::Create 1044
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}
    SetCtlColors $0 ""  transparent ;背景设成透明
    ${NSW_SetWindowSize} $0 514 355 ;改变Page大小

    ;更改目录控件创建
    ${NSD_CreateDirRequest} 28 78 353 20 "$INSTDIR"
    Pop	$Txt_Browser
    ${NSD_OnChange} $Txt_Browser OnChange_DirRequest

    ${NSD_CreateBrowseButton} 400 75 88 25 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_change.bmp $0
    GetFunctionAddress $3 OnClick_BrowseButton
    SkinBtn::onClick $0 $3

    ${NSD_CreateCheckbox} 36 130u 12u 12u ""
    Pop $CheckShortCut
    SetCtlColors $CheckShortCut "" "f7f7f7"
    ${NSD_SetState} $CheckShortCut ${BST_CHECKED}

    ${NSD_CreateLabel} 36u 131u 100u 12u "添加桌面快捷方式"
    Pop $CheckShortCut_Lable
    SetCtlColors $CheckShortCut_Lable ""  transparent ;前景色,背景设成透明
    ${NSD_OnClick} $CheckShortCut_Lable onCheckShortCut

    ${NSD_CreateCheckbox} 36 150u 12u 12u ""
    Pop $CheckAutoStart
    SetCtlColors $CheckAutoStart "" "f7f7f7"
    ${NSD_SetState} $CheckAutoStart ${BST_CHECKED}

    ${NSD_CreateLabel} 36u 151u 100u 12u "开机自动运行程序"
    Pop $CheckAutoStart_Lable
    SetCtlColors $CheckAutoStart_Lable ""  transparent ;前景色,背景设成透明
    ${NSD_OnClick} $CheckAutoStart_Lable onCheckAutoStart

    ;安装
    ${NSD_CreateButton} 320 315 88 25 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_install.bmp $0
    GetFunctionAddress $3 OnClick_Install
    SkinBtn::onClick $0 $3


    ;取消
    ${NSD_CreateButton} 417 315 88 25 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_cancel.bmp $0
    GetFunctionAddress $3 onCancel
    SkinBtn::onClick $0 $3

   ;关闭按钮
    ${NSD_CreateButton}} 490 8 15 15 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_close.bmp $0
    GetFunctionAddress $3 onCancel
    SkinBtn::onClick $0 $3

    ;贴背景大图
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\select.bmp $ImageHandle

    GetFunctionAddress $0 onGUICallback
    WndProc::onCallback $BGImage $0 ;处理无边框窗体移动
    nsDialogs::Show
    ${NSD_FreeImage} $ImageHandle
 
FunctionEnd

#----------------------------------------------
#存储4个选项状态
#----------------------------------------------
Function Page.2leave
   ${NSD_GetState} $CheckShortCut $CheckShortCut_State
   ${NSD_GetState} $CheckAutoStart $CheckAutoStart_State
FunctionEnd
#----------------------------------------------
#第2个页面完成
#----------------------------------------------


Function  InstFilesPageShow

    FindWindow $R2 "#32770" "" $HWNDPARENT
    GetDlgItem $0 $HWNDPARENT 1
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 2
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 3
    
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $1 $R2 1027
    ShowWindow $1 ${SW_HIDE}


  File '/oname=$PLUGINSDIR\Slides.dat' 'nsisSlideShow\Slides.dat'
  File '/oname=$PLUGINSDIR\Play1.png' 'nsisSlideShow\Play1.png'
  File '/oname=$PLUGINSDIR\Play2.png' 'nsisSlideShow\Play2.png'
  File '/oname=$PLUGINSDIR\Play3.png' 'nsisSlideShow\Play3.png'
		;自定义进度条的颜色样式
		;取消进度条windows 样式主题风格，改为用自已定义的颜色
;		GetDlgItem $2 $R2 1004
;		System::Call UxTheme::SetWindowTheme(i,w,w)i(r2, n, n)
		;SendMessage $2 ${PBM_SETBARCOLOR} 0 0x339a00 ;设置进度条前景色
		;SendMessage $2 ${PBM_SETBKCOLOR} 0 0xa4a4a4  ;设置进度条背景色

    GetDlgItem $R0 $R2 1004  ;设置进度条位置
    System::Call "user32::MoveWindow(i R0, i 30, i 100, i 440, i 12) i r2"


    StrCpy $R0 $R2 ;改变页面大小,不然贴图不能全页
    System::Call "user32::MoveWindow(i R0, i 0, i 0, i 514, i 355) i r2"
    GetFunctionAddress $0 onGUICallback
    WndProc::onCallback $R0 $0 ;处理无边框窗体移动
    
    GetDlgItem $R1 $R2 1006  ;获取1006控件设置颜色并改变位置
    SetCtlColors $R1 ""  F6F6F6 ;背景设成F6F6F6,注意颜色不能设为透明，否则重叠
    System::Call "user32::MoveWindow(i R1, i 30, i 82, i 440, i 12) i r2"

    GetDlgItem $R3 $R2 1990  ;获取1006控件设置颜色并改变位置
    System::Call "user32::MoveWindow(i R3, i 416, i 315, i 88, i 25) i r2"
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_cancel.bmp $R3
    GetFunctionAddress $3 onCancel
    SkinBtn::onClick $R3 $3
    ShowWindow $R3 ${SW_HIDE}
    ;SetCtlColors $R1 ""  F6F6F6 ;背景设成F6F6F6,注意颜色不能设为透明，否则重叠

    GetDlgItem $R4 $R2 1991  ;获取1006控件设置颜色并改变位置
    System::Call "user32::MoveWindow(i R4, i 490, i 8, i 15, i 15) i r2" ;改变位置465, 1, 31, 18
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_close.bmp $R4
    GetFunctionAddress $3 onCancel
    SkinBtn::onClick $R4 $3
    EnableWindow $R4 0  ;禁止0为禁止
    
    GetDlgItem $R5 $R2 1992  ;获取1006控件设置颜色并改变位置
    System::Call "user32::MoveWindow(i R5, i 416, i 339, i 72, i 24) i r2"
    ${NSD_SetText} $R5 "安装"
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $R5
    ;GetFunctionAddress $3 onClickins
    SkinBtn::onClick $R5 $3
    ShowWindow $R5 ${SW_HIDE}
    ;EnableWindow $R5 0

    ;GetDlgItem $R6 $R2 1992  ;获取1006控件设置颜色并改变位置
    ;System::Call "user32::MoveWindow(i R6, i 320, i 315, i 88, i 25) i r2"
    ;SkinBtn::Set /IMGID=$PLUGINSDIR\btn_next.bmp $R6
    ;GetFunctionAddress $3 onClickins
    ;SkinBtn::onClick $R6 $3
    ;EnableWindow $R6 0

    ;GetDlgItem $R7 $R2 1993  ;获取1993控件设置颜色并改变位置
    ;SetCtlColors $R7 "666666"  transparent ;
    ;System::Call "user32::MoveWindow(i R7, i 38, i 12, i 150, i 12) i r2"
    ;${NSD_SetText} $R7 "${PRODUCT_NAME} 安装" ;设置某个控件的 text 文本


    GetDlgItem $R8 $R2 1016  ;获取1006控件设置颜色并改变位置
    SetCtlColors $R8 ""  F6F6F6 ;背景设成F6F6F6,注意颜色不能设为透明，否则重叠
    System::Call "user32::MoveWindow(i R8, i 30, i 120, i 440, i 180) i r2"
    
    FindWindow $R2 "#32770" "" $HWNDPARENT
    GetDlgItem $R0 $R2 1995
    System::Call "user32::MoveWindow(i R0, i 0, i 0, i 514, i 355) i r2"
    ${NSD_SetImage} $R0 $PLUGINSDIR\installation.bmp $ImageHandle

    ;这里是给进度条贴图
    FindWindow $R2 "#32770" "" $HWNDPARENT
    GetDlgItem $5 $R2 1004
    SkinProgress::Set $5 "$PLUGINSDIR\Progress.bmp" "$PLUGINSDIR\ProgressBar.bmp"

FunctionEnd

Function Page.3

    GetDlgItem $0 $HWNDPARENT 1
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 2
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 3
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1990
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1991
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1992
    ShowWindow $0 ${SW_HIDE}
    
    nsDialogs::Create 1044
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}
    SetCtlColors $0 ""  transparent ;背景设成透明

    ${NSW_SetWindowSize} $0 514 355 ;改变Page大小

  
   ;关闭按钮
    ${NSD_CreateButton}} 490 8 15 15 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_close.bmp $0
    GetFunctionAddress $3 onCancel
    SkinBtn::onClick $0 $3
 
   ;完成
    ${NSD_CreateButton} 417 315 88 25 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_complete.bmp $0 
    GetFunctionAddress $3 onClickComplete
    SkinBtn::onClick $0 $3

    ;贴背景大图
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\success.bmp $ImageHandle

    GetFunctionAddress $0 onGUICallback
    WndProc::onCallback $BGImage $0 ;处理无边框窗体移动
    nsDialogs::Show
    ${NSD_FreeImage} $ImageHandle

FunctionEnd


Function Page.4

FunctionEnd



Function onCancel
    IsWindow $WarningForm Create_End

    ;消除边框
    System::Call `user32::SetWindowLong(i$HWNDPARENT,i${GWL_STYLE},0x9480084C)i.R0`
    ;隐藏一些既有控件
    GetDlgItem $0 $HWNDPARENT 1034
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1035
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1036
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1037
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1038
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1039
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1256
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1028
    ShowWindow $0 ${SW_HIDE}

	!define Style ${WS_VISIBLE}|${WS_OVERLAPPEDWINDOW}
	${NSW_CreateWindowEx} $WarningForm $hwndparent ${ExStyle} ${Style} "" 1018

	System::Call "user32::MoveWindow(i $WarningForm, i 0, i 0, i 349, i 184) i r2"
	;${NSW_SetWindowSize} $WarningForm 349 184
	EnableWindow $hwndparent 0
	System::Call `user32::SetWindowLong(i$WarningForm,i${GWL_STYLE},0x9480084C)i.R0`

	${NSW_CreateButton} 78 132 88 25 ''
	Pop $1
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_quit.bmp $1
	GetFunctionAddress $3 OnClickQuitOK
        SkinBtn::onClick $1 $3

	${NSW_CreateButton} 178 132 88 25 ''
	Pop $1
        SkinBtn::Set /IMGID=$PLUGINSDIR\btn_cancel.bmp $1
 	GetFunctionAddress $3 OnClickQuitCancel
        SkinBtn::onClick $1 $3
	
        ${NSW_CreateBitmap} 0 0 100% 100% ""
  	Pop $BGImage
  	${NSW_SetImage} $BGImage $PLUGINSDIR\quit.bmp $ImageHandle
	GetFunctionAddress $0 onWarningGUICallback
	WndProc::onCallback $BGImage $0 ;处理无边框窗体移动
  	${NSW_CenterWindow} $WarningForm $hwndparent
	${NSW_Show}
	Create_End:
  	ShowWindow $WarningForm ${SW_SHOW}
FunctionEnd


;更改目录事件
Function OnChange_DirRequest
	${NSD_GetText} $Txt_Browser  $0
	StrCpy $INSTDIR $0
FunctionEnd

Function OnClick_BrowseButton
  Pop $0

  Push $INSTDIR ; input string "C:\Program Files\ProgramName"
  Call GetParent
  Pop $R0 ; first part "C:\Program Files"

  Push $INSTDIR ; input string "C:\Program Files\ProgramName"
  Push "\" ; input chop char
  Call GetLastPart
  Pop $R1 ; last part "ProgramName"Var Lbl_Sumary

  nsDialogs::SelectFolderDialog "请选择 $R0 安装的文件夹:" "$R0"
  Pop $0
  ${If} $0 == "error" # returns 'error' if 'cancel' was pressed?
    Return
  ${EndIf}
  ${If} $0 != ""
    StrCpy $INSTDIR "$0\$R1"
    system::Call `user32::SetWindowText(i $Txt_Browser, t "$INSTDIR")`
  ${EndIf}
FunctionEnd

Section MainSetup
SetDetailsPrint textonly
DetailPrint "正在安装${PRODUCT_NAME}..."
SetDetailsPrint None ;不显示信息
nsisSlideshow::Show /NOUNLOAD /auto=$PLUGINSDIR\Slides.dat
 

    Push $R0
    CheckProc:
	Push "Pandora.exe"
	ProcessWork::existsprocess
	Pop $R0
	IntCmp $R0 0 Done
	;MessageBox MB_OKCANCEL|MB_ICONSTOP "安装程序检测到 XiaoP 正在运行，请退出程序后重试。$\r$\n点击“确定”立即结束进程，点击“取消”退出。" IDCANCEL Exit
	Push "Pandora.exe"
	ProcessWork::KillProcess
	Sleep 1000
	Goto CheckProc
	Done:
	Pop $R0

  Call UninstallSoft
  sleep 1500

  SetShellVarContext all
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  File "..\XiaoP\bin\Release\XLUE.dll"
  File "..\XiaoP\bin\Release\XiaoP.UI.Core.dll"
  File "..\XiaoP\bin\Release\RabbitMQ.Client.dll"
  File "..\XiaoP\bin\Release\ImgView.dll"
  File "..\XiaoP\bin\Release\CaptureTool.dll"
  File "..\XiaoP\bin\Release\XiaoP.exe"
  File "..\XiaoP\bin\Release\Newtonsoft.Json.dll"
  ;File "..\Pandora\bin\Release\conf.config"
  ;File "..\Upgrade\bin\Release\Upgrade.exe"
  ;File "..\Xiaopcmd\bin\Release\xiaopcmd.exe"
  CreateDirectory "$INSTDIR\update"
  CreateDirectory "$INSTDIR\sounds"
  ;CreateDirectory "$DOCUMENTS\Pandora\userLogo"
  CreateDirectory "$INSTDIR\profiles\system\userLogo"
  	
  sleep 1000
  SetOutPath "$INSTDIR\sounds"
  File "..\XiaoP\bin\Release\sounds\*"
  CreateDirectory "$INSTDIR\profiles\system\emotion\default"
  SetOutPath "$INSTDIR\profiles\system\emotion\default"
  File "..\XiaoP\bin\Release\profiles\system\emotion\default\*"

  sleep 1000
  CreateDirectory "$INSTDIR\xar\XAR"
  SetOutPath "$INSTDIR\xar\XAR"
  File "..\XiaoP\bin\Release\xar\XAR\*.xar"


   SetOutPath "$INSTDIR"
   ;判断是否添加桌面快捷方式
   ${If} $CheckShortCut_State == 1
      CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\Pandora.exe"
   ${EndIf}
   
   sleep 1000
  ;${NSD_GetState} $Checkbox1_State $0
    ;${If} $Checkbox1_itate == 1
    ;DetailPrint "选中"
    ;MessageBox MB_OK '选中'
    ;${EndIf}
;MessageBox MB_OK '选中项:$\r$\n$Checkbox1_State$\r$\n$Checkbox2_State$\r$\n$Checkbox3_State$\r$\n$Checkbox4_State$\r$\n安装目录：$INSTDIR'
nsisSlideshow::Stop

IfSilent 0 +2
 Exec "$INSTDIR\XiaoP.exe"
 ;ExecShell "open" "http://item.taobao.com/item.htm?id=20321929386"
 SetAutoClose true 
SectionEnd

Section -AdditionalIcons
  SetShellVarContext all
  SetOutPath "$INSTDIR"
  ;!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  CreateDirectory "$SMPROGRAMS\Pandora"
  CreateShortCut "$SMPROGRAMS\Pandora\${PRODUCT_NAME}.lnk" "$INSTDIR\XiaoP.exe"
  ;CreateShortCut "$DESKTOP\Pandora.lnk" "$INSTDIR\Pandora.exe"
  #WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  #CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\Pandora\卸载${PRODUCT_NAME}.lnk" "$INSTDIR\uninst.exe"
  ;!insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

#----------------------------------------------
#创建控制面板卸载程序信息 ,下面的具体用法卡查看帮助  D.2 添加卸载信息到添加/删除程序面板  或者在帮助里搜索关键词，如：DisplayName
#----------------------------------------------
Section -Post
   DeleteRegValue HKLM "Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" "Pandora"
   ${If} ${RunningX64}
   SetRegView 64
   ;${Else}
    ;  MessageBox MB_OK "running on x86"
   ${EndIf}
   DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "XiaoP"
   DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "Pandora"
   Delete "$QUICKLAUNCH\${PRODUCT_NAME}.lnk"
   Delete "$SMSTARTUP\${PRODUCT_NAME}.lnk"
   Delete "$QUICKLAUNCH\XiaoP Setup.lnk"
   Delete "$SMSTARTUP\XiaoP Setup.lnk"
   Delete "$QUICKLAUNCH\XiaoP.lnk"
 
  ;判断是否开机运行程序
   ${If} $CheckAutoStart_State == 1
	;MessageBox MB_OK '选中'
     ;CreateShortCut "$QUICKLAUNCH\${PRODUCT_NAME}.lnk" "$INSTDIR\Pandora.exe"
     ;CreateShortCut "$SMSTARTUP\${PRODUCT_NAME}.lnk" "$INSTDIR\Pandora.exe"
     WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "XiaoP" "$INSTDIR\XiaoP.exe"
   ${EndIf}

  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\XiaoP.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\XiaoP.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  ;WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"

  #写注册表激活客户端链接
  WriteRegStr HKCR "Pandora" "" "URL:Pandora Protocol"
  WriteRegStr HKCR "Pandora" "URL Protocol" ""
  WriteRegStr HKCR "Pandora\DefaultICon" "" "$INSTDIR\XiaoP.exe"
  WriteRegStr HKCR "Pandora\Shell\Open\Command" "" "$INSTDIR\xiaopcmd.exe %1"
  ${If} ${RunningX64}
  SetRegView lastused
  ${EndIf}

SectionEnd


;处理页面跳转的命令
Function RelGotoPage
  IntCmp $R9 0 0 Move Move
    StrCmp $R9 "X" 0 Move
      StrCpy $R9 "120"
  Move:
  SendMessage $HWNDPARENT "0x408" "$R9" ""
FunctionEnd

;点击安装按钮
Function OnClick_Install
	StrCpy $R9 1 ;Goto the next page
    Call RelGotoPage
FunctionEnd

;点击右上角关闭按钮
Function onClickClose

    SendMessage $hwndparent ${WM_CLOSE} 0 0  ;关闭
    
FunctionEnd

Function onClickNext
  StrCpy $R9 1 ;Goto the next page
  Call RelGotoPage
  Abort
FunctionEnd

Function OnClickQuitOK
	Call onClickClose
FunctionEnd

Function OnClickQuitCancel
  ${NSW_DestroyWindow} $WarningForm
  EnableWindow $hwndparent 1
  BringToFront
FunctionEnd

#-------------------------------------------------
# 第一个Lable点击，同步CheckBox状态处理函数
#-------------------------------------------------
Function onCheckShortCut

	 ${NSD_GetState} $CheckShortCut $0

   ${If} $0 == ${BST_CHECKED}
			 ${NSD_SetState} $CheckShortCut ${BST_UNCHECKED}
	 ${Else}
			 ${NSD_SetState} $CheckShortCut ${BST_CHECKED}
	 ${EndIf}

FunctionEnd


#-------------------------------------------------
# 第一个Lable点击，同步CheckBox状态处理函数
#-------------------------------------------------
Function onCheckAutoStart

	 ${NSD_GetState} $CheckAutoStart $0

   ${If} $0 == ${BST_CHECKED}
			 ${NSD_SetState} $CheckAutoStart ${BST_UNCHECKED}
	 ${Else}
			 ${NSD_SetState} $CheckAutoStart ${BST_CHECKED}
	 ${EndIf}

FunctionEnd

Function onClickComplete
    ;判断是否打开网站
    ;${If} $Bool_FinishPage == 1
    ;    ExecShell open "http://www.pylife.net"
    ;${EndIf}
    ;判断是否立即运行程序
    ;${If} $Bool_Weibo == 1
    ;  ExecShell open "http://weibo.com/pylife"
    ;  ShowWindow $HWNDPARENT ${SW_HIDE}
    ;  GetFunctionAddress $0 onClickClose
    ;  BgWorker::CallAndWait
	;	${ELSE}
;		  ShowWindow $HWNDPARENT ${SW_HIDE}
    SendMessage $hwndparent ${WM_CLOSE} 0 0  ;关闭
    ExecShell "" "$INSTDIR\Pandora.exe"

  ;  ${EndIf}
FunctionEnd

#----------------------------------------------
#执行卸载任务
#----------------------------------------------
Function UninstallSoft
   ${If} ${RunningX64}
   SetRegView 64
   ;${Else}
    ;  MessageBox MB_OK "running on x86"
   ${EndIf}
    ReadRegStr $R6 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString"
   ${If} ${RunningX64}
   SetRegView lastused
   ${EndIf}

    StrCmp $R6 "" done
    ExecWait "$R6 /S"
    ;MessageBox MB_OK $R6
    #KillProcDLL::KillProc "Pandora.exe"
    ;ExecWait "$R6 /S"
done:
    Pop $R0
FunctionEnd


; Usage:
; Push "C:\Program Files\Directory\Whatever"
; Call GetParent
; Pop $R0 ; $R0 equal "C:\Program Files\Directory"
;得到选中目录用于拼接安装程序名称
Function GetParent
  Exch $R0 ; input string
  Push $R1
  Push $R2
  Push $R3
  StrCpy $R1 0
  StrLen $R2 $R0
  loop:
    IntOp $R1 $R1 + 1
    IntCmp $R1 $R2 get 0 get
    StrCpy $R3 $R0 1 -$R1
    StrCmp $R3 "\" get
    Goto loop
  get:
    StrCpy $R0 $R0 -$R1
    Pop $R3
    Pop $R2
    Pop $R1
    Exch $R0 ; output string
FunctionEnd

; Usage:
; Push $INSTDIR ; input string "C:\Program Files\ProgramName"
; Push "\" ; input chop char
; Call GetLastPart
; Pop $R1 ; last part "ProgramName"
;截取选中目录
Function GetLastPart
  Exch $0 ; chop char
  Exch
  Exch $1 ; input string
  Push $2
  Push $3
  StrCpy $2 0
  loop:
    IntOp $2 $2 - 1
    StrCpy $3 $1 1 $2
    StrCmp $3 "" 0 +3
      StrCpy $0 ""
      Goto exit2
    StrCmp $3 $0 exit1
    Goto loop
  exit1:
    IntOp $2 $2 + 1
    StrCpy $0 $1 "" $2
  exit2:
    Pop $3
    Pop $2
    Pop $1
    Exch $0 ; output string
FunctionEnd


/******************************
 *  以下是安装程序的卸载部分  *
 ******************************/

Section Uninstall
  SetDetailsPrint textonly
  DetailPrint "正在卸载${PRODUCT_NAME}..."

  SetShellVarContext all 
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\conf.config"
  Delete "$INSTDIR\Upgrade.exe"
  #Delete "$INSTDIR\conf.config"
  Delete "$INSTDIR\Newtonsoft.Json.dll"
  Delete "$INSTDIR\CaptureTool.dll"
  Delete "$INSTDIR\XiaoP.exe"
  Delete "$INSTDIR\RabbitMQ.Client.dll"
  Delete "$INSTDIR\ImgView.dll"
  Delete "$INSTDIR\CaptureImageTool.dll"
  Delete "$INSTDIR\sounds\*"
  Delete "$INSTDIR\update\*"
  Delete "$INSTDIR\xiaopcmd.exe"
  Delete "$INSTDIR\profiles\system\userLogo\*"
  Delete "$INSTDIR\profiles\system\cursors\*"

  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall.lnk"
  Delete "$SMPROGRAMS\XiaoP\XiaoP.lnk"
  Delete "$SMPROGRAMS\XiaoP\Uninstall.lnk"
  ;Delete "$SMPROGRAMS\$ICONS_GROUP\Website.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Pandora.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall.lnk"
 

  Delete "$QUICKLAUNCH\${PRODUCT_NAME}.lnk"
  Delete "$SMSTARTUP\${PRODUCT_NAME}.lnk"
  Delete "$QUICKLAUNCH\Pandora Setup.lnk"
  Delete "$SMSTARTUP\Pandora Setup.lnk"
  Delete "$QUICKLAUNCH\XiaoP.lnk"
  Delete "$SMSTARTUP\XiaoP.lnk"

 
  Delete "$SMPROGRAMS\Pandora\${PRODUCT_NAME}.lnk"
  Delete "$SMPROGRAMS\Pandora\Uninstall.lnk"
  Delete "$SMPROGRAMS\Pandora\卸载${PRODUCT_NAME}.lnk"
  #MessageBox MB_OK $ICONS_GROUP
  RMDir "$SMPROGRAMS\XiaoP"
  RMDir "$SMPROGRAMS\Pandora"
  RMDir "$SMPROGRAMS\${PRODUCT_NAME}"
  Delete "$DESKTOP\XiaoP.lnk"
  Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
  ;RMDir /r "$INSTDIR\profiles"
  RMDir /r "$INSTDIR\sounds"
  ;RMDir /r "$INSTDIR\update"
  ;RMDir /r "$INSTDIR"


  ${If} ${RunningX64}
  SetRegView 64  
  ${EndIf}
  
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"

  DeleteRegValue HKCR "Pandora" "URL Protocol" 
  DeleteRegValue HKCR "Pandora\DefaultICon" ""
  DeleteRegValue HKCR "Pandora\Shell\Open\Command" ""
  DeleteRegKey HKCR "Pandora"
 
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "Pandora"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "XiaoP"

  ${If} ${RunningX64}
  SetRegView lastused
  ${EndIf}
 
  SetAutoClose true
SectionEnd

#-- 根据 NSIS 脚本编辑规则，所有 Function 区段必须放置在 Section 区段之后编写，以避免安装程序出现未可预知的问题。--#

Function un.Page.5
    GetDlgItem $0 $HWNDPARENT 1
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 2
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 3
    ShowWindow $0 ${SW_HIDE}

    nsDialogs::Create 1044
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}
    SetCtlColors $0 ""  transparent ;背景设成透明

    ${NSW_SetWindowSize} $0 514 355 ;改变窗体大小


    ${NSD_CreateLabel} 25u 8u 150u 9u "${PRODUCT_NAME} 卸载"
    Pop $2
    SetCtlColors $2 666666  transparent ;背景设成透明

    ${NSD_CreateLabel} 10% 25% 250u 15u '"欢迎使用${PRODUCT_NAME}"卸载向导！'
    Pop $2
    SetCtlColors $2 ""  transparent ;背景设成透明
    CreateFont $1 "宋体" "11" "700"
    SendMessage $2 ${WM_SETFONT} $1 0

    ${NSD_CreateLabel} 10% 31% 280u 25u "这个向导将指引你从计算机移除${PRODUCT_NAME}。单击【卸载】按钮开始卸载。"
    Pop $2
    SetCtlColors $2 "666666"  transparent ;背景设成透明

    ;创建取消按钮
    ${NSD_CreateButton} 416 315 72 24 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_cancel.bmp $0
    GetFunctionAddress $3 un.onClickclos
    SkinBtn::onClick $0 $3

    ${NSD_CreateButton} 338 315 72 24 "卸载"
    Pop $R0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $R0
    GetFunctionAddress $3 un.onClickins
    SkinBtn::onClick $R0 $3

    ;最小化按钮
    ;${NSD_CreateButton} 434 1 31 18 ""
    ;Pop $0
    ;SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $0
    ;GetFunctionAddress $3 un.onClickmini
    ;SkinBtn::onClick $0 $3

   ;关闭按钮
    ${NSD_CreateButton}} 490 8 15 15 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_close.bmp $0
    GetFunctionAddress $3 un.onClickclos
    SkinBtn::onClick $0 $3

    ;贴背景大图
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\bg.bmp $ImageHandle


    GetFunctionAddress $0 un.onGUICallback
    WndProc::onCallback $BGImage $0 ;处理无边框窗体移动
    nsDialogs::Show

    ${NSD_FreeImage} $ImageHandle
FunctionEnd

Function un.InstFiles.PRO

FunctionEnd

Function un.InstFiles.Show
    FindWindow $BCSJ "#32770" "" $HWNDPARENT
    GetDlgItem $0 $HWNDPARENT 1
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 2
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 3
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $1 $BCSJ 1027
    ShowWindow $1 ${SW_HIDE}

    GetDlgItem $R0 $BCSJ 1004  ;设置进度条位置
    System::Call "user32::MoveWindow(i R0, i 30, i 100, i 440, i 12) i r2梁逸峰"


    StrCpy $R0 $BCSJ ;改变页面大小,不然贴图不能全页
    System::Call "user32::MoveWindow(i R0, i 0, i 0, i 514, i 355) i r2"
    GetFunctionAddress $0 un.onGUICallback
    WndProc::onCallback $R0 $0 ;处理无边框窗体移动

    GetDlgItem $R1 $BCSJ 1006  ;获取1006控件设置颜色并改变位置
    SetCtlColors $R1 ""  F6F6F6 ;背景设成F6F6F6,注意颜色不能设为透明，否则重叠
    System::Call "user32::MoveWindow(i R1, i 30, i 82, i 440, i 12) i r2"

    GetDlgItem $R3 $BCSJ 1990  ;获取1006控件设置颜色并改变位置
    System::Call "user32::MoveWindow(i R3, i 434, i 1, i 31, i 18) i r2"
		SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $R3
		GetFunctionAddress $3 un.onClickmini
    SkinBtn::onClick $R3 $3
    ShowWindow $R3 ${SW_HIDE}
    ;SetCtlColors $R1 ""  F6F6F6 ;背景设成F6F6F6,注意颜色不能设为透明，否则重叠

    GetDlgItem $R4 $BCSJ 1991  ;获取1006控件设置颜色并改变位置
    System::Call "user32::MoveWindow(i R4, i 490, i 8, i 15, i 15) i r2" ;改变位置465, 1, 31, 18
		SkinBtn::Set /IMGID=$PLUGINSDIR\btn_close.bmp $R4
		GetFunctionAddress $3 un.onClickclos
    SkinBtn::onClick $R4 $3
    EnableWindow $R4 0  ;禁止0为禁止

    GetDlgItem $R5 $BCSJ 1992  ;获取1006控件设置颜色并改变位置
    System::Call "user32::MoveWindow(i R5, i 416, i 339, i 72, i 24) i r2"
    ${NSD_SetText} $R5 "安装"
		SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $R5
		;GetFunctionAddress $3 un.onClickins
    SkinBtn::onClick $R5 $3
    ;EnableWindow $R5 0
    ShowWindow $R5 ${SW_HIDE}

    GetDlgItem $R7 $BCSJ 1993  ;获取1993控件设置颜色并改变位置
    SetCtlColors $R7 "666666"  transparent ;
    System::Call "user32::MoveWindow(i R7, i 38, i 12, i 150, i 12) i r2"
    ${NSD_SetText} $R7 "${PRODUCT_NAME} 安装" ;设置某个控件的 text 文本


    GetDlgItem $R8 $BCSJ 1016  ;获取1006控件设置颜色并改变位置
    SetCtlColors $R8 ""  F6F6F6 ;背景设成F6F6F6,注意颜色不能设为透明，否则重叠
    System::Call "user32::MoveWindow(i R8, i 30, i 120, i 440, i 180) i r2"

    FindWindow $R2 "#32770" "" $HWNDPARENT
    GetDlgItem $R0 $R2 1995
    System::Call "user32::MoveWindow(i R0, i 0, i 0, i 498, i 373) i r2"
    ${NSD_SetImage} $R0 $PLUGINSDIR\bg.bmp $ImageHandle

		;这里是给进度条贴图
    FindWindow $R2 "#32770" "" $HWNDPARENT
    GetDlgItem $5 $R2 1004
	  SkinProgress::Set $5 "$PLUGINSDIR\Progress.bmp" "$PLUGINSDIR\ProgressBar.bmp"

FunctionEnd

Function un.Page.6
    GetDlgItem $0 $HWNDPARENT 1
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 2
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 3
    ShowWindow $0 ${SW_HIDE}
    
    nsDialogs::Create 1044
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}
    SetCtlColors $0 ""  transparent ;背景设成透明

    ${NSW_SetWindowSize} $0 514 355 ;改变窗体大小

    ${NSD_CreateLabel} 25u 8u 150u 9u "${PRODUCT_NAME} 卸载"
    Pop $2
    SetCtlColors $2 666666  transparent ;背景设成透明

    ${NSD_CreateLabel} 10% 25% 250u 15u '"${PRODUCT_NAME}"卸载完成！'
    Pop $2
    SetCtlColors $2 ""  transparent ;背景设成透明
    CreateFont $1 "宋体" "11" "700"
    SendMessage $2 ${WM_SETFONT} $1 0

    ${NSD_CreateLabel} 10% 31% 250u 12u "${PRODUCT_NAME}已从您的电脑中成功移除，请单击【完成】。"
    Pop $2
    SetCtlColors $2 666666  transparent ;背景设成透明

    ;完成按钮
    ${NSD_CreateButton} 416 315 72 24 "完成"
    Pop $2
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $2
    GetFunctionAddress $3 un.onClickend
    SkinBtn::onClick $2 $3

    ;关闭按钮
    ${NSD_CreateButton}} 490 8 15 15 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_close.bmp $0
    GetFunctionAddress $3 un.onClickclos
    SkinBtn::onClick $0 $3

    ;贴背景大图
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\bg.bmp $ImageHandle
    GetFunctionAddress $0 un.onGUICallback
    WndProc::onCallback $BGImage $0 ;处理无边框窗体移动
    nsDialogs::Show

FunctionEnd


Function un.Page.7

FunctionEnd


Function un.ForceKillProcess
try_kill_one:
    KillProcDLL::KillProc "Pandora.exe"
    Pop $R0
    IntCmp $R0 0 try_kill_one       ; 返回0表示杀进程成功，则应继续杀此进程名的其它进程
    IntCmp $R0 603 check_no_more    ; 返回603表示没找到此进程，有两种情况：a) 确实没有此进程 b) 因权限等原因无法访问此进程，如果第2种，应认为杀进程失败，所以需要进一步检查
fail_to_kill:   ; KillProc返回值非0非603，或返回603但实际上此进程仍存在，均表示杀进程失败
    MessageBox MB_ICONSTOP "无法终止 Pandora 助手 (Pandora.exe)，请手动终止此程序后重试"
    Quit
check_no_more:
    FindProcDLL::FindProc "Pandora.exe"
    Pop $R0
    IntCmp $R0 1 fail_to_kill  ; 如果FindProc结果为1，表示找到了程序，说明杀进程失败，否则继续
no_more:
FunctionEnd

Function un.onInit
    InitPluginsDir
    ;Call un.ForceKillProcess 
    Push $R0
    CheckProc:
	Push "Pandora.exe"
	ProcessWork::existsprocess
	Pop $R0
	IntCmp $R0 0 Done
	;MessageBox MB_OKCANCEL|MB_ICONSTOP "安装程序检测到 XiaoP 正在运行，请退出程序后重试。$\r$\n点击“确定”立即结束进程，点击“取消”退出。" IDCANCEL Exit
	Push "Pandora.exe"
	ProcessWork::KillProcess
	Sleep 1000
	Goto CheckProc
	Done:
	Pop $R0

    File `/oname=$PLUGINSDIR\btn_next.bmp` `images\btn_next.bmp`
    File `/oname=$PLUGINSDIR\btn_close.bmp` `images\btn_close.bmp`
    File `/oname=$PLUGINSDIR\btn_cancel.bmp` `images\btn_cancel.bmp`
    File `/oname=$PLUGINSDIR\btn_quit.bmp` `images\btn_quit.bmp`
    File `/oname=$PLUGINSDIR\btn_complete.bmp` `images\btn_complete.bmp`

    File `/ONAME=$PLUGINSDIR\bg.bmp` `images\all_bg.bmp`
    
    File `/oname=$PLUGINSDIR\btn_clos.bmp` `images\clos.bmp`
    File `/oname=$PLUGINSDIR\btn_mini.bmp` `images\mini.bmp`
    File `/oname=$PLUGINSDIR\btn_in.bmp` `images\in.bmp`
    File `/oname=$PLUGINSDIR\btn_btn.bmp` `images\btn.bmp`

    ;进度条皮肤
    File `/oname=$PLUGINSDIR\Progress.bmp` `images\Progress.bmp`
    File `/oname=$PLUGINSDIR\ProgressBar.bmp` `images\ProgressBar.bmp`

    SkinBtn::Init "$PLUGINSDIR\btn_next.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_close.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_complete.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_cancel.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_quit.bmp"
FunctionEnd

Function un.onGUIInit
    ;消除边框
    System::Call `user32::SetWindowLong(i$HWNDPARENT,i${GWL_STYLE},0x9480084C)i.R0`
    ;隐藏一些既有控件
    GetDlgItem $0 $HWNDPARENT 1034
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1035
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1036
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1037
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1038
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1039
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1256
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1028
    ShowWindow $0 ${SW_HIDE}

    ${NSW_SetWindowSize} $HWNDPARENT 514 355 ;改变主窗体大小
    System::Call User32::GetDesktopWindow()i.R0
    ;圆角
    System::Alloc 16
  	System::Call user32::GetWindowRect(i$HWNDPARENT,isR0)
  	System::Call *$R0(i.R1,i.R2,i.R3,i.R4)
  	IntOp $R3 $R3 - $R1
  	IntOp $R4 $R4 - $R2
  	System::Call gdi32::CreateRoundRectRgn(i0,i0,iR3,iR4,i4,i4)i.r0
  	System::Call user32::SetWindowRgn(i$HWNDPARENT,ir0,i1)
  	System::Free $R0

FunctionEnd

;处理无边框移动
Function un.onGUICallback
  ${If} $MSG = ${WM_LBUTTONDOWN}
    SendMessage $HWNDPARENT ${WM_NCLBUTTONDOWN} ${HTCAPTION} $0
  ${EndIf}
FunctionEnd

#------------------------------------------
#最小化代码
#------------------------------------------
Function un.onClickmini
System::Call user32::CloseWindow(i$HWNDPARENT) ;最小化
FunctionEnd

#------------------------------------------
#关闭代码
#------------------------------------------
Function un.onClickclos
SendMessage $hwndparent ${WM_CLOSE} 0 0  ;关闭
FunctionEnd

#------------------------------------------
#卸载完成页使用独立区段方便操作，如打开某个网页
#------------------------------------------
Function un.onClickend
SendMessage $hwndparent ${WM_CLOSE} 0 0
FunctionEnd

;处理页面跳转的命令
Function un.RelGotoPage
  IntCmp $R9 0 0 Move Move
    StrCmp $R9 "X" 0 Move
      StrCpy $R9 "120"
  Move:
  SendMessage $HWNDPARENT "0x408" "$R9" ""
FunctionEnd

Function un.onClickins
  StrCpy $R9 1 ;Goto the next page
  Call un.RelGotoPage
  Abort
FunctionEnd

