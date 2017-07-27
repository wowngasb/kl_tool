VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.1#0"; "MSCOMCTL.OCX"
Object = "{48E59290-9880-11CF-9754-00AA00C00908}#1.0#0"; "MSINET.OCX"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "comdlg32.ocx"
Begin VB.Form AHscan 
   Caption         =   "AHscan"
   ClientHeight    =   3330
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   5205
   LinkTopic       =   "Form1"
   ScaleHeight     =   3330
   ScaleWidth      =   5205
   StartUpPosition =   3  '����ȱʡ
   Begin VB.CommandButton cmdRUN 
      Caption         =   "RUN"
      Height          =   375
      Left            =   3120
      TabIndex        =   12
      Top             =   1080
      Width           =   735
   End
   Begin VB.CommandButton cmdSET 
      Caption         =   "SET"
      Height          =   375
      Left            =   3720
      TabIndex        =   11
      Top             =   120
      Width           =   495
   End
   Begin VB.CommandButton cmdDATA 
      Caption         =   "Data"
      Height          =   375
      Left            =   4080
      TabIndex        =   10
      Top             =   600
      Width           =   735
   End
   Begin MSComDlg.CommonDialog cd 
      Left            =   2160
      Top             =   2160
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.CommandButton cmdREAD 
      Caption         =   "Read"
      Height          =   375
      Left            =   3120
      TabIndex        =   9
      Top             =   600
      Width           =   735
   End
   Begin VB.TextBox filetext 
      Height          =   375
      Left            =   3000
      TabIndex        =   8
      Top             =   1560
      Width           =   2055
   End
   Begin VB.TextBox timetext 
      Height          =   270
      Left            =   3000
      TabIndex        =   7
      Top             =   2040
      Width           =   2055
   End
   Begin VB.TextBox proctext 
      Height          =   270
      Left            =   4440
      TabIndex        =   6
      Top             =   2400
      Width           =   615
   End
   Begin InetCtlsObjects.Inet Inet1 
      Left            =   1080
      Top             =   2280
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
   End
   Begin MSComctlLib.ProgressBar ProgressBar1 
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   2400
      Width           =   4215
      _ExtentX        =   7435
      _ExtentY        =   450
      _Version        =   393216
      Appearance      =   1
   End
   Begin VB.CommandButton cmdEXIT 
      Caption         =   "EXIT"
      Height          =   375
      Left            =   4320
      TabIndex        =   3
      Top             =   120
      Width           =   495
   End
   Begin VB.CommandButton cmdGET 
      Caption         =   "GET"
      Height          =   375
      Left            =   3120
      TabIndex        =   2
      Top             =   120
      Width           =   495
   End
   Begin VB.TextBox savefile 
      Height          =   1215
      Left            =   240
      MultiLine       =   -1  'True
      TabIndex        =   1
      Top             =   1080
      Width           =   2655
   End
   Begin VB.TextBox txtURL 
      Height          =   855
      Left            =   240
      MultiLine       =   -1  'True
      TabIndex        =   0
      Top             =   120
      Width           =   2655
   End
   Begin VB.Label Label3 
      Height          =   375
      Left            =   120
      TabIndex        =   4
      Top             =   2760
      Width           =   4695
   End
End
Attribute VB_Name = "AHscan"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim save_dir As String
Dim is_downing As Boolean, is_runing As Boolean
Dim num_count As Long
Dim s_time
Dim set_str(0 To 5) As String

Const MAX_FILE_BUFF = 1024 * 8

Private Declare Function DeleteUrlCacheEntry Lib "wininet" Alias "DeleteUrlCacheEntryA" (ByVal lpszUrlName As String) As Long
Private Declare Function URLDownloadToFile Lib "urlmon" Alias "URLDownloadToFileA" (ByVal pCaller As Long, ByVal szURL As String, ByVal szFileName As String, ByVal dwReserved As Long, ByVal lpfnCB As Long) As Long

