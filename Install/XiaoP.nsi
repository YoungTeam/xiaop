;7Z打开空白
!system '>blank set/p=MSCF<nul'
!packhdr temp.dat 'cmd /c Copy /b temp.dat /b +blank&&del blank'

Var MSG     ;MSG变量必须定义，而且在最前面，否则WndProc::onCallback不工作，插件中需要这个消息变量,用于记录消息信息
Var Dialog  ;Dialog变量也需要定义，他可能是NSIS默认的对话框变量用于保存窗体中控件的信息

Var BGImage  ;背景大图
Var ImageHandle
Var THImage   ;叹号
Var BCSJ

Var WarningForm

Var btn_in
Var btn_ins
Var link_fastin

Var lbl_zhuye
Var lbl_biaoti

Var Txt_Browser
Var btn_Browser

Var Checkbox1
Var Checkbox_State1
Var Checkbox1_State

Var Checkbox2
Var Checkbox_State2
Var Checkbox2_State

;Var Checkbox3
;Var Checkbox_State3
;Var Checkbox3_State

;Var Checkbox4
;Var Checkbox_State4
;Var Checkbox4_State

;---------------------------全局编译脚本预定义的常量-----------------------------------------------------
;!define PRODUCT_NAME "Pandora 助手"
!define PRODUCT_NAME "小P"
!define SETUPEXE_NAME "Pandora"
!define PRODUCT_DIR "Pandora"
!define PRODUCT_VERSION "3.0.0.2"
!define PRODUCT_PUBLISHER "yt.OP.OP-INFO."
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\Pandora.exe" ;请自行修改
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\Pandora"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

ShowInstDetails nevershow ;设置是否显示安装详细信息。
ShowUnInstDetails nevershow ;设置是否显示删除详细信息。

;应用程序显示名字
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
;应用程序输出文件名
OutFile "${SETUPEXE_NAME}_${PRODUCT_VERSION}.exe"
;默认安装目录
InstallDir "$PROGRAMFILES\${PRODUCT_DIR}"
InstallDirRegKey HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"

; MUI 预定义常量
;!define MUI_ABORTWARNING ;退出提示
;安装图标的路径名字
!define MUI_ICON "Icon\install.ico"
;卸载图标的路径名字
!define MUI_UNICON "Icon\unst.ico"
;使用的UI
!define MUI_UI "UI\mod.exe"


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

;------------------------------------------------------MUI 现代界面定义以及函数结束------------------------

