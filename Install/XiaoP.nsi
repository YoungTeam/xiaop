;7Z�򿪿հ�
!system '>blank set/p=MSCF<nul'
!packhdr temp.dat 'cmd /c Copy /b temp.dat /b +blank&&del blank'

Var MSG     ;MSG�������붨�壬��������ǰ�棬����WndProc::onCallback���������������Ҫ�����Ϣ����,���ڼ�¼��Ϣ��Ϣ
Var Dialog  ;Dialog����Ҳ��Ҫ���壬��������NSISĬ�ϵĶԻ���������ڱ��洰���пؼ�����Ϣ

Var BGImage  ;������ͼ
Var ImageHandle
Var THImage   ;̾��
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

;---------------------------ȫ�ֱ���ű�Ԥ����ĳ���-----------------------------------------------------
;!define PRODUCT_NAME "Pandora ����"
!define PRODUCT_NAME "СP"
!define SETUPEXE_NAME "Pandora"
!define PRODUCT_DIR "Pandora"
!define PRODUCT_VERSION "3.0.0.2"
!define PRODUCT_PUBLISHER "yt.OP.OP-INFO."
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\Pandora.exe" ;�������޸�
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\Pandora"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

ShowInstDetails nevershow ;�����Ƿ���ʾ��װ��ϸ��Ϣ��
ShowUnInstDetails nevershow ;�����Ƿ���ʾɾ����ϸ��Ϣ��

;Ӧ�ó�����ʾ����
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
;Ӧ�ó�������ļ���
OutFile "${SETUPEXE_NAME}_${PRODUCT_VERSION}.exe"
;Ĭ�ϰ�װĿ¼
InstallDir "$PROGRAMFILES\${PRODUCT_DIR}"
InstallDirRegKey HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"

; MUI Ԥ���峣��
;!define MUI_ABORTWARNING ;�˳���ʾ
;��װͼ���·������
!define MUI_ICON "Icon\install.ico"
;ж��ͼ���·������
!define MUI_UNICON "Icon\unst.ico"
;ʹ�õ�UI
!define MUI_UI "UI\mod.exe"


;---------------------------��������ѹ�����ͣ�Ҳ����ͨ���������ű����ƣ�------------------------------------
SetCompressor lzma
SetCompress force
XPStyle on
; ------ MUI �ִ����涨�� (1.67 �汾���ϼ���) ------
!include "MUI2.nsh"
!include "WinCore.nsh"
!include "nsWindows.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"
!include "x64.nsh"

!define MUI_CUSTOMFUNCTION_GUIINIT onGUIInit

;�Զ���ҳ��
Page custom Page.1

Page custom Page.2 Page.2leave
; ����Э��ҳ��
;!define MUI_LICENSEPAGE_CHECKBOX

; ��װĿ¼ѡ��ҳ��

;!insertmacro MUI_PAGE_DIRECTORY
; ��װ����ҳ��
;!define MUI_PAGE_CUSTOMFUNCTION_PRO InstFilesPagePRO
!define MUI_PAGE_CUSTOMFUNCTION_SHOW InstFilesPageShow
!insertmacro MUI_PAGE_INSTFILES

Page custom Page.3

Page custom Page.4
; ��װ���ҳ��
;!insertmacro MUI_PAGE_FINISH
; ��װж�ع���ҳ��
UninstPage custom un.Page.5

UninstPage instfiles un.InstFiles.PRO un.InstFiles.Show

UninstPage custom un.Page.6

UninstPage custom un.Page.7


; ��װ�����������������
!insertmacro MUI_LANGUAGE "SimpChinese"

;------------------------------------------------------MUI �ִ����涨���Լ���������------------------------

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


		;������Ƥ��
    File `/oname=$PLUGINSDIR\Progress.bmp` `nimages\progress.bmp`
    File `/oname=$PLUGINSDIR\ProgressBar.bmp` `nimages\progressBar.bmp`

    SkinBtn::Init "$PLUGINSDIR\btn_btn.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_bg.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_mini.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_clos.bmp"
FunctionEnd

Function onGUIInit

    ;�����߿�
    System::Call `user32::SetWindowLong(i$HWNDPARENT,i${GWL_STYLE},0x9480084C)i.R0`
    ;����һЩ���пؼ�
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

    ${NSW_SetWindowSize} $HWNDPARENT 600 400 ;�ı��������С
    ;System::Call User32::GetDesktopWindow()i.R0
    ;Բ��
    ;System::Alloc 16
  ;	System::Call user32::GetWindowRect(i$HWNDPARENT,isR0)
  ;	System::Call *$R0(i.R1,i.R2,i.R3,i.R4)
  ;	IntOp $R3 $R3 - $R1
  ;	IntOp $R4 $R4 - $R2
  ;	System::Call gdi32::CreateRoundRectRgn(i0,i0,iR3,iR4,i4,i4)i.r0
  ;	System::Call user32::SetWindowRgn(i$HWNDPARENT,ir0,i1)
  System::Free $R0
FunctionEnd