Private Declare Function GetTickCount Lib "kernel32" () As Long
Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)
Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Private Declare Function MultiByteToWideChar Lib "kernel32" (ByVal CodePage As Long, ByVal dwFlags As Long, ByRef lpMultiByteStr As Any, ByVal cchMultiByte As Long, ByVal lpWideCharStr As Long, ByVal cchWideChar As Long) As Long
Private Const CP_UTF8 = 65001

Private Type json_file
    isfile As Boolean
    fwq As String
    Url As String
    lastModified As String
End Type

Private Type json_data
    isdata As Boolean
    name As String
    slug As String
    auctions As String
End Type

Private Type json_ah
    timeLeft As Byte
    ahfrom As Byte
    ispet As Boolean
    auc As String
    item As String
    owner As String
    bid As String
    buyout As String
    quantity As String
    rand As String
    seed As String
    petSpeciesId As String
    petBreedId As String
    petLevel As String
    petQualityId As String
End Type
Dim ch As New kVBJSON

Public Function DownloadFile(Url As String, LocalFilename As String, ReWrite As Long) As Boolean
If Url = "" Or LocalFilename = "" Then DownloadFile = False:: Exit Function
If Filelong(LocalFilename) > 10 And ReWrite = 0 Then DownloadFile = True:: Exit Function

Dim lngRetVal As Long
lngRetVal = URLDownloadToFile(0, Url, LocalFilename, 0, 0)
If lngRetVal = 0 Then
    DownloadFile = True
    DeleteUrlCacheEntry Url
End If
End Function

