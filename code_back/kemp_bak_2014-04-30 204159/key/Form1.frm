VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3090
   ClientLeft      =   165
   ClientTop       =   855
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3090
   ScaleWidth      =   4680
   StartUpPosition =   3  '����ȱʡ
   Begin VB.Menu m_syso 
      Caption         =   "����"
      WindowList      =   -1  'True
      Begin VB.Menu m_sys 
         Caption         =   "����(&O)"
         Index           =   0
         Shortcut        =   ^O
      End
      Begin VB.Menu m_sys 
         Caption         =   "-"
         Index           =   1
      End
      Begin VB.Menu m_sys 
         Caption         =   "��С(&E)"
         Index           =   2
         Shortcut        =   ^E
      End
      Begin VB.Menu m_sys 
         Caption         =   "-"
         Index           =   3
      End
      Begin VB.Menu m_sys 
         Caption         =   "��ԭ(&R)"
         Index           =   4
         Shortcut        =   ^D
      End
      Begin VB.Menu m_sys 
         Caption         =   "-"
         Index           =   5
      End
      Begin VB.Menu m_sys 
         Caption         =   "�˳�(&T)"
         Index           =   6
         Shortcut        =   ^T
      End
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'�������:
Private MinFlag As Boolean

' ����      : ���ڴ�С�ı�ʱ
' ����˵��  : ���ڴ�С�ı䡣
' ��ע      :
Private Sub Form_Resize()
    '�жϴ����Ƿ���С��״̬�������ǰ���С����Ŧ���һ�η���Resize�¼�
    If IsIconic(Me.hWnd) <> 0 And MinFlag = False Then
        MinFlag = True
        Me.Visible = False '���ش���
        '������ͼ�����֪ͨ��
        Call Icon_Add(Me.hWnd, Me.Caption, Me.Icon, 0)
    End If
End Sub

' ����      : �������ͼ��
' ����˵��  : �������ͼ�ꡣ
' ��ע      :
Private Sub Form_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
    Dim l
    l = x \ 15
'    Form1.Caption = Button & "  " & Shift & "  " & x & "  " & y & "   " & l

    '���֪ͨ��ͼ�꣬������Ҽ�ʱ���������˵�

    Select Case l
        Case WM_LBUTTONDOWN:    showfrm
        Case WM_RBUTTONDOWN:    Me.PopupMenu m_syso
    End Select
         
    '���֪ͨ��ͼ�꣬��������ʱ����֪ͨ��ͼ���Ϊ�����ͼ��
'
End Sub

Private Sub m_sys_Click(Index As Integer)
    Select Case Index
        Case 0:
            MsgBox "��Į���ʵ�֣�ҵ�ఴ����"
        Case 2:
            If MinFlag = False Then
                MinFlag = True
                Me.Visible = False '���ش���
                '������ͼ�����֪ͨ��
                Call Icon_Add(Me.hWnd, Me.Caption, Me.Icon, 0)
            End If
        Case 4: '������"��ԭ"�˵�ʱ
            If MinFlag = True Then
                showfrm
            End If
        Case 6: '������"�˳�"�˵�ʱ
            Dim ret As Integer
            ret = MsgBox("��ȷ��Ҫ�˳�ϵͳ��", vbYesNo)
            If ret = vbYes Then
                Call Icon_Del(Form1.hWnd, 0) 'ɾ��֪ͨ��ͼ��
                Unload Me
                End '�˳�����
            End If
    End Select
End Sub

Private Sub showfrm()
            If MinFlag = False Then
                Exit Sub
            End If
            Form1.Show '��������
            Form1.WindowState = 0
            Call Icon_Del(Form1.hWnd, 0) 'ɾ��֪ͨ��ͼ��
            Form1.SetFocus
            MinFlag = False
End Sub