;�����ޱ߿��ƶ�
Function onGUICallback
  ${If} $MSG = ${WM_LBUTTONDOWN}
    SendMessage $HWNDPARENT ${WM_NCLBUTTONDOWN} ${HTCAPTION} $0
  ${EndIf}
FunctionEnd
;�����Ի����ƶ�
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
    SetCtlColors $0 ""  transparent ;�������͸��

    ${NSW_SetWindowSize} $0 600 400 ;�ı�Page��С

    ;XXX��װ��
    ;${NSD_CreateLabel} 30u 130u 493U 18u "${PRODUCT_NAME} ������"
    ;Pop $lbl_zhuye
    ;SetCtlColors $lbl_zhuye 0xFFFFFF transparent ;�������͸��
    ;CreateFont $1 "΢���ź�" "20" "800"
    ;SendMessage $lbl_zhuye ${WM_SETFONT} $1 0
    ;${NSD_AddStyle} $lbl_zhuye ${ES_CENTER}

    ;��������
    ;${NSD_CreateLabel} 25u 8u 150u 9u "${PRODUCT_NAME} ��װ"
    ;Pop $lbl_biaoti
    ;;SetCtlColors $lbl_biaoti "" 0xFFFFFF ;��ɫ
    ;SetCtlColors $lbl_biaoti "666666"  transparent ;�������͸��

    ;�Զ��尲װ��ť
    ;${NSD_CreateButton} 120u 185u 260 56 "�Զ��尲װ"
    ;Pop $btn_ins
    ;SkinBtn::Set /IMGID=$PLUGINSDIR\btn_bg.bmp $btn_ins
    ;SetCtlColors $btn_ins "808080"  transparent ;�������͸��
    ;GetFunctionAddress $3 onClickins
    ;SkinBtn::onClick $btn_ins $3

    ;���ٰ�װ��ť
    ${NSD_CreateButton} 170 324 260 46 "���ٰ�װ(�Ƽ�)"
    Pop $btn_in 
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_bg.bmp $btn_in
    SetCtlColors $btn_in 0xFFFFFF transparent ;�������͸��
    CreateFont $1 "΢���ź�" "16" "0"
    SendMessage $btn_in ${WM_SETFONT} $1 0
    ${NSD_AddStyle} $btn_in ${ES_CENTER}
    GetFunctionAddress $3 onClickin
    SkinBtn::onClick $btn_in $3


    ;�Զ��尲װ��ť
    ;${NSD_CreateButton} 490 370 100 20 "�Զ��尲װ"
    ;Pop $link_fastin
    ;SkinBtn::Set /IMGID=$PLUGINSDIR\btn_bg.bmp $link_fastin
    ;SetCtlColors $link_fastin "666666"  transparent ;�������͸��
    ;GetFunctionAddress $3 onClickins
    ;SkinBtn::onClick $link_fastin $3

    ${NSD_CreateLink} 490 370 100 12u "�Զ��尲װ >>"
    Pop $link_fastin
    SetCtlColors $link_fastin "3cbba2"  "F8FCFB" ;ǰ��ɫ,�������͸��
    CreateFont $2 "΢���ź�" "10" "0"
    SendMessage $link_fastin ${WM_SETFONT} $2 0
    ${NSD_OnClick} $link_fastin onClickins
    
    ;��С����ť
    ${NSD_CreateButton} 520 1 40 40 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $0
    SetCtlColors $0 "" transparent ;�������͸��
    GetFunctionAddress $3 onClickmini
    SkinBtn::onClick $0 $3

    ;�رհ�ť
    ${NSD_CreateButton} 560 1 40 40 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_clos.bmp $0
    GetFunctionAddress $3 MessgesboxPage
    SkinBtn::onClick $0 $3

    ;��������ͼ
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\bg.bmp $ImageHandle

    GetFunctionAddress $0 onGUICallback
    WndProc::onCallback $BGImage $0 ;�����ޱ߿����ƶ�
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
    SetCtlColors $0 ""  transparent ;�������͸��

    ${NSW_SetWindowSize} $0 600 400 ;�ı�Page��С

   ;��װ��ť
    ${NSD_CreateButton} 170 324 260 46 "��װ"
    Pop $0 
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_bg.bmp $0
    SetCtlColors $0 0xFFFFFF transparent ;�������͸��
    CreateFont $1 "΢���ź�" "16" "0"
    SendMessage $0 ${WM_SETFONT} $1 0
    ${NSD_AddStyle} $0 ${ES_CENTER}
    GetFunctionAddress $3 onClickinst
    SkinBtn::onClick $0 $3
  

#------------------------------------------
#��ѡ��1
#------------------------------------------    
    ${NSD_CreateCheckbox} 95 265 12u 12u ""
    Pop $Checkbox1
    SetCtlColors $Checkbox1 "" "f7f7f7"
    ;${NSD_SetState} $Checkbox1 ${BST_CHECKED}
    ${NSD_CreateLabel} 115 262 100u 12u "���������ݷ�ʽ"
    Pop $Checkbox_State1
    SetCtlColors $Checkbox_State1 "666666"  transparent ;ǰ��ɫ,�������͸��
    CreateFont $1 "΢���ź�" "11" "0"
    SendMessage $Checkbox_State1 ${WM_SETFONT} $1 0
    ${NSD_OnClick} $Checkbox_State1 onCheckbox1
    ${NSD_SetState} $Checkbox1 ${BST_CHECKED}