Public Function FileIsR(FileName As String) As Boolean
On Error GoTo NotExist
    Dim objWMIService, colProcessList, objProcess
    Dim file As String
    If InStrRev(FileName, "\", -1, vbTextCompare) Then file = Mid$(FileName, InStrRev(FileName, "\", -1, vbTextCompare) + 1)
    If Len(file) < 4 Or Filelong(FileName) < 10 Then GoTo NotExist
    Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
    Set colProcessList = objWMIService.ExecQuery _
    ("Select * from Win32_Process Where Name='" & file & "'")
    For Each objProcess In colProcessList
        FileIsR = True
    Exit For
    Next
    Exit Function
NotExist:
    FileIsR = False
End Function

Public Function Filelong(FileName As String) As Long
    Filelong = -1
    On Error GoTo NotExist
    Filelong = FileLen(FileName)
    Exit Function
NotExist:
End Function
Private Sub cmdEXIT_Click()
    Dim msgRes As VbMsgBoxResult
    
    If is_downing = True Then
        msgRes = MsgBox("�������أ��Ƿ��˳�?", vbQuestion + vbYesNo + vbDefaultButton2, "�˳�")
        If msgRes = vbNo Then Exit Sub
    End If
    
    If is_runing = True Then
        msgRes = MsgBox("�������У��Ƿ��˳�?", vbQuestion + vbYesNo + vbDefaultButton2, "�˳�")
        If msgRes = vbNo Then Exit Sub
    End If
    
    Unload Me
    End
End Sub

Private Sub cmdGET_Click()
    On Error GoTo CuoWu
    If is_downing = True Then Exit Sub
    If txtURL.Text = "" Or savefile.Text = "" Or filetext.Text = "" Then Exit Sub
    If Dir(savefile.Text) = "" Then Exit Sub
    proctext.Text = "0.0%"
    timetext.Text = "00:00:00"
    ProgressBar1.Value = 0
    is_downing = True
    Label3.Caption = "Download starting ..."
    StartDownLoad txtURL.Text, savefile.Text & "\" & filetext.Text
    Exit Sub
CuoWu:
    MsgBox "Try Download error!!!"
End Sub


Private Sub cmdRUN_Click()
    On Error GoTo CuoWu
    
    If is_runing = True Then Exit Sub
    
    For n = 0 To 5
         If Dir(set_str(n)) = "" Then
            setform.Show 1, Me
            Exit Sub
         End If
    Next
    
    For n = 1 To 4
         If Not FileIsR(set_str(n)) And n <> 2 Then
            Shell set_str(n), vbMinimizedNoFocus
         End If
    Next
    
    Dim rc As Long, ts As String, i As Long, k As Long, r_url As String
    Dim fp As String, fo As String
    
    r_url = "http://www.battlenet.com.cn//api/wow/auction/data/"
    
    rc = ch.parse_UTF(set_str(0), "base_set|MySQL_set|log_set|task", 4, 1)
    
    If rc = 4 Then
        ts = ch.Getkv(3)
    Else
        MsgBox "error cfg : " & set_str(0)
    End If
    
    fo = "123"
    Dim bh As New kVBJSON
    rc = bh.parse_str(ch.Getkv(0), "JSON_path", 1)
    If rc = 1 Then fo = bh.Getkv(0)
    If fo = "" Then fo = "JSON"
    MsgBox fo
    
    rc = ch.Class_Clear()
    rc = ch.parse_str(ts, "info", 1)
    If rc = 1 Then ts = ch.Getkv(0)
    rc = ch.Class_Clear()
    rc = ch.parse_str(ts, "is|name", 1)
    
    savefile.Text = Left$(set_str(0), InStrRev(set_str(0), "\") - 1) & "\temp"
    
    If Not ch.FolderExists(savefile.Text) Then MkDir (savefile.Text)
    
    Do
        If rc = 2 And ch.Getkv(0) = "1" Then
            txtURL.Text = r_url & ch.Getkv(1)
            filetext.Text = ch.Getkv(1) & ".json"
            Me.Refresh
            DoEvents
            k = 0
            fp = savefile.Text & "\" & filetext.Text
            fo = Left$(set_str(0), InStrRev(set_str(0), "\") - 1) & "\JSON\" & filetext.Text
            Do While Not DownloadFile(txtURL.Text, fp, 1)
                k = k + 1
                DoEvents
                If k > 10 Then MsgBox "Download to file error!":: Exit Do
            Loop
            
            k = check_file(fp, fo)
        End If
        If ch.can_next Then
            rc = ch.nextArray()
        Else
            Exit Do
        End If
    Loop
    
    Exit Sub
CuoWu:
    MsgBox "Try Run error!!!"
End Sub
Public Function check_file(fq As String, fo As String) As Long
    If ch.FileExists(fp) Then
    
    End If
    



End Function


Private Sub cmdRead_Click()

    cd.ShowOpen
    Dim jfile As json_file
    If cd.FileName <> "" Then
        jfile = read_json_file(cd.FileName)

        ' MsgBox jfile.fwq & jfile.url & jfile.lastModified
    End If

End Sub
Private Sub cmdDATA_Click()

    cd.ShowOpen

    If cd.FileName <> "" Then

        read_json_data cd.FileName

        ' MsgBox jfile.fwq & jfile.url & jfile.lastModified
    End If

End Sub

Private Function read_json_file(FileName As String) As json_file
    On Error GoTo CuoWu
    Dim str As String, a As Long, b As Long, Index As Long
    Index = 0
    Dim jf As json_file
    jf.fwq = midkl(FileName, InStrRev(FileName, "\"), InStrRev(FileName, "."))
    str = ReadTextFile(FileName, 4)

    If midkl(str, 0, 1) <> "{" Then GoTo CuoWu
    Index = Index + 1
    a = InStr(Index, str, ":")
    If skipstr(midkl(str, 1, a)) = "files" Then jf.isfile = True
    Index = a + 1

    b = InStr(Index, str, "{")
    a = InStr(Index, str, ":")
    If skipstr(midkl(str, b, a)) = "url" Then
        Index = a + 1
        b = InStr(Index, str, ",")
        jf.Url = skipstr(midkl(str, a, b))
        Index = b + 1
    End If

    a = InStr(Index, str, ":")

    If skipstr(midkl(str, b, a)) = "lastModified" Then
        Index = a + 1
        b = InStr(Index, str, "}")
        jf.lastModified = skipstr(midkl(str, a, b))
    End If

    read_json_file = jf
    Exit Function
CuoWu:
    'MsgBox "json_file error!!!"
    read_json_file = jf
End Function
Private Function read_json_data(FileName As String) As Long
    On Error GoTo CuoWu
    Dim str As String, a As Long, b As Long, Index As Long, f As Long, fs As Long, ah_count As Long
    Index = 0
    Dim jd As json_data, t_file As String

    t_file = midkl(FileName, InStrRev(FileName, "\"), InStrRev(FileName, "."))

    ah_count = 0
    fs = 4
    str = UTF8_Decode(FileName, fs)

    If midkl(str, 0, 1) <> "{" Then GoTo CuoWu

    Index = Index + 1
    a = InStr(Index, str, ":")
    If skipstr(midkl(str, 1 + 2, a)) = "realm" Then jd.isdata = True

    Index = a + 1

    b = InStr(Index, str, "{")
    a = InStr(Index, str, ":")
    If skipstr(midkl(str, b, a)) = "name" Then
        Index = a + 1
        b = InStr(Index, str, ",")
        jd.name = skipstr(midkl(str, a, b))
        Index = b + 1
    End If

    a = InStr(Index, str, ":")

    If skipstr(midkl(str, b, a)) = "slug" Then
        Index = a + 1
        b = InStr(Index, str, "}")
        jd.slug = skipstr(midkl(str, a, b))
        Index = b + 1
    End If

    a = InStr(Index, str, ":")
    jd.auctions = skipstr(midkl(str, b + 3, a))
    Index = a + 1
    b = InStr(Index, str, ":")
    If skipstr(midkl(str, a + 1, b)) = "auctions" Then
        Index = b + 1
        Index = InStr(Index, str, "{")

        If jd.auctions = "alliance" Then
            f = 1
        ElseIf jd.auctions = "horde" Then
            f = 2
        ElseIf jd.auctions = "neutral" Then
            f = 3
        Else
            f = 0
        End If
    End If

    ah_count = ah_count + 1
    b = read_json_ah(str, Index, f)

    Index = InStr(b + 1, str, "{")
    a = InStr(Index + 1, str, "}")
    If a = 0 Then
        str = UTF8_Decode(FileName, fs + Index)
        fs = fs + Index
        Index = 1
    End If

    a = InStr(Index + 1, str, "{")

    If a - Index = 14 Then

    End If
    Do While fs
    Loop

    Exit Function
CuoWu:
    'MsgBox "json_data error!!!"
    read_json_data = 0
End Function
Private Function read_json_ah(str As String, Index As Long, fb As Long) As Long
    On Error GoTo CuoWu

    Dim a As Long, b As Long
    Dim time_str As String
    Dim jah As json_ah

    If Mid$(str, Index, 1) <> "{" Then GoTo CuoWu

    a = InStr(Index, str, ":")
    b = Index
    Index = a + 1
    If Mid$(str, b + 2, a - b - 3) = "auc" Then
        b = InStr(Index, str, ",")
        jah.auc = Mid$(str, a + 1, b - a - 1)
        Index = b + 1
        jah.ahfrom = fb
    End If

    a = InStr(Index, str, ":")
    Index = a + 1
    If Mid$(str, b + 2, a - b - 3) = "item" Then
        b = InStr(Index, str, ",")
        jah.item = Mid$(str, a + 1, b - a - 1)
        Index = b + 1
    End If

    a = InStr(Index, str, ":")
    Index = a + 1
    If Mid$(str, b + 2, a - b - 3) = "owner" Then
        b = InStr(Index, str, ",")
        jah.owner = skipstr(midkl(str, a, b))
        Index = b + 1
    End If

    a = InStr(Index, str, ":")
    Index = a + 1
    If Mid$(str, b + 2, a - b - 3) = "bid" Then
        b = InStr(Index, str, ",")
        jah.bid = Mid$(str, a + 1, b - a - 1)
        Index = b + 1
    End If

    a = InStr(Index, str, ":")
    Index = a + 1
    If Mid$(str, b + 2, a - b - 3) = "buyout" Then
        b = InStr(Index, str, ",")
        jah.buyout = Mid$(str, a + 1, b - a - 1)
        Index = b + 1
    End If

    a = InStr(Index, str, ":")
    Index = a + 1
    If Mid$(str, b + 2, a - b - 3) = "quantity" Then
        b = InStr(Index, str, ",")
        jah.quantity = Mid$(str, a + 1, b - a - 1)
        Index = b + 1
    End If

    a = InStr(Index, str, ":")
    If Mid$(str, b + 2, a - b - 3) = "timeLeft" Then
        Index = a + 1
        b = InStr(Index, str, ",")
        time_str = Mid$(str, a + 2, b - a - 3)
        If time_str = "VERY_LONG" Then
            jah.timeLeft = 4
        ElseIf time_str = "LONG" Then
            jah.timeLeft = 3
        ElseIf time_str = "MEDIUM" Then
            jah.timeLeft = 2
        ElseIf time_str = "SHORT" Then
            jah.timeLeft = 1
        Else
            jah.timeLeft = 0
        End If
        Index = b + 1
    End If

    a = InStr(Index, str, ":")
    Index = a + 1
    If Mid$(str, b + 2, a - b - 3) = "rand" Then
        b = InStr(Index, str, ",")
        jah.rand = Mid$(str, a + 1, b - a - 1)
        Index = b + 1
    End If

    a = InStr(Index, str, ":")
    Index = a + 1
    If Mid$(str, b + 2, a - b - 3) = "seed" Then
        b = InStr(Index, str, ",")
        jah.seed = Mid$(str, a + 1, b - a - 1)
        Index = b + 1
    End If

    a = InStr(Index, str, ":")
    If Mid$(str, b + 2, a - b - 3) = "quantity" Then
        Index = a + 1
        b = InStr(Index, str, ",")
        jah.quantity = Mid$(str, a + 1, b - a - 1)
        Index = b + 1
    End If

    a = InStr(Index, str, ":")
    Index = a + 1
    If Mid$(str, b + 2, a - b - 3) = "petSpeciesId" Then
        b = InStr(Index, str, ",")
        jah.petSpeciesId = Mid$(str, a + 1, b - a - 1)
        Index = b + 1
    End If

    a = InStr(Index, str, ":")
    Index = a + 1
    If Mid$(str, b + 2, a - b - 3) = "petBreedId" Then
        b = InStr(Index, str, ",")
        jah.petBreedId = Mid$(str, a + 1, b - a - 1)
        Index = b + 1
    End If

    a = InStr(Index, str, ":")
    Index = a + 1
    If Mid$(str, b + 2, a - b - 3) = "petLevel" Then
        b = InStr(Index, str, ",")
        jah.petLevel = Mid$(str, a + 1, b - a - 1)
        Index = b + 1
    End If

    a = InStr(Index, str, ":")
    Index = a + 1
    If Mid$(str, b + 2, a - b - 3) = "petQualityId" Then
        b = InStr(Index, str, "}")
        jah.petQualityId = Mid$(str, a + 1, b - a - 1)
        jah.ispet = True
    End If

    MsgBox jah.owner
    read_json_ah = b

    Exit Function
CuoWu:
    'MsgBox "json_ah error!!!"
    read_json_ah = 0
End Function
Private Function midkl(str As String, a As Long, b As Long) As String
    Dim c As Long
    If a > b Then c = a:: a = b:: b = c
    If (b - 1 - a) > 0 Then
        midkl = Mid$(str, a + 1, b - 1 - a)
    Else
        midkl = Mid$(str, a + 1, 1)
    End If
End Function
Private Function skipstr(str As String) As String
    Dim st As String, spo As Long
    st = Trim$(str)
    spo = InStrRev(st, Chr$(34))
    Do While spo = Len(st)
        st = Left$(st, Len(st) - 1)
        spo = InStrRev(st, Chr$(34))
        st = Trim$(st)
    Loop
    spo = InStrRev(st, Chr$(34), 1)
    Do While spo = 1
        st = Right$(st, Len(st) - 1)
        spo = InStrRev(st, Chr$(34), 1)
        st = Trim$(st)
    Loop
    st = Trim$(st)
    skipstr = st
End Function
Private Function midkl2(str As String, a As Long, b As Long) As String
    midkl2 = Mid$(str, a + 2, b - 3 - a)
End Function
Private Function skipstr2(str As String) As String
    skipstr2 = str
    If InStrRev(skipstr2, Chr$(34)) = Len(skipstr2) Then skipstr2 = Left$(skipstr2, Len(skipstr2) - 1)
    If InStrRev(skipstr2, Chr$(34), 1) = 1 Then skipstr2 = Right$(skipstr2, Len(skipstr2) - 1)
End Function

'���ļ�������
Private Function GetFile(FileName As String, offset As Long) As String
    On Error Resume Next
    Dim i As Integer, BB() As Byte
    If Dir(FileName) = "" Then Exit Function
    i = FreeFile

    Open FileName For Binary As #i
    Seek #i, offset
    If LOF(i) - offset < MAX_FILE_BUFF Then
        ReDim BB(FileLen(FileName) - 1 - offset)
    Else
        ReDim BB(MAX_FILE_BUFF)
    End If

    Get #i, , BB
    Close #i
    GetFile = BB
End Function

'����: ��Utf8�ַ�ת����ANSI�ַ�
Public Function UTF8_Decode(FileName As String, offset As Long) As String
    On Error Resume Next
    Dim sUTF8 As String
    Dim lngUtf8Size As Long
    Dim strBuffer As String
    Dim lngBufferSize As Long
    Dim lngResult As Long
    Dim bytUtf8() As Byte
    Dim n As Long
    sUTF8 = GetFile(FileName, offset)

    If LenB(sUTF8) = 0 Then Exit Function
    On Error GoTo EndFunction
    bytUtf8 = sUTF8
    lngUtf8Size = UBound(bytUtf8) + 1
    lngBufferSize = lngUtf8Size * 2
    strBuffer = String$(lngBufferSize, vbNullChar)
    lngResult = MultiByteToWideChar(CP_UTF8, 0, bytUtf8(0), _
                lngUtf8Size, StrPtr(strBuffer), lngBufferSize)
    If lngResult Then
        UTF8_Decode = Left$(strBuffer, lngResult)
    End If
EndFunction:

End Function

Public Function ReadTextFile(sFilePath As String, offset As Long) As String
    On Error Resume Next

    Dim handle As Integer
    If LenB(Dir$(sFilePath)) > 0 Then
        If offset > FileLen(sFilePath) Then ReadTextFile = "":: Exit Function

        handle = FreeFile
        Open sFilePath For Binary As #handle
        Seek #handle, offset
        If LOF(handle) - offset < MAX_FILE_BUFF Then
            ReadTextFile = Space$(LOF(handle) - offset)
        Else
            ReadTextFile = Space$(MAX_FILE_BUFF)
        End If
        Get #handle, , ReadTextFile
        Close #handle

    End If

End Function

Private Sub cmdSET_Click()
    setform.Show 1, Me
End Sub
Public Function GetAry(ByVal Index As Long) As String
    '����һ������������ӷ�������
    GetAry = set_str(Index)
End Function
Public Function SaveAry(ByVal Index As Long, strin As String) As Long
    '����һ������������ӷ�������
    set_str(Index) = strin
    SaveAry = Index
End Function

Private Sub Form_Load()
    For n = 0 To 5
        set_str(n) = GetSetting("AHscan", "Settings", "set_" & n, "")
    Next n

    txtURL.Text = GetSetting("AHscan", "Settings", "url", "www.baidu.com")
    savefile.Text = GetSetting("AHscan", "Settings", "save_dir", App.Path & "\download")
    is_downing = False
    save_dir = ""
    proctext.Text = "0.0%"
    timetext.Text = "00:00:00"
    ProgressBar1.Value = 0

    Label3.Caption = "Ready..."
End Sub
Private Sub Form_Unload(Cancel As Integer)
    Unload setform
    For n = 0 To 5
        SaveSetting "AHscan", "Settings", "set_" & n, set_str(n)
    Next n
    SaveSetting "AHscan", "Settings", "url", txtURL.Text
    SaveSetting "AHscan", "Settings", "save_dir", savefile.Text
End Sub

Private Sub StartDownLoad(Geturl As String, Savetofile As String)
    save_dir = Savetofile
    s_time = Now
    Inet1.Execute Geturl, "get"
End Sub

Private Sub Inet1_StateChanged(ByVal State As Integer)

    On Error GoTo CuoWu
    'State = 12 ʱ���� GetChunk ������������������Ӧ��
    Dim k As Long, n As Long, s As Long, o As Long

    Dim vtData() As Byte
    Select Case State
        Case icError '11
        '���ִ���ʱ������ ResponseCode �� ResponseInfo��
        vtData = Inet1.ResponseCode & ":" & Inet1.ResponseInfo
        MsgBox "return 11,net error: " & Inet1.ResponseCode & ":" & Inet1.ResponseInfo
        Case icResponseCompleted ' 12
        Dim bDone As Boolean
        bDone = False
        'ȡ�õ�һ���顣
        vtData() = Inet1.GetChunk(1024, 1)
        DoEvents
        Open save_dir For Binary Access Write As #1     '���ñ���·���ļ���

        ' ��ʼ����
        '��ȡ�����ļ�����
        'MsgBox Len(Inet1.GetHeader("Content-Length"))
        If Len(Inet1.GetHeader("Content-Length")) > 0 Then ProgressBar1.Max = CLng(Inet1.GetHeader("Content-Length"))

        'ѭ���ֿ�����
        k = GetTickCount()
        n = 0
        s = 0
        o = 0
        Do While Not bDone
            n = n + 1
            Put #1, Loc(1) + 1, vtData()
            vtData() = Inet1.GetChunk(1024, 1)
            DoEvents
            ProgressBar1.Value = Loc(1)   '���ý���������
            proctext.Text = CStr(Format$(ProgressBar1.Value / (ProgressBar1.Max + 1) * 100, "0.0")) & "%"
            Label3.Caption = "Downloading now: " & ByteToString(ProgressBar1.Value) & " /" & ByteToString(ProgressBar1.Max)
            timetext.Text = SecondToString(DateDiff("s", s_time, Now)) & " >> " & ByteToString(s) & "/s"
            If Loc(1) >= ProgressBar1.Max Then bDone = True
            If n = 70 Then
                s = (ProgressBar1.Value - o) * 1000 \ (GetTickCount() - k)
                k = GetTickCount()
                o = ProgressBar1.Value
                n = 0
            End If
        Loop

        Close #1
        Label3.Caption = "Download Finished,Total: " & ByteToString(ProgressBar1.Max)
        proctext.Text = "100%"
        k = DateDiff("s", s_time, Now)
        timetext.Text = SecondToString(k) & " ++ " & ByteToString(ProgressBar1.Max \ k) & "/s"
        is_downing = False
        save_dir = ""
    End Select

    Exit Sub
CuoWu:
    MsgBox "Downloading error!!!"
End Sub


Private Sub txtURL_Change()
    proctext.Text = "0.0%"
    timetext.Text = "00:00:00"
    ProgressBar1.Value = 0
    filetext.Text = ""
    Label3.Caption = ""
End Sub


Private Function ByteToString(ByVal iSize As Long) As String
    '//Byte ->Byte KB or MB
    Dim c       As Double
    If iSize < 1024 Then
        ByteToString = CStr(iSize) & " Byte"
    Else
        c = iSize / 1024& / 1024&
        If c > 1 Then
            ByteToString = CStr(Format$(c, "###,###,##0.0")) & " MB"
        Else
            c = iSize / 1024&
            ByteToString = CStr(Format$(c, "###,###,##0.0")) & " KB"
        End If
    End If
    If iSize <= 0 Then
        ByteToString = "NaN Byte"
    End If
End Function
Private Function SecondToString(ByVal secn As Long) As String
    '//Second ->00::00::00
    If secn > 3600 Then
        SecondToString = Format$(secn \ 3600, "00")
        secn = secn Mod 3600
    Else
        SecondToString = "00"
    End If
    If secn > 60 Then
        SecondToString = SecondToString & ":" & Format$(secn \ 60, "00")
        secn = secn Mod 60
    Else
        SecondToString = SecondToString & ":" & "00"
    End If
    SecondToString = SecondToString & ":" & Format$(secn, "00")
End Function