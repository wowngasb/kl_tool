Attribute VB_Name = "MiniToSys"
'������Щ��������һ¥�Ĵ��룬�пյĻ��ټӸ��Ҽ��˵�
'model1.bas

Public Const DefaultIconIndex = 1 'ͼ��ȱʡ����
Public Const WM_LBUTTONDOWN = &H201 '��������
Public Const WM_RBUTTONDOWN = &H204 '������Ҽ�

Public Const NIM_ADD = 0 '���ͼ��
Public Const NIM_MODIFY = 1 '�޸�ͼ��
Public Const NIM_DELETE = 2 'ɾ��ͼ��

Public Const NIF_MESSAGE = 1 'message ��Ч
Public Const NIF_ICON = 2 'ͼ���������ӡ��޸ġ�ɾ������Ч
Public Const NIF_TIP = 4 'ToolTip(��ʾ����Ч

'API��������
'ͼ�����
Declare Function Shell_NotifyIcon Lib "shell32.dll" Alias "Shell_NotifyIconA" (ByVal dwMessage As Long, lpData As NOTIFYICONDATA) As Long
'�жϴ����Ƿ���С��
Declare Function IsIconic Lib "user32" (ByVal hWnd As Long) As Long
'
'���ô���λ�ú�״̬��position���Ĺ���
Declare Function SetWindowPos Lib "user32" (ByVal hWnd As Long, ByVal hWndInsertAfter As Long, ByVal x As Long, ByVal y As Long, ByVal cx As Long, ByVal cy As Long, ByVal wFlags As Long) As Long

'��������
'֪ͨ��ͼ��״̬
Public Type NOTIFYICONDATA
cbSize As Long
hWnd As Long
uID As Long
uFlags As Long
uCallbackMessage As Long
hIcon As Long
szTip As String * 64
End Type

'��������
'���ͼ����֪ͨ��
Public Function Icon_Add(iHwnd As Long, sTips As String, hIcon As Long, IconID As Long) As Long
  '����˵����iHwnd�����ھ����sTips��������Ƶ�֪ͨ��ͼ����ʱ��ʾ����ʾ����
  'hIcon��ͼ������IconID��ͼ��Id��
  Dim IconVa As NOTIFYICONDATA
  With IconVa
    .hWnd = iHwnd
    .szTip = sTips + Chr$(0)
    .hIcon = hIcon
    .uID = IconID
    .uCallbackMessage = WM_LBUTTONDOWN
    .cbSize = Len(IconVa)
    .uFlags = NIF_MESSAGE Or NIF_ICON Or NIF_TIP
    Icon_Add = Shell_NotifyIcon(NIM_ADD, IconVa)
  End With
End Function
'ɾ��֪ͨ��ͼ��(����˵��ͬIcon_Add)
Function Icon_Del(iHwnd As Long, lIndex As Long) As Long
  Dim IconVa As NOTIFYICONDATA
  Dim l As Long
  With IconVa
    .hWnd = iHwnd
    .uID = lIndex
    .cbSize = Len(IconVa)
  End With
  Icon_Del = Shell_NotifyIcon(NIM_DELETE, IconVa)
End Function
'�޸�֪ͨ��ͼ��(����˵��ͬIcon_Add)
Public Function Icon_Modify(iHwnd As Long, sTips As String, hIcon As Long, IconID As Long) As Long
  Dim IconVa As NOTIFYICONDATA
  With IconVa
    .hWnd = iHwnd
    .szTip = sTips + Chr$(0)
    .hIcon = hIcon
    .uID = IconID
    .uCallbackMessage = WM_LBUTTONDOWN
    .cbSize = Len(IconVa)
    .uFlags = NIF_MESSAGE Or NIF_ICON Or NIF_TIP
    Icon_Modify = Shell_NotifyIcon(NIM_MODIFY, IconVa)
  End With
End Function