#------------------------------------------
#��ѡ��2
#------------------------------------------
    ${NSD_CreateCheckbox} 300 265 12u 12u ""
    Pop $Checkbox2
    SetCtlColors $Checkbox2 "" "f4f4f4"
    ;${NSD_SetState} $Checkbox3 ${BST_CHECKED}
    ;ShowWindow $Checkbox2 ${SW_HIDE}
		
    ${NSD_CreateLabel} 320 262 100u 12u "�����Զ�����"
    Pop $Checkbox_State2
    SetCtlColors $Checkbox_State2 "666666"  transparent ;ǰ��ɫ,�������͸��
    SendMessage $Checkbox_State2 ${WM_SETFONT} $1 0
    ${NSD_OnClick} $Checkbox_State2 onCheckbox2
    ${NSD_SetState} $Checkbox2 ${BST_CHECKED}
    ;ShowWindow $Checkbox_State2 ${SW_HIDE}   ;���㲻ʹ�ø�ѡ��ʱ����������
    
#��ѡ�����!
#------------------------------------------

    ;��С����ť
    ${NSD_CreateButton} 520 1 40 40 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $0
    GetFunctionAddress $3 onClickmini
    SkinBtn::onClick $0 $3

    ;�رհ�ť
    ${NSD_CreateButton} 560 1 40 40 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_clos.bmp $0
    GetFunctionAddress $3 MessgesboxPage
    SkinBtn::onClick $0 $3
    
    ;������װĿ¼�����ı���
    ${NSD_CreateText} 95 220 310 30 $INSTDIR
    Pop $Txt_Browser
    CreateFont $1 "΢���ź�" "11" "0"
    SendMessage $Txt_Browser ${WM_SETFONT} $1 1
    ;ShowWindow $Txt_Browser ${SW_HIDE}


    ;��������·���ļ��а�ť
    ${NSD_CreateButton} 425 220 90 30  "���"
    Pop $btn_Browser
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $btn_Browser
    GetFunctionAddress $3 onButtonClickSelectPath
    SkinBtn::onClick $btn_Browser $3
    ;ShowWindow $btn_Browser ${SW_HIDE}
    
    ;��������ͼ
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\selfbg.bmp $ImageHandle

    GetFunctionAddress $0 onGUICallback
    WndProc::onCallback $BGImage $0 ;�����ޱ߿����ƶ�
    nsDialogs::Show
    ${NSD_FreeImage} $ImageHandle
FunctionEnd

#----------------------------------------------
#�洢4��ѡ��״̬
#----------------------------------------------
Function Page.2leave
   ${NSD_GetState} $Checkbox1 $Checkbox1_State
   ${NSD_GetState} $Checkbox2 $Checkbox2_State
   ;${NSD_GetState} $Checkbox3 $Checkbox3_State
   ;${NSD_GetState} $Checkbox4 $Checkbox4_State
FunctionEnd
#----------------------------------------------
#��2��ҳ�����
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
		;�Զ������������ɫ��ʽ
		;ȡ��������windows ��ʽ�����񣬸�Ϊ�����Ѷ������ɫ
;		GetDlgItem $2 $R2 1004
;		System::Call UxTheme::SetWindowTheme(i,w,w)i(r2, n, n)
		;SendMessage $2 ${PBM_SETBARCOLOR} 0 0x339a00 ;���ý�����ǰ��ɫ
		;SendMessage $2 ${PBM_SETBKCOLOR} 0 0xa4a4a4  ;���ý���������ɫ

    GetDlgItem $R0 $R2 1004  ;���ý�����λ��
    System::Call "user32::MoveWindow(i R0, i 30, i 353, i 540, i 12) i r2"


    StrCpy $R0 $R2 ;�ı�ҳ���С,��Ȼ��ͼ����ȫҳ
    System::Call "user32::MoveWindow(i R0, i 0, i 0, i 600, i 400) i r2"
    GetFunctionAddress $0 onGUICallback
    WndProc::onCallback $R0 $0 ;�����ޱ߿����ƶ�
    
    GetDlgItem $R1 $R2 1006  ;��ȡ1006�ؼ�������ɫ���ı�λ��
    SetCtlColors $R1 ""  F6F6F6 ;�������F6F6F6,ע����ɫ������Ϊ͸���������ص�
    System::Call "user32::MoveWindow(i R1, i 30, i 82, i 440, i 12) i r2"
    ShowWindow $R1 ${SW_HIDE}

    GetDlgItem $R3 $R2 1990  ;��ȡ1006�ؼ�������ɫ���ı�λ��
    System::Call "user32::MoveWindow(i R3, i 520, i 0, i 40, i 40) i r2"
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $R3
    GetFunctionAddress $3 onClickmini
    SkinBtn::onClick $R3 $3
     ShowWindow $R3 ${SW_HIDE}
    ;SetCtlColors $R1 ""  F6F6F6 ;�������F6F6F6,ע����ɫ������Ϊ͸���������ص�

    GetDlgItem $R4 $R2 1991  ;��ȡ1006�ؼ�������ɫ���ı�λ��
    System::Call "user32::MoveWindow(i R4, i 560, i 0, i 40, i 40) i r2" ;�ı�λ��465, 1, 31, 18
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_clos.bmp $R4
    GetFunctionAddress $3 onClickclos
    SkinBtn::onClick $R4 $3
    EnableWindow $R4 0  ;��ֹ0Ϊ��ֹ
     ShowWindow $R4 ${SW_HIDE}    

    GetDlgItem $R5 $R2 1992  ;��ȡ1006�ؼ�������ɫ���ı�λ��
    System::Call "user32::MoveWindow(i R5, i 500, i 370, i 72, i 24) i r2"
    ${NSD_SetText} $R5 "��װ"
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $R5
    GetFunctionAddress $3 onClickins
    SkinBtn::onClick $R5 $3
    EnableWindow $R5 0
    ShowWindow $R5 ${SW_HIDE}

    ;GetDlgItem $R7 $R2 1993  ;��ȡ1993�ؼ�������ɫ���ı�λ��
    ;SetCtlColors $R7 "666666"  transparent ;
    ;System::Call "user32::MoveWindow(i R7, i 38, i 12, i 150, i 12) i r2"
    ;${NSD_SetText} $R7 "${PRODUCT_NAME} ��װ" ;����ĳ���ؼ��� text �ı�


    GetDlgItem $R8 $R2 1016  ;��ȡ1006�ؼ�������ɫ���ı�λ��
    SetCtlColors $R8 ""  F6F6F6 ;�������F6F6F6,ע����ɫ������Ϊ͸���������ص�
    System::Call "user32::MoveWindow(i R8, i 0, i 0, i 600, i 320) i r2"
    
    FindWindow $R2 "#32770" "" $HWNDPARENT
    GetDlgItem $R0 $R2 1995
    System::Call "user32::MoveWindow(i R0, i 0, i 0, i 600, i 400) i r2"
    ${NSD_SetImage} $R0 $PLUGINSDIR\processbg.bmp $ImageHandle

		;�����Ǹ���������ͼ
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
    SetCtlColors $0 ""  transparent ;�������͸��

    ${NSW_SetWindowSize} $0 600 400 ;�ı�Page��С


    ;${NSD_CreateLabel} 10% 25% 250u 15u '"${PRODUCT_NAME}"��װ��ɣ�'
    ;Pop $2
    ;SetCtlColors $2 ""  transparent ;�������͸��
    ;CreateFont $1 "����" "11" "700"
    ;SendMessage $2 ${WM_SETFONT} $1 0

    ;${NSD_CreateLabel} 10% 31% 250u 12u "${PRODUCT_NAME}�Ѱ�װ�����ĵ����У��뵥������ɡ���"
    ;Pop $2
    ;SetCtlColors $2 666666  transparent ;�������͸��

		;��������
    ;${NSD_CreateLabel} 25u 8u 150u 9u "${PRODUCT_NAME} ��װ"
    ;Pop $lbl_biaoti
    ;SetCtlColors $lbl_biaoti "" 0xFFFFFF ;��ɫ
    ;SetCtlColors $lbl_biaoti "666666"  transparent ;�������͸��



    ;��ɰ�ť
    ${NSD_CreateButton} 170 324 260 46 "��������"
    Pop $0 
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_bg.bmp $0
    SetCtlColors $0 0xFFFFFF transparent ;�������͸��
    CreateFont $1 "΢���ź�" "16" "0"
    SendMessage $0 ${WM_SETFONT} $1 0
    ${NSD_AddStyle} $0 ${ES_CENTER}
    GetFunctionAddress $3 onClickend
    SkinBtn::onClick $0 $3
    
    ;${NSD_CreateButton} 416 339 72 24 "���"
    ;Pop $0
    ;SkinBtn::Set /IMGID=$PLUGINSDIR\btn_BTN.bmp $0
    ;GetFunctionAddress $3 onClickend
    ;SkinBtn::onClick $0 $3

    ;��С����ť
    ${NSD_CreateButton} 520 1 40 40 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $0
    GetFunctionAddress $3 onClickmini
    SkinBtn::onClick $0 $3

    ;�رհ�ť
    ${NSD_CreateButton} 560 1 40 40 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_clos.bmp $0
    GetFunctionAddress $3 onClickclos
    SkinBtn::onClick $0 $3
    ;EnableWindow $0 0

    ;��������ͼ
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\succbg.bmp $ImageHandle


    GetFunctionAddress $0 onGUICallback
    WndProc::onCallback $BGImage $0 ;�����ޱ߿����ƶ�
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
  ;SetCtlColors $hwndparent ""  transparent ;�������͸��
	System::Call `user32::SetWindowLong(i$WarningForm,i${GWL_STYLE},0x9480084C)i.R0`

	  ${NSW_CreateButton} 225 179 72 24 'ȷ��'
	  Pop $1
	  SkinBtn::Set /IMGID=$PLUGINSDIR\btn_bg.bmp $1
          SetCtlColors $1 "FFFFFF"  transparent ;�������͸��
	  GetFunctionAddress $3 onClickclos
	  SkinBtn::onClick $1 $3

	  ${NSW_CreateButton} 303 179 72 24 'ȡ��'
	  Pop $1
	  SkinBtn::Set /IMGID=$PLUGINSDIR\btn_bg.bmp $1
          SetCtlColors $1 "FFFFFF"  transparent ;�������͸��
	  GetFunctionAddress $3 OnClickQuitCancel
	  SkinBtn::onClick $1 $3

	  ;�رհ�ť
	  ${NSW_CreateButton} 350 1 30 29 ""
	  Pop $1
	  SkinBtn::Set /IMGID=$PLUGINSDIR\msg_clos.bmp $1
	  GetFunctionAddress $3 OnClickQuitCancel
	  SkinBtn::onClick $1 $3

		;�˳���ʾ
	  ${NSW_CreateLabel} 17% 95 170u 9u "ȷ��Ҫ�˳�${PRODUCT_NAME}��װ��"
	  Pop $R3
	  ;SetCtlColors $R2 "" 0xFFFFFF ;��ɫ
	  SetCtlColors $R3 "636363"  transparent ;�������͸��

		;���Ͻ�����
	  ${NSW_CreateLabel} 25u 8u 150u 9u "${PRODUCT_NAME}"
	  Pop $R2
	  ;SetCtlColors $R2 "" 0xFFFFFF ;��ɫ
	  SetCtlColors $R2 "666666"  transparent ;�������͸��

		;̾��
		${NSW_CreateBitmap} 10% 93 16u 16u ""
	  Pop $THImage
	  ${NSW_SetImage} $THImage $PLUGINSDIR\TanHao.bmp $ImageHandle

		;����ͼ
		${NSW_CreateBitmap} 0 0 380u 210u ""
	  Pop $BGImage
	  ${NSW_SetImage} $BGImage $PLUGINSDIR\msgbg.bmp $ImageHandle

		GetFunctionAddress $0 onWarningGUICallback
		WndProc::onCallback $BGImage $0 ;�����ޱ߿����ƶ�
	;	WndProc::onCallback $THImage $0
	;	WndProc::onCallback $R2 $0
	;	WndProc::onCallback $R3 $0

        ${NSW_CenterWindow} $WarningForm $hwndparent
	${NSW_Show}
	Create_End:
        ShowWindow $WarningForm ${SW_SHOW}