Function .onInit
    InitPluginsDir
    StrCpy $Checkbox1_State ${BST_CHECKED}
    StrCpy $Checkbox2_State ${BST_CHECKED}
    
    File `/ONAME=$PLUGINSDIR\bg.bmp` `nimages\index.bmp`
    File `/oname=$PLUGINSDIR\mgbg.bmp` `images\Message.bmp`
    File `/oname=$PLUGINSDIR\processbg.bmp` `nimages\process_bg.bmp`
    File `/oname=$PLUGINSDIR\succbg.bmp` `nimages\succ_bg.bmp`
    File `/oname=$PLUGINSDIR\selfbg.bmp` `nimages\self_bg.bmp`

    File `/ONAME=$PLUGINSDIR\BeiJing.bmp` `images\BeiJing.bmp`
    File `/oname=$PLUGINSDIR\btn_clos.bmp` `nimages\clos.bmp`
    File `/oname=$PLUGINSDIR\btn_mini.bmp` `nimages\mini.bmp`
    File `/oname=$PLUGINSDIR\btn_bg.bmp` `nimages\btn_bg.bmp`
    File `/oname=$PLUGINSDIR\btn_btn.bmp` `images\btn.bmp`
    File `/oname=$PLUGINSDIR\TanHao.bmp` `images\TanHao.bmp`

    File `/ONAME=$PLUGINSDIR\msgbg.bmp` `nimages\un_bg.bmp`
    File `/oname=$PLUGINSDIR\msg_clos.bmp` `nimages\un_close.bmp`


		;进度条皮肤
    File `/oname=$PLUGINSDIR\Progress.bmp` `nimages\progress.bmp`
    File `/oname=$PLUGINSDIR\ProgressBar.bmp` `nimages\progressBar.bmp`

    SkinBtn::Init "$PLUGINSDIR\btn_btn.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_bg.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_mini.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_clos.bmp"
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

    ${NSW_SetWindowSize} $HWNDPARENT 600 400 ;改变主窗体大小
    ;System::Call User32::GetDesktopWindow()i.R0
    ;圆角
    ;System::Alloc 16
  ;	System::Call user32::GetWindowRect(i$HWNDPARENT,isR0)
  ;	System::Call *$R0(i.R1,i.R2,i.R3,i.R4)
  ;	IntOp $R3 $R3 - $R1
  ;	IntOp $R4 $R4 - $R2
  ;	System::Call gdi32::CreateRoundRectRgn(i0,i0,iR3,iR4,i4,i4)i.r0
  ;	System::Call user32::SetWindowRgn(i$HWNDPARENT,ir0,i1)
  System::Free $R0
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

    ${NSW_SetWindowSize} $0 600 400 ;改变Page大小

    ;XXX安装向导
    ;${NSD_CreateLabel} 30u 130u 493U 18u "${PRODUCT_NAME} 纯净版"
    ;Pop $lbl_zhuye
    ;SetCtlColors $lbl_zhuye 0xFFFFFF transparent ;背景设成透明
    ;CreateFont $1 "微软雅黑" "20" "800"
    ;SendMessage $lbl_zhuye ${WM_SETFONT} $1 0
    ;${NSD_AddStyle} $lbl_zhuye ${ES_CENTER}

    ;标题文字
    ;${NSD_CreateLabel} 25u 8u 150u 9u "${PRODUCT_NAME} 安装"
    ;Pop $lbl_biaoti
    ;;SetCtlColors $lbl_biaoti "" 0xFFFFFF ;蓝色
    ;SetCtlColors $lbl_biaoti "666666"  transparent ;背景设成透明

    ;自定义安装按钮
    ;${NSD_CreateButton} 120u 185u 260 56 "自定义安装"
    ;Pop $btn_ins
    ;SkinBtn::Set /IMGID=$PLUGINSDIR\btn_bg.bmp $btn_ins
    ;SetCtlColors $btn_ins "808080"  transparent ;背景设成透明
    ;GetFunctionAddress $3 onClickins
    ;SkinBtn::onClick $btn_ins $3

    ;快速安装按钮
    ${NSD_CreateButton} 170 324 260 46 "快速安装(推荐)"
    Pop $btn_in 
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_bg.bmp $btn_in
    SetCtlColors $btn_in 0xFFFFFF transparent ;背景设成透明
    CreateFont $1 "微软雅黑" "16" "0"
    SendMessage $btn_in ${WM_SETFONT} $1 0
    ${NSD_AddStyle} $btn_in ${ES_CENTER}
    GetFunctionAddress $3 onClickin
    SkinBtn::onClick $btn_in $3


    ;自定义安装按钮
    ;${NSD_CreateButton} 490 370 100 20 "自定义安装"
    ;Pop $link_fastin
    ;SkinBtn::Set /IMGID=$PLUGINSDIR\btn_bg.bmp $link_fastin
    ;SetCtlColors $link_fastin "666666"  transparent ;背景设成透明
    ;GetFunctionAddress $3 onClickins
    ;SkinBtn::onClick $link_fastin $3

    ${NSD_CreateLink} 490 370 100 12u "自定义安装 >>"
    Pop $link_fastin
    SetCtlColors $link_fastin "3cbba2"  "F8FCFB" ;前景色,背景设成透明
    CreateFont $2 "微软雅黑" "10" "0"
    SendMessage $link_fastin ${WM_SETFONT} $2 0
    ${NSD_OnClick} $link_fastin onClickins
    
    ;最小化按钮
    ${NSD_CreateButton} 520 1 40 40 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $0
    SetCtlColors $0 "" transparent ;背景设成透明
    GetFunctionAddress $3 onClickmini
    SkinBtn::onClick $0 $3

    ;关闭按钮
    ${NSD_CreateButton} 560 1 40 40 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_clos.bmp $0
    GetFunctionAddress $3 MessgesboxPage
    SkinBtn::onClick $0 $3

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

    ${NSW_SetWindowSize} $0 600 400 ;改变Page大小

   ;安装按钮
    ${NSD_CreateButton} 170 324 260 46 "安装"
    Pop $0 
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_bg.bmp $0
    SetCtlColors $0 0xFFFFFF transparent ;背景设成透明
    CreateFont $1 "微软雅黑" "16" "0"
    SendMessage $0 ${WM_SETFONT} $1 0
    ${NSD_AddStyle} $0 ${ES_CENTER}
    GetFunctionAddress $3 onClickinst
    SkinBtn::onClick $0 $3
  

#------------------------------------------
#可选项1
#------------------------------------------    
    ${NSD_CreateCheckbox} 95 265 12u 12u ""
    Pop $Checkbox1
    SetCtlColors $Checkbox1 "" "f7f7f7"
    ;${NSD_SetState} $Checkbox1 ${BST_CHECKED}
    ${NSD_CreateLabel} 115 262 100u 12u "添加桌面快捷方式"
    Pop $Checkbox_State1
    SetCtlColors $Checkbox_State1 "666666"  transparent ;前景色,背景设成透明
    CreateFont $1 "微软雅黑" "11" "0"
    SendMessage $Checkbox_State1 ${WM_SETFONT} $1 0
    ${NSD_OnClick} $Checkbox_State1 onCheckbox1
    ${NSD_SetState} $Checkbox1 ${BST_CHECKED}
#------------------------------------------
#可选项2
#------------------------------------------
    ${NSD_CreateCheckbox} 300 265 12u 12u ""
    Pop $Checkbox2
    SetCtlColors $Checkbox2 "" "f4f4f4"
    ;${NSD_SetState} $Checkbox3 ${BST_CHECKED}
    ;ShowWindow $Checkbox2 ${SW_HIDE}
		
    ${NSD_CreateLabel} 320 262 100u 12u "开机自动启动"
    Pop $Checkbox_State2
    SetCtlColors $Checkbox_State2 "666666"  transparent ;前景色,背景设成透明
    SendMessage $Checkbox_State2 ${WM_SETFONT} $1 0
    ${NSD_OnClick} $Checkbox_State2 onCheckbox2
    ${NSD_SetState} $Checkbox2 ${BST_CHECKED}
    ;ShowWindow $Checkbox_State2 ${SW_HIDE}   ;当你不使用该选项时，可以隐藏
    
#可选项完成!
#------------------------------------------

    ;最小化按钮
    ${NSD_CreateButton} 520 1 40 40 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $0
    GetFunctionAddress $3 onClickmini
    SkinBtn::onClick $0 $3

    ;关闭按钮
    ${NSD_CreateButton} 560 1 40 40 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_clos.bmp $0
    GetFunctionAddress $3 MessgesboxPage
    SkinBtn::onClick $0 $3
    
    ;创建安装目录输入文本框
    ${NSD_CreateText} 95 220 310 30 $INSTDIR
    Pop $Txt_Browser
    CreateFont $1 "微软雅黑" "11" "0"
    SendMessage $Txt_Browser ${WM_SETFONT} $1 1
    ;ShowWindow $Txt_Browser ${SW_HIDE}


    ;创建更改路径文件夹按钮
    ${NSD_CreateButton} 425 220 90 30  "浏览"
    Pop $btn_Browser
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $btn_Browser
    GetFunctionAddress $3 onButtonClickSelectPath
    SkinBtn::onClick $btn_Browser $3
    ;ShowWindow $btn_Browser ${SW_HIDE}
    
    ;贴背景大图
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\selfbg.bmp $ImageHandle

    GetFunctionAddress $0 onGUICallback
    WndProc::onCallback $BGImage $0 ;处理无边框窗体移动
    nsDialogs::Show
    ${NSD_FreeImage} $ImageHandle
FunctionEnd

#----------------------------------------------
#存储4个选项状态
#----------------------------------------------
Function Page.2leave
   ${NSD_GetState} $Checkbox1 $Checkbox1_State
   ${NSD_GetState} $Checkbox2 $Checkbox2_State
   ;${NSD_GetState} $Checkbox3 $Checkbox3_State
   ;${NSD_GetState} $Checkbox4 $Checkbox4_State
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
    System::Call "user32::MoveWindow(i R0, i 30, i 353, i 540, i 12) i r2"


    StrCpy $R0 $R2 ;改变页面大小,不然贴图不能全页
    System::Call "user32::MoveWindow(i R0, i 0, i 0, i 600, i 400) i r2"
    GetFunctionAddress $0 onGUICallback
    WndProc::onCallback $R0 $0 ;处理无边框窗体移动
    
    GetDlgItem $R1 $R2 1006  ;获取1006控件设置颜色并改变位置
    SetCtlColors $R1 ""  F6F6F6 ;背景设成F6F6F6,注意颜色不能设为透明，否则重叠
    System::Call "user32::MoveWindow(i R1, i 30, i 82, i 440, i 12) i r2"
    ShowWindow $R1 ${SW_HIDE}

    GetDlgItem $R3 $R2 1990  ;获取1006控件设置颜色并改变位置
    System::Call "user32::MoveWindow(i R3, i 520, i 0, i 40, i 40) i r2"
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $R3
    GetFunctionAddress $3 onClickmini
    SkinBtn::onClick $R3 $3
     ShowWindow $R3 ${SW_HIDE}
    ;SetCtlColors $R1 ""  F6F6F6 ;背景设成F6F6F6,注意颜色不能设为透明，否则重叠

    GetDlgItem $R4 $R2 1991  ;获取1006控件设置颜色并改变位置
    System::Call "user32::MoveWindow(i R4, i 560, i 0, i 40, i 40) i r2" ;改变位置465, 1, 31, 18
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_clos.bmp $R4
    GetFunctionAddress $3 onClickclos
    SkinBtn::onClick $R4 $3
    EnableWindow $R4 0  ;禁止0为禁止
     ShowWindow $R4 ${SW_HIDE}    

    GetDlgItem $R5 $R2 1992  ;获取1006控件设置颜色并改变位置
    System::Call "user32::MoveWindow(i R5, i 500, i 370, i 72, i 24) i r2"
    ${NSD_SetText} $R5 "安装"
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $R5
    GetFunctionAddress $3 onClickins
    SkinBtn::onClick $R5 $3
    EnableWindow $R5 0
    ShowWindow $R5 ${SW_HIDE}

    ;GetDlgItem $R7 $R2 1993  ;获取1993控件设置颜色并改变位置
    ;SetCtlColors $R7 "666666"  transparent ;
    ;System::Call "user32::MoveWindow(i R7, i 38, i 12, i 150, i 12) i r2"
    ;${NSD_SetText} $R7 "${PRODUCT_NAME} 安装" ;设置某个控件的 text 文本


    GetDlgItem $R8 $R2 1016  ;获取1006控件设置颜色并改变位置
    SetCtlColors $R8 ""  F6F6F6 ;背景设成F6F6F6,注意颜色不能设为透明，否则重叠
    System::Call "user32::MoveWindow(i R8, i 0, i 0, i 600, i 320) i r2"
    
    FindWindow $R2 "#32770" "" $HWNDPARENT
    GetDlgItem $R0 $R2 1995
    System::Call "user32::MoveWindow(i R0, i 0, i 0, i 600, i 400) i r2"
    ${NSD_SetImage} $R0 $PLUGINSDIR\processbg.bmp $ImageHandle

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


    nsDialogs::Create 1044
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}
    SetCtlColors $0 ""  transparent ;背景设成透明

    ${NSW_SetWindowSize} $0 600 400 ;改变Page大小


    ;${NSD_CreateLabel} 10% 25% 250u 15u '"${PRODUCT_NAME}"安装完成！'
    ;Pop $2
    ;SetCtlColors $2 ""  transparent ;背景设成透明
    ;CreateFont $1 "宋体" "11" "700"
    ;SendMessage $2 ${WM_SETFONT} $1 0

    ;${NSD_CreateLabel} 10% 31% 250u 12u "${PRODUCT_NAME}已安装到您的电脑中，请单击【完成】。"
    ;Pop $2
    ;SetCtlColors $2 666666  transparent ;背景设成透明

		;标题文字
    ;${NSD_CreateLabel} 25u 8u 150u 9u "${PRODUCT_NAME} 安装"
    ;Pop $lbl_biaoti
    ;SetCtlColors $lbl_biaoti "" 0xFFFFFF ;蓝色
    ;SetCtlColors $lbl_biaoti "666666"  transparent ;背景设成透明



    ;完成按钮
    ${NSD_CreateButton} 170 324 260 46 "立即体验"
    Pop $0 
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_bg.bmp $0
    SetCtlColors $0 0xFFFFFF transparent ;背景设成透明
    CreateFont $1 "微软雅黑" "16" "0"
    SendMessage $0 ${WM_SETFONT} $1 0
    ${NSD_AddStyle} $0 ${ES_CENTER}
    GetFunctionAddress $3 onClickend
    SkinBtn::onClick $0 $3
    
    ;${NSD_CreateButton} 416 339 72 24 "完成"
    ;Pop $0
    ;SkinBtn::Set /IMGID=$PLUGINSDIR\btn_BTN.bmp $0
    ;GetFunctionAddress $3 onClickend
    ;SkinBtn::onClick $0 $3

    ;最小化按钮
    ${NSD_CreateButton} 520 1 40 40 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $0
    GetFunctionAddress $3 onClickmini
    SkinBtn::onClick $0 $3

    ;关闭按钮
    ${NSD_CreateButton} 560 1 40 40 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_clos.bmp $0
    GetFunctionAddress $3 onClickclos
    SkinBtn::onClick $0 $3
    ;EnableWindow $0 0

    ;贴背景大图
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\succbg.bmp $ImageHandle


    GetFunctionAddress $0 onGUICallback
    WndProc::onCallback $BGImage $0 ;处理无边框窗体移动
    nsDialogs::Show

    ${NSD_FreeImage} $ImageHandle

FunctionEnd


Function Page.4

FunctionEnd

Function MessgesboxPage
	IsWindow $WarningForm Create_End
	!define Style ${WS_VISIBLE}|${WS_OVERLAPPEDWINDOW}
	${NSW_CreateWindowEx} $WarningForm $hwndparent ${ExStyle} ${Style} "" 1018

	;${NSW_SetWindowSize} $WarningForm 382 202
	System::Call "user32::MoveWindow(i $WarningForm, i 0, i 0, i 380, i 210) i r2"
	EnableWindow $hwndparent 0
  ;SetCtlColors $hwndparent ""  transparent ;背景设成透明
	System::Call `user32::SetWindowLong(i$WarningForm,i${GWL_STYLE},0x9480084C)i.R0`

	  ${NSW_CreateButton} 225 179 72 24 '确定'
	  Pop $1
	  SkinBtn::Set /IMGID=$PLUGINSDIR\btn_bg.bmp $1
          SetCtlColors $1 "FFFFFF"  transparent ;背景设成透明
	  GetFunctionAddress $3 onClickclos
	  SkinBtn::onClick $1 $3

	  ${NSW_CreateButton} 303 179 72 24 '取消'
	  Pop $1
	  SkinBtn::Set /IMGID=$PLUGINSDIR\btn_bg.bmp $1
          SetCtlColors $1 "FFFFFF"  transparent ;背景设成透明
	  GetFunctionAddress $3 OnClickQuitCancel
	  SkinBtn::onClick $1 $3

	  ;关闭按钮
	  ${NSW_CreateButton} 350 1 30 29 ""
	  Pop $1
	  SkinBtn::Set /IMGID=$PLUGINSDIR\msg_clos.bmp $1
	  GetFunctionAddress $3 OnClickQuitCancel
	  SkinBtn::onClick $1 $3

		;退出提示
	  ${NSW_CreateLabel} 17% 95 170u 9u "确定要退出${PRODUCT_NAME}安装吗？"
	  Pop $R3
	  ;SetCtlColors $R2 "" 0xFFFFFF ;蓝色
	  SetCtlColors $R3 "636363"  transparent ;背景设成透明

		;左上角文字
	  ${NSW_CreateLabel} 25u 8u 150u 9u "${PRODUCT_NAME}"
	  Pop $R2
	  ;SetCtlColors $R2 "" 0xFFFFFF ;蓝色
	  SetCtlColors $R2 "666666"  transparent ;背景设成透明

		;叹号
		${NSW_CreateBitmap} 10% 93 16u 16u ""
	  Pop $THImage
	  ${NSW_SetImage} $THImage $PLUGINSDIR\TanHao.bmp $ImageHandle

		;背景图
		${NSW_CreateBitmap} 0 0 380u 210u ""
	  Pop $BGImage
	  ${NSW_SetImage} $BGImage $PLUGINSDIR\msgbg.bmp $ImageHandle

		GetFunctionAddress $0 onWarningGUICallback
		WndProc::onCallback $BGImage $0 ;处理无边框窗体移动
	;	WndProc::onCallback $THImage $0
	;	WndProc::onCallback $R2 $0
	;	WndProc::onCallback $R3 $0

        ${NSW_CenterWindow} $WarningForm $hwndparent
	${NSW_Show}
	Create_End:
        ShowWindow $WarningForm ${SW_SHOW}
FunctionEnd

Function GetNetFrameworkVersion
;获取.Net Framework版本支持
    Push $1
    Push $0
    ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" "Install"
    ReadRegDWORD $1 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" "Version"
    StrCmp $0 1 KnowNetFrameworkVersion +1
    ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" "Install"
    ReadRegDWORD $1 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" "Version"
    StrCmp $0 1 KnowNetFrameworkVersion +1
    ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.0\Setup" "InstallSuccess"
    ReadRegDWORD $1 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.0\Setup" "Version"
    StrCmp $0 1 KnowNetFrameworkVersion +1
    ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v2.0.50727" "Install"
    ReadRegDWORD $1 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v2.0.50727" "Version"
    StrCmp $1 "" +1 +2
    StrCpy $1 "2.0.50727.832"
    StrCmp $0 1 KnowNetFrameworkVersion +1
    ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v1.1.4322" "Install"
    ReadRegDWORD $1 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v1.1.4322" "Version"
    StrCmp $1 "" +1 +2
    StrCpy $1 "1.1.4322.573"
    StrCmp $0 1 KnowNetFrameworkVersion +1
    ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\.NETFramework\policy\v1.0" "Install"
    ReadRegDWORD $1 HKLM "SOFTWARE\Microsoft\.NETFramework\policy\v1.0" "Version"
    StrCmp $1 "" +1 +2
    StrCpy $1 "1.0.3705.0"
    StrCmp $0 1 KnowNetFrameworkVersion +1
    StrCpy $1 "not .NetFramework"
    KnowNetFrameworkVersion:
    Pop $0
    Exch $1
FunctionEnd

Function DownloadNetFramework4
;下载 .NET Framework 4.0
  NSISdl::download /TRANSLATE2 '正在下载 %s' '正在连接...' '(剩余 1 秒)' '(剩余 1 分钟)' '(剩余 1 小时)' '(剩余 %u 秒)' '(剩余 %u 分钟)' '(剩余 %u 小时)' '已完成：%skB(%d%%) 大小：%skB 速度：%u.%01ukB/s' /TIMEOUT=7500 /NOIEPROXY 'http://10.138.96.28/versions/dotNetFx40.exe' '$INSTDIR\dotNetFx40.exe'
  Pop $R0
  StrCmp $R0 "success" 0 +2
   
  SetDetailsPrint textonly
  DetailPrint "正在安装 .NET Framework 4.0 Full..."
  SetDetailsPrint listonly
  ExecWait '$INSTDIR\dotNetFx40.exe /quiet /norestart' $R1
  Delete "$INSTDIR\dotNetFx40.exe"
   
FunctionEnd

Section MainSetup
SetDetailsPrint textonly
DetailPrint ""
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

  SetOutPath $INSTDIR
  ;检测是否是需要的.NET Framework版本
  Call GetNetFrameworkVersion
  Pop $R1
  ${If} $R1 < '4.0.30319'
      Call DownloadNetFramework4
  ${ENDIF}

  SetShellVarContext all
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  File "..\XiaoP\bin\Release\XLUE.dll"
  File "..\XiaoP\bin\Release\XiaoP.UI.Core.dll"
  File "..\XiaoP\bin\Release\RabbitMQ.Client.dll"
  File "..\XiaoP\bin\Release\ImgView.dll"
  File "..\XiaoP\bin\Release\CaptureTool.dll"
  ;File "..\XiaoP\bin\Release\PSkin.dll"
  File "..\XiaoP\bin\Release\Pandora.exe"
  File "..\XiaoP\bin\Release\Newtonsoft.Json.dll"
  ;File "..\XiaoP\bin\Release\conf.config"
  File "..\Upgrade\bin\Release\Upgrade.exe"
  File "..\Xiaopcmd\bin\Release\xiaopcmd.exe"
  CreateDirectory "$INSTDIR\update"
  CreateDirectory "$INSTDIR\sounds"
  CreateDirectory "$INSTDIR\profiles\user"
  ;CreateDirectory "$DOCUMENTS\Pandora\userLogo"
  	
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
  ;CreateDirectory "$INSTDIR\profiles\system\cursors"
  ;SetOutPath "$INSTDIR\profiles\system\cursors"
  ;File "..\Pandora\bin\Release\profiles\system\cursors\*"


   SetOutPath "$INSTDIR"
   ;判断是否添加桌面快捷方式
   ${If} $Checkbox1_State == 1
      CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\Pandora.exe"
   ${EndIf}
   
   sleep 1000

nsisSlideshow::Stop
SetAutoClose true
SectionEnd

Section -AdditionalIcons
  SetShellVarContext all
  SetOutPath "$INSTDIR"
  ;!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  CreateDirectory "$SMPROGRAMS\Pandora"
  CreateShortCut "$SMPROGRAMS\Pandora\${PRODUCT_NAME}.lnk" "$INSTDIR\Pandora.exe"
  CreateShortCut "$SMPROGRAMS\Pandora\卸载${PRODUCT_NAME}.lnk" "$INSTDIR\uninst.exe"
SectionEnd


#----------------------------------------------
#创建控制面板卸载程序信息 ,下面的具体用法卡查看帮助  D.2 添加卸载信息到添加/删除程序面板  或者在帮助里搜索关键词，如：DisplayName
#----------------------------------------------
Section -Post

   ${If} ${RunningX64}
   SetRegView 64
   ;${Else}
    ;  MessageBox MB_OK "running on x86"
   ${EndIf}
   DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "Pandora"
   DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "Pandora"

   Delete "$QUICKLAUNCH\${PRODUCT_NAME}.lnk"
   Delete "$SMSTARTUP\${PRODUCT_NAME}.lnk"
   ;Delete "$SMSTARTUP\Pandora Setup.lnk"
   ;Delete "$QUICKLAUNCH\XiaoP.lnk"
 
  ;判断是否开机运行程序
   ${If} $Checkbox2_State == 1
     ;MessageBox MB_OK '选中'
     ;CreateShortCut "$QUICKLAUNCH\${PRODUCT_NAME}.lnk" "$INSTDIR\Pandora.exe"
     ;CreateShortCut "$SMSTARTUP\${PRODUCT_NAME}.lnk" "$INSTDIR\Pandora.exe"
     WriteRegStr HKCU "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "Pandora" "$INSTDIR\Pandora.exe"
   ${EndIf}

  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\Pandora.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\Pandora.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  ;WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"

  #写注册表激活客户端链接
  WriteRegStr HKCR "Pandora" "" "URL:Pandora Protocol"
  WriteRegStr HKCR "Pandora" "URL Protocol" ""
  WriteRegStr HKCR "Pandora\DefaultICon" "" "$INSTDIR\Pandora.exe"
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

Function onClickins
  StrCpy $R9 1 ;Goto the next page
  Call RelGotoPage
  Abort
FunctionEnd

Function onClickin
StrCpy $Checkbox1_State 1  ;这里，我直接把第二页的四个选项情况写出来了，请自己修改
StrCpy $Checkbox2_State 1
  StrCpy $R9 2 ;Goto the next page
  Call RelGotoPage
  Abort
FunctionEnd

Function onClickinst
  ${NSD_GetText} $Txt_Browser  $R0  ;获得设置的安装路径

  ;判断目录是否正确
	ClearErrors
	CreateDirectory "$R0"
	IfErrors 0 +3
  MessageBox MB_ICONINFORMATION|MB_OK "'$R0' 安装目录不存在，请重新设置。"
  Return

	StrCpy $INSTDIR  $R0  ;保存安装路径

	;跳到下一页， $R9是NavigationGotoPage 函数需要的跳转参数变量
  StrCpy $R9 1
  call RelGotoPage
FunctionEnd
#------------------------------------------
#最小化代码
#------------------------------------------
Function onClickmini
System::Call user32::CloseWindow(i$HWNDPARENT) ;最小化
FunctionEnd

#------------------------------------------
#关闭代码
#------------------------------------------
Function onClickclos
SendMessage $hwndparent ${WM_CLOSE} 0 0  ;关闭
FunctionEnd

Function OnClickQuitCancel
  ${NSW_DestroyWindow} $WarningForm
  EnableWindow $hwndparent 1
  BringToFront
FunctionEnd

#--------------------------------------------------------
# 路径选择按钮事件，打开Windows系统自带的目录选择对话框
#--------------------------------------------------------
Function onButtonClickSelectPath

   ${NSD_GetText} $Txt_Browser  $0
   nsDialogs::SelectFolderDialog  "请选择 ${PRODUCT_NAME} 安装目录："  "$0"
   Pop $0
   ${IfNot} $0 == error
	${NSD_SetText} $Txt_Browser  $0
   ${EndIf}

FunctionEnd

#-------------------------------------------------
# 第一个Lable点击，同步CheckBox状态处理函数
#-------------------------------------------------
Function onCheckbox1

	 ${NSD_GetState} $Checkbox1 $0

   	 ${If} $0 == ${BST_CHECKED}
			 ${NSD_SetState} $Checkbox1 ${BST_UNCHECKED}
	 ${Else}
			 ${NSD_SetState} $Checkbox1 ${BST_CHECKED}
	 ${EndIf}

FunctionEnd

#-------------------------------------------------
# 第二个Lable点击，同步CheckBox状态处理函数
#-------------------------------------------------
Function onCheckbox2

	 ${NSD_GetState} $Checkbox2 $0

         ${If} $0 == ${BST_CHECKED}
			 ${NSD_SetState} $Checkbox2 ${BST_UNCHECKED}
	 ${Else}
			 ${NSD_SetState} $Checkbox2 ${BST_CHECKED}
	 ${EndIf}

FunctionEnd

;完成页面完成按钮
Function onClickend
SendMessage $hwndparent ${WM_CLOSE} 0 0
ExecShell "" "$INSTDIR\Pandora.exe"
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

/******************************
 *  以下是安装程序的卸载部分  *
 ******************************/

Section Uninstall
  SetDetailsPrint textonly
  DetailPrint "正在卸载${PRODUCT_NAME}..."
  Delete "$INSTDIR\uninst.exe"

  #-- 卸载文件 --#

  SetShellVarContext all 
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\sounds\*"
  Delete "$INSTDIR\profiles\system\userLogo\*"
  Delete "$INSTDIR\profiles\system\cursors\*"
  Delete "$INSTDIR\xar\XAR\*"
  Delete "$INSTDIR\*"

  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Pandora.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall.lnk"
 

  Delete "$QUICKLAUNCH\${PRODUCT_NAME}.lnk"
  Delete "$QUICKLAUNCH\pandora 助手.lnk"
  Delete "$SMSTARTUP\${PRODUCT_NAME}.lnk"
  Delete "$SMSTARTUP\pandora 助手.lnk"

 
  Delete "$SMPROGRAMS\Pandora\${PRODUCT_NAME}.lnk"
  Delete "$SMPROGRAMS\Pandora\卸载${PRODUCT_NAME}.lnk"
  RMDir "$SMPROGRAMS\Pandora"
  Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
  Delete "$DESKTOP\pandora 助手.lnk"
  ;RMDir /r "$INSTDIR\profiles"
  ;RMDir /r "$INSTDIR\xar"
  ;RMDir /r "$INSTDIR\update"
  ;RMDir /r "$INSTDIR\sounds"
  RMDir /r "$INSTDIR"

  ${If} ${RunningX64}
  SetRegView 64  
  ${EndIf}
 
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"

  DeleteRegValue HKCR "Pandora" "URL Protocol" 
  DeleteRegValue HKCR "Pandora\DefaultICon" ""
  DeleteRegValue HKCR "Pandora\Shell\Open\Command" ""
  DeleteRegKey HKCR "Pandora"
 
  DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "Pandora"

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

    ${NSW_SetWindowSize} $0 380 210 ;改变窗体大小


    ;${NSD_CreateLabel} 25u 8u 150u 9u "${PRODUCT_NAME} 卸载"
    ;Pop $2
    ;SetCtlColors $2 666666  transparent ;背景设成透明

    ;${NSD_CreateLabel} 10% 25% 250u 15u '"欢迎使用${PRODUCT_NAME}"卸载向导！'
    ;Pop $2
    ;SetCtlColors $2 ""  transparent ;背景设成透明
    ;CreateFont $1 "宋体" "11" "700"
    ;SendMessage $2 ${WM_SETFONT} $1 0

    ${NSD_CreateLabel} 10% 31% 280u 25u "您确定要卸载 ${PRODUCT_NAME} 么？"
    Pop $2
    SetCtlColors $2 "666666"  transparent ;背景设成透明

    ;创建取消按钮
    ${NSD_CreateButton} 290 180 70 25 "取消"
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $0
    SetCtlColors $0 "FFFFFF"  transparent ;背景设成透明
    GetFunctionAddress $3 un.onClickclos
    SkinBtn::onClick $0 $3
    ;380.210
    ${NSD_CreateButton} 210 180 70 25 "卸载"
    Pop $R0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $R0
    SetCtlColors $R0 "FFFFFF"  transparent ;背景设成透明
    GetFunctionAddress $3 un.onClickins
    SkinBtn::onClick $R0 $3

    ;最小化按钮
    ${NSD_CreateButton} 320 1 30 29 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $0
    GetFunctionAddress $3 un.onClickmini
    SkinBtn::onClick $0 $3

    ;关闭按钮
    ${NSD_CreateButton} 350 1 30 29 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_clos.bmp $0
    GetFunctionAddress $3 un.onClickclos
    SkinBtn::onClick $0 $3

    ;贴背景大图
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\unbg.bmp $ImageHandle


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
    System::Call "user32::MoveWindow(i R0, i 20, i 70, i 340, i 12) i r2"


    StrCpy $R0 $BCSJ ;改变页面大小,不然贴图不能全页
    System::Call "user32::MoveWindow(i R0, i 0, i 0, i 380, i 210) i r2"
    GetFunctionAddress $0 un.onGUICallback
    WndProc::onCallback $R0 $0 ;处理无边框窗体移动

    GetDlgItem $R1 $BCSJ 1006  ;获取1006控件设置颜色并改变位置
    SetCtlColors $R1 ""  F6F6F6 ;背景设成F6F6F6,注意颜色不能设为透明，否则重叠
    System::Call "user32::MoveWindow(i R1, i 30, i 82, i 380, i 12) i r2"


    GetDlgItem $R3 $BCSJ 1990  ;获取1006控件设置颜色并改变位置
    System::Call "user32::MoveWindow(i R3, i 320, i 1, i 30, i 29) i r2"
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $R3
    GetFunctionAddress $3 un.onClickmini
    SkinBtn::onClick $R3 $3
    ;SetCtlColors $R1 ""  F6F6F6 ;背景设成F6F6F6,注意颜色不能设为透明，否则重叠

    GetDlgItem $R4 $BCSJ 1991  ;获取1006控件设置颜色并改变位置
    System::Call "user32::MoveWindow(i R4, i 350, i 1, i 30, i 29) i r2" ;改变位置465, 1, 31, 18
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_clos.bmp $R4
    GetFunctionAddress $3 un.onClickclos
    SkinBtn::onClick $R4 $3
    EnableWindow $R4 0  ;禁止0为禁止

    GetDlgItem $R5 $BCSJ 1992  ;获取1006控件设置颜色并改变位置
    System::Call "user32::MoveWindow(i R5, i 290, i 180, i 70, i 25) i r2"
    ${NSD_SetText} $R5 "完成"
    SetCtlColors $R5 "FFFFFF"  transparent ;背景设成透明
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $R5
    ;GetFunctionAddress $3 un.onClickins
    SkinBtn::onClick $R5 $3
    EnableWindow $R5 0

    ;title
    GetDlgItem $R7 $BCSJ 1993  ;获取1993控件设置颜色并改变位置
    SetCtlColors $R7 "666666"  transparent ;
    System::Call "user32::MoveWindow(i R7, i 38, i 12, i 150, i 12) i r2"
    ${NSD_SetText} $R7 "" ;设置某个控件的 text 文本


    GetDlgItem $R8 $BCSJ 1016  ;获取1006控件设置颜色并改变位置
    SetCtlColors $R8 ""  F6F6F6 ;背景设成F6F6F6,注意颜色不能设为透明，否则重叠
    System::Call "user32::MoveWindow(i R8, i 30, i 120, i 440, i 180) i r2"

    FindWindow $R2 "#32770" "" $HWNDPARENT
    GetDlgItem $R0 $R2 1995
    System::Call "user32::MoveWindow(i R0, i 0, i 0, i 380, i 210) i r2"
    ${NSD_SetImage} $R0 $PLUGINSDIR\unbg.bmp $ImageHandle

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

    ${NSW_SetWindowSize} $0 380 210 ;改变窗体大小

    ;${NSD_CreateLabel} 25u 8u 150u 9u "${PRODUCT_NAME} 卸载"
    ;Pop $2
    ;SetCtlColors $2 666666  transparent ;背景设成透明

    ${NSD_CreateLabel} 10% 25% 250u 15u '"${PRODUCT_NAME}"卸载完成！'
    Pop $2
    SetCtlColors $2 ""  transparent ;背景设成透明
    CreateFont $1 "宋体" "11" "700"
    SendMessage $2 ${WM_SETFONT} $1 0

    ${NSD_CreateLabel} 10% 41% 250u 12u "${PRODUCT_NAME}已从您的电脑中成功移除，请单击【完成】。"
    Pop $2
    SetCtlColors $2 666666  transparent ;背景设成透明

    ;完成按钮
    ${NSD_CreateButton} 290 180 70 25 "完成"
    Pop $2
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $2
    SetCtlColors $2 "FFFFFF"  transparent ;背景设成透明
    GetFunctionAddress $3 un.onClickend
    SkinBtn::onClick $2 $3

    ;最小化按钮
    ${NSD_CreateButton} 320 1 30 29 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $0
    GetFunctionAddress $3 un.onClickmini
    SkinBtn::onClick $0 $3

    ;关闭按钮
    ${NSD_CreateButton} 350 1 30 29 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_clos.bmp $0
    GetFunctionAddress $3 un.onClickclos
    SkinBtn::onClick $0 $3

    ;贴背景大图
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\unbg.bmp $ImageHandle
    GetFunctionAddress $0 un.onGUICallback
    WndProc::onCallback $BGImage $0 ;处理无边框窗体移动
    nsDialogs::Show

