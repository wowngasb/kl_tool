Attribute VB_Name = "html2doc"

Public Function html2docex(opendir As String, savedir As String) As Boolean
On Error Resume Next
 
Dim strTitle As String, strWord
Dim nn As Long, keys As Long, fin As Long
Dim MyName() As String
Dim wrd
Set wrd = CreateObject("Word.Application")
wrd.Visible = False
wrd.application.Activate
Dim fs As Object

Set fs = application.FileSearch

With fs
.LookIn = opendir '����Ҫ���ҵ���ʼĿ¼
.FileType = msoFileTypeWebPages  'msoFileTypeExcelWorkbooks Ҫ���ҵ��ļ�����
.SearchSubFolders = True '�Ƿ������Ŀ¼
.Execute '�������������ִ�в���
End With
ReDim MyName(1 To fs.FoundFiles.Count)

For fin = 1 To fs.FoundFiles.Count

If fin > 3 Then Kill (fs.FoundFiles(fin - 2))

 MyName(fin) = fs.FoundFiles(fin)  '�������ҵ����ļ�
'MyName(i)  ����
'MyName(i) = "kk (" & CStr(i) & ").doc"
'ChangeFileOpenDirectory (opendir)

Documents.Open FileName:=MyName(fin), _
ConfirmConversions:=False, ReadOnly:=False, AddToRecentFiles:=False, _
PasswordDocument:="", PasswordTemplate:="", Revert:=False, _
WritePasswordDocument:="", WritePasswordTemplate:="", Format:= _
wdOpenFormatAuto, XMLTransform:=""

    strTitle = ""
    strTitle = ""
     If (ActiveDocument.Words.Count > 48) Then
     Dim enter As Long, ii As Long
     enter = 0
         For ii = 48 To ActiveDocument.Words.Count
             strWord = ActiveDocument.Words.Item(ii)
             keys = Asc(strWord)
             If keys = 13 And strTitle <> "" Then
                   Exit For
             End If
          If keys <> 13 And keys <> 63 And keys <> -24159 Then
              If strTitle = "" Then
                  If keys < 0 Or keys > 32 Then strTitle = strTitle + strWord
              Else
                  strTitle = strTitle + strWord
              End If
              If (Len(strTitle) > 100) Then Exit For
          End If
         Next ii
     Else
          strTitle = "kk (" & CStr(fin) & ")"
     End If

'MyName(i) ���  wdFormatWebArchive  mht��ʽ  wdFormatDocument  doc��ʽ
GetTitle = Replace(strTitle, vbCrLf, "")
MyName(fin) = GetTitle & ".doc"

ChangeFileOpenDirectory (savedir)


'�Ѳ������ҳ������ʽ��ͼƬתΪ��ǶͼƬ������word��
Dim i As InlineShape, j As Shape, N As Long

application.ScreenUpdating = False '�ر���Ļˢ��
For Each i In ActiveDocument.InlineShapes '�������в����InlineShapeͼ�ζ���
    If i.Type = wdInlineShapeLinkedPicture Then
        i.LinkFormat.SavePictureWithDocument = True
        i.LinkFormat.BreakLink '�Ͽ�Դ�ļ���ָ��ͼƬ֮�������
        N = N + 1 '����
    End If
Next i
For Each j In ActiveDocument.Shapes '�������в����Shapeͼ�ζ���
    If j.Type = msoLinkedPicture Then
        j.LinkFormat.SavePictureWithDocument = True
        j.LinkFormat.BreakLink '�Ͽ�Դ�ļ���ָ��ͼƬ֮������ӡ�
        N = N + 1 '����
    End If
Next j
'MsgBox "��ת��������ͼƬ" & N & "��!"
'Application.ScreenUpdating = True '�ָ���Ļˢ��

ActiveDocument.SaveAs FileName:=MyName(fin), FileFormat:= _
wdFormatDocument, LockComments:=False, Password:="", AddToRecentFiles:= _
True, WritePassword:="", ReadOnlyRecommended:=False, EmbedTrueTypeFonts:= _
False, SaveNativePictureFormat:=False, SaveFormsData:=False, _
SaveAsAOCELetter:=False

ActiveWindow.Close

Next fin

End Function


'Microsoft.Office.Interop.Word.WdSaveFormat�Ǹ�ö�٣����Ķ������£�
'����û��wdFormatDocumentDefault�����ǲ��Ƕ�д��Default��
'wdFormatDocument
'wdFormatDOSText
'wdFormatDOSTextLineBreaks
'wdFormatEncodedText
'wdFormatFilteredHTML
'wdFormatHTML
'wdFormatRTF
'wdFormatTemplate
'wdFormatText
'wdFormatTextLineBreaks
'wdFormatUnicodeText
'wdFormatWebArchive
'wdFormatXML