FunctionEnd

Function GetNetFrameworkVersion
;��ȡ.Net Framework�汾֧��
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
;���� .NET Framework 4.0
  NSISdl::download /TRANSLATE2 '�������� %s' '��������...' '(ʣ�� 1 ��)' '(ʣ�� 1 ����)' '(ʣ�� 1 Сʱ)' '(ʣ�� %u ��)' '(ʣ�� %u ����)' '(ʣ�� %u Сʱ)' '����ɣ�%skB(%d%%) ��С��%skB �ٶȣ�%u.%01ukB/s' /TIMEOUT=7500 /NOIEPROXY 'http://10.138.96.28/versions/dotNetFx40.exe' '$INSTDIR\dotNetFx40.exe'
  Pop $R0
  StrCmp $R0 "success" 0 +2
   
  SetDetailsPrint textonly
  DetailPrint "���ڰ�װ .NET Framework 4.0 Full..."
  SetDetailsPrint listonly
  ExecWait '$INSTDIR\dotNetFx40.exe /quiet /norestart' $R1
  Delete "$INSTDIR\dotNetFx40.exe"
   
FunctionEnd

Section MainSetup
SetDetailsPrint textonly
DetailPrint ""
SetDetailsPrint None ;����ʾ��Ϣ
nsisSlideshow::Show /NOUNLOAD /auto=$PLUGINSDIR\Slides.dat

   Push $R0
    CheckProc:
	Push "Pandora.exe"
	ProcessWork::existsprocess
	Pop $R0
	IntCmp $R0 0 Done
	;MessageBox MB_OKCANCEL|MB_ICONSTOP "��װ�����⵽ XiaoP �������У����˳���������ԡ�$\r$\n�����ȷ���������������̣������ȡ�����˳���" IDCANCEL Exit
	Push "Pandora.exe"
	ProcessWork::KillProcess
	Sleep 1000
	Goto CheckProc
	Done:
	Pop $R0

  Call UninstallSoft
  sleep 1500

  SetOutPath $INSTDIR
  ;����Ƿ�����Ҫ��.NET Framework�汾
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
   ;�ж��Ƿ����������ݷ�ʽ
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
  CreateShortCut "$SMPROGRAMS\Pandora\ж��${PRODUCT_NAME}.lnk" "$INSTDIR\uninst.exe"
SectionEnd


#----------------------------------------------
#�����������ж�س�����Ϣ ,����ľ����÷����鿴����  D.2 ����ж����Ϣ������/ɾ���������  �����ڰ����������ؼ��ʣ��磺DisplayName
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
 
  ;�ж��Ƿ񿪻����г���
   ${If} $Checkbox2_State == 1
     ;MessageBox MB_OK 'ѡ��'
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

  #дע�������ͻ�������
  WriteRegStr HKCR "Pandora" "" "URL:Pandora Protocol"
  WriteRegStr HKCR "Pandora" "URL Protocol" ""
  WriteRegStr HKCR "Pandora\DefaultICon" "" "$INSTDIR\Pandora.exe"
  WriteRegStr HKCR "Pandora\Shell\Open\Command" "" "$INSTDIR\xiaopcmd.exe %1"
  ${If} ${RunningX64}
  SetRegView lastused
  ${EndIf}
SectionEnd


;����ҳ����ת������
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
StrCpy $Checkbox1_State 1  ;�����ֱ�Ӱѵڶ�ҳ���ĸ�ѡ�����д�����ˣ����Լ��޸�
StrCpy $Checkbox2_State 1
  StrCpy $R9 2 ;Goto the next page
  Call RelGotoPage
  Abort
FunctionEnd

Function onClickinst
  ${NSD_GetText} $Txt_Browser  $R0  ;������õİ�װ·��

  ;�ж�Ŀ¼�Ƿ���ȷ
	ClearErrors
	CreateDirectory "$R0"
	IfErrors 0 +3
  MessageBox MB_ICONINFORMATION|MB_OK "'$R0' ��װĿ¼�����ڣ����������á�"
  Return

	StrCpy $INSTDIR  $R0  ;���氲װ·��

	;������һҳ�� $R9��NavigationGotoPage ������Ҫ����ת��������
  StrCpy $R9 1
  call RelGotoPage
FunctionEnd
#------------------------------------------
#��С������
#------------------------------------------
Function onClickmini
System::Call user32::CloseWindow(i$HWNDPARENT) ;��С��
FunctionEnd

#------------------------------------------
#�رմ���
#------------------------------------------
Function onClickclos
SendMessage $hwndparent ${WM_CLOSE} 0 0  ;�ر�
FunctionEnd

Function OnClickQuitCancel
  ${NSW_DestroyWindow} $WarningForm
  EnableWindow $hwndparent 1
  BringToFront
FunctionEnd

#--------------------------------------------------------
# ·��ѡ��ť�¼�����Windowsϵͳ�Դ���Ŀ¼ѡ��Ի���
#--------------------------------------------------------
Function onButtonClickSelectPath

   ${NSD_GetText} $Txt_Browser  $0
   nsDialogs::SelectFolderDialog  "��ѡ�� ${PRODUCT_NAME} ��װĿ¼��"  "$0"
   Pop $0
   ${IfNot} $0 == error
	${NSD_SetText} $Txt_Browser  $0
   ${EndIf}

FunctionEnd

#-------------------------------------------------
# ��һ��Lable�����ͬ��CheckBox״̬��������
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
# �ڶ���Lable�����ͬ��CheckBox״̬��������
#-------------------------------------------------
Function onCheckbox2

	 ${NSD_GetState} $Checkbox2 $0

         ${If} $0 == ${BST_CHECKED}
			 ${NSD_SetState} $Checkbox2 ${BST_UNCHECKED}
	 ${Else}
			 ${NSD_SetState} $Checkbox2 ${BST_CHECKED}
	 ${EndIf}

FunctionEnd

;���ҳ����ɰ�ť
Function onClickend
SendMessage $hwndparent ${WM_CLOSE} 0 0
ExecShell "" "$INSTDIR\Pandora.exe"
FunctionEnd

#----------------------------------------------
#ִ��ж������
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
 *  �����ǰ�װ�����ж�ز���  *
 ******************************/

Section Uninstall
  SetDetailsPrint textonly
  DetailPrint "����ж��${PRODUCT_NAME}..."
  Delete "$INSTDIR\uninst.exe"

  #-- ж���ļ� --#

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
  Delete "$QUICKLAUNCH\pandora ����.lnk"
  Delete "$SMSTARTUP\${PRODUCT_NAME}.lnk"
  Delete "$SMSTARTUP\pandora ����.lnk"

 
  Delete "$SMPROGRAMS\Pandora\${PRODUCT_NAME}.lnk"
  Delete "$SMPROGRAMS\Pandora\ж��${PRODUCT_NAME}.lnk"
  RMDir "$SMPROGRAMS\Pandora"
  Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
  Delete "$DESKTOP\pandora ����.lnk"
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