FunctionEnd


Function un.Page.7

FunctionEnd


Function un.onInit
    InitPluginsDir

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

    File `/ONAME=$PLUGINSDIR\unbg.bmp` `nimages\un_bg.bmp`
    File `/oname=$PLUGINSDIR\btn_clos.bmp` `nimages\un_close.bmp`
    File `/oname=$PLUGINSDIR\btn_mini.bmp` `nimages\un_min.bmp`
    File `/oname=$PLUGINSDIR\btn_in.bmp` `nimages\btn_bg.bmp`
    File `/oname=$PLUGINSDIR\btn_btn.bmp` `nimages\btn_bg.bmp`

		;进度条皮肤
    File `/oname=$PLUGINSDIR\Progress.bmp` `nimages\progress.bmp`
    File `/oname=$PLUGINSDIR\ProgressBar.bmp` `nimages\progressBar.bmp`

    SkinBtn::Init "$PLUGINSDIR\btn_btn.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_in.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_mini.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_clos.bmp"
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

    ${NSW_SetWindowSize} $HWNDPARENT 380 210 ;改变主窗体大小
    ;System::Call User32::GetDesktopWindow()i.R0
    ;圆角
    ;System::Alloc 16
    ;System::Call user32::GetWindowRect(i$HWNDPARENT,isR0)
  	;System::Call *$R0(i.R1,i.R2,i.R3,i.R4)
  	;IntOp $R3 $R3 - $R1
  	;IntOp $R4 $R4 - $R2
  	;System::Call gdi32::CreateRoundRectRgn(i0,i0,iR3,iR4,i4,i4)i.r0
  	;System::Call user32::SetWindowRgn(i$HWNDPARENT,ir0,i1)
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