#-- ���� NSIS �ű��༭�������� Function ���α�������� Section ����֮���д���Ա��ⰲװ�������δ��Ԥ֪�����⡣--#

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
    SetCtlColors $0 ""  transparent ;�������͸��

    ${NSW_SetWindowSize} $0 380 210 ;�ı䴰���С


    ;${NSD_CreateLabel} 25u 8u 150u 9u "${PRODUCT_NAME} ж��"
    ;Pop $2
    ;SetCtlColors $2 666666  transparent ;�������͸��

    ;${NSD_CreateLabel} 10% 25% 250u 15u '"��ӭʹ��${PRODUCT_NAME}"ж���򵼣�'
    ;Pop $2
    ;SetCtlColors $2 ""  transparent ;�������͸��
    ;CreateFont $1 "����" "11" "700"
    ;SendMessage $2 ${WM_SETFONT} $1 0

    ${NSD_CreateLabel} 10% 31% 280u 25u "��ȷ��Ҫж�� ${PRODUCT_NAME} ô��"
    Pop $2
    SetCtlColors $2 "666666"  transparent ;�������͸��

    ;����ȡ����ť
    ${NSD_CreateButton} 290 180 70 25 "ȡ��"
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $0
    SetCtlColors $0 "FFFFFF"  transparent ;�������͸��
    GetFunctionAddress $3 un.onClickclos
    SkinBtn::onClick $0 $3
    ;380.210
    ${NSD_CreateButton} 210 180 70 25 "ж��"
    Pop $R0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $R0
    SetCtlColors $R0 "FFFFFF"  transparent ;�������͸��
    GetFunctionAddress $3 un.onClickins
    SkinBtn::onClick $R0 $3

    ;��С����ť
    ${NSD_CreateButton} 320 1 30 29 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $0
    GetFunctionAddress $3 un.onClickmini
    SkinBtn::onClick $0 $3

    ;�رհ�ť
    ${NSD_CreateButton} 350 1 30 29 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_clos.bmp $0
    GetFunctionAddress $3 un.onClickclos
    SkinBtn::onClick $0 $3

    ;��������ͼ
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\unbg.bmp $ImageHandle


    GetFunctionAddress $0 un.onGUICallback
    WndProc::onCallback $BGImage $0 ;�����ޱ߿����ƶ�
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

    GetDlgItem $R0 $BCSJ 1004  ;���ý�����λ��
    System::Call "user32::MoveWindow(i R0, i 20, i 70, i 340, i 12) i r2"


    StrCpy $R0 $BCSJ ;�ı�ҳ���С,��Ȼ��ͼ����ȫҳ
    System::Call "user32::MoveWindow(i R0, i 0, i 0, i 380, i 210) i r2"
    GetFunctionAddress $0 un.onGUICallback
    WndProc::onCallback $R0 $0 ;�����ޱ߿����ƶ�

    GetDlgItem $R1 $BCSJ 1006  ;��ȡ1006�ؼ�������ɫ���ı�λ��
    SetCtlColors $R1 ""  F6F6F6 ;�������F6F6F6,ע����ɫ������Ϊ͸���������ص�
    System::Call "user32::MoveWindow(i R1, i 30, i 82, i 380, i 12) i r2"


    GetDlgItem $R3 $BCSJ 1990  ;��ȡ1006�ؼ�������ɫ���ı�λ��
    System::Call "user32::MoveWindow(i R3, i 320, i 1, i 30, i 29) i r2"
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $R3
    GetFunctionAddress $3 un.onClickmini
    SkinBtn::onClick $R3 $3
    ;SetCtlColors $R1 ""  F6F6F6 ;�������F6F6F6,ע����ɫ������Ϊ͸���������ص�

    GetDlgItem $R4 $BCSJ 1991  ;��ȡ1006�ؼ�������ɫ���ı�λ��
    System::Call "user32::MoveWindow(i R4, i 350, i 1, i 30, i 29) i r2" ;�ı�λ��465, 1, 31, 18
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_clos.bmp $R4
    GetFunctionAddress $3 un.onClickclos
    SkinBtn::onClick $R4 $3
    EnableWindow $R4 0  ;��ֹ0Ϊ��ֹ

    GetDlgItem $R5 $BCSJ 1992  ;��ȡ1006�ؼ�������ɫ���ı�λ��
    System::Call "user32::MoveWindow(i R5, i 290, i 180, i 70, i 25) i r2"
    ${NSD_SetText} $R5 "���"
    SetCtlColors $R5 "FFFFFF"  transparent ;�������͸��
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $R5
    ;GetFunctionAddress $3 un.onClickins
    SkinBtn::onClick $R5 $3
    EnableWindow $R5 0

    ;title
    GetDlgItem $R7 $BCSJ 1993  ;��ȡ1993�ؼ�������ɫ���ı�λ��
    SetCtlColors $R7 "666666"  transparent ;
    System::Call "user32::MoveWindow(i R7, i 38, i 12, i 150, i 12) i r2"
    ${NSD_SetText} $R7 "" ;����ĳ���ؼ��� text �ı�


    GetDlgItem $R8 $BCSJ 1016  ;��ȡ1006�ؼ�������ɫ���ı�λ��
    SetCtlColors $R8 ""  F6F6F6 ;�������F6F6F6,ע����ɫ������Ϊ͸���������ص�
    System::Call "user32::MoveWindow(i R8, i 30, i 120, i 440, i 180) i r2"

    FindWindow $R2 "#32770" "" $HWNDPARENT
    GetDlgItem $R0 $R2 1995
    System::Call "user32::MoveWindow(i R0, i 0, i 0, i 380, i 210) i r2"
    ${NSD_SetImage} $R0 $PLUGINSDIR\unbg.bmp $ImageHandle

		;�����Ǹ���������ͼ
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
    SetCtlColors $0 ""  transparent ;�������͸��

    ${NSW_SetWindowSize} $0 380 210 ;�ı䴰���С

    ;${NSD_CreateLabel} 25u 8u 150u 9u "${PRODUCT_NAME} ж��"
    ;Pop $2
    ;SetCtlColors $2 666666  transparent ;�������͸��

    ${NSD_CreateLabel} 10% 25% 250u 15u '"${PRODUCT_NAME}"ж����ɣ�'
    Pop $2
    SetCtlColors $2 ""  transparent ;�������͸��
    CreateFont $1 "����" "11" "700"
    SendMessage $2 ${WM_SETFONT} $1 0

    ${NSD_CreateLabel} 10% 41% 250u 12u "${PRODUCT_NAME}�Ѵ����ĵ����гɹ��Ƴ����뵥������ɡ���"
    Pop $2
    SetCtlColors $2 666666  transparent ;�������͸��

    ;��ɰ�ť
    ${NSD_CreateButton} 290 180 70 25 "���"
    Pop $2
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_btn.bmp $2
    SetCtlColors $2 "FFFFFF"  transparent ;�������͸��
    GetFunctionAddress $3 un.onClickend
    SkinBtn::onClick $2 $3

    ;��С����ť
    ${NSD_CreateButton} 320 1 30 29 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_mini.bmp $0
    GetFunctionAddress $3 un.onClickmini
    SkinBtn::onClick $0 $3

    ;�رհ�ť
    ${NSD_CreateButton} 350 1 30 29 ""
    Pop $0
    SkinBtn::Set /IMGID=$PLUGINSDIR\btn_clos.bmp $0
    GetFunctionAddress $3 un.onClickclos
    SkinBtn::onClick $0 $3

    ;��������ͼ
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\unbg.bmp $ImageHandle
    GetFunctionAddress $0 un.onGUICallback
    WndProc::onCallback $BGImage $0 ;�����ޱ߿����ƶ�
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
	;MessageBox MB_OKCANCEL|MB_ICONSTOP "��װ�����⵽ XiaoP �������У����˳���������ԡ�$\r$\n�����ȷ���������������̣������ȡ�����˳���" IDCANCEL Exit
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

		;������Ƥ��
    File `/oname=$PLUGINSDIR\Progress.bmp` `nimages\progress.bmp`
    File `/oname=$PLUGINSDIR\ProgressBar.bmp` `nimages\progressBar.bmp`

    SkinBtn::Init "$PLUGINSDIR\btn_btn.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_in.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_mini.bmp"
    SkinBtn::Init "$PLUGINSDIR\btn_clos.bmp"
FunctionEnd

Function un.onGUIInit
    ;�����߿�
    System::Call `user32::SetWindowLong(i$HWNDPARENT,i${GWL_STYLE},0x9480084C)i.R0`
    ;����һЩ���пؼ�
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

    ${NSW_SetWindowSize} $HWNDPARENT 380 210 ;�ı��������С
    ;System::Call User32::GetDesktopWindow()i.R0
    ;Բ��
    ;System::Alloc 16
    ;System::Call user32::GetWindowRect(i$HWNDPARENT,isR0)
  	;System::Call *$R0(i.R1,i.R2,i.R3,i.R4)
  	;IntOp $R3 $R3 - $R1
  	;IntOp $R4 $R4 - $R2
  	;System::Call gdi32::CreateRoundRectRgn(i0,i0,iR3,iR4,i4,i4)i.r0
  	;System::Call user32::SetWindowRgn(i$HWNDPARENT,ir0,i1)
   System::Free $R0

FunctionEnd

;�����ޱ߿��ƶ�
Function un.onGUICallback
  ${If} $MSG = ${WM_LBUTTONDOWN}
    SendMessage $HWNDPARENT ${WM_NCLBUTTONDOWN} ${HTCAPTION} $0
  ${EndIf}
FunctionEnd

#------------------------------------------
#��С������
#------------------------------------------
Function un.onClickmini
System::Call user32::CloseWindow(i$HWNDPARENT) ;��С��
FunctionEnd

#------------------------------------------
#�رմ���
#------------------------------------------
Function un.onClickclos
SendMessage $hwndparent ${WM_CLOSE} 0 0  ;�ر�
FunctionEnd

#------------------------------------------
#ж�����ҳʹ�ö������η�����������ĳ����ҳ
#------------------------------------------
Function un.onClickend
SendMessage $hwndparent ${WM_CLOSE} 0 0
FunctionEnd

;����ҳ����ת������
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
