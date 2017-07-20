unit Unit1;

interface
uses
  uProcInfo,
  //ProcessInfo,
  StrUtils,
  ShellAPI,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, EnumStuff, Grids, ValEdit, ComCtrls, ExtCtrls;

type
  TForm3 = class(TForm)
    ע�����: TButton;
    ȡ��ע��: TButton;
    edit_proc_path: TEdit;
    label_proc_path: TLabel;
    label_dll_path: TLabel;
    edit_dll_path: TEdit;
    OpenDialog1: TOpenDialog;
    edit_proc_pid: TEdit;
    edit_dll_pid: TEdit;
    ˢ��: TButton;
    ListView1: TListView;
    ��������: TButton;
    Timer1: TTimer;
    edit_dll_addr: TEdit;
    edit_timer_set: TEdit;
    procedure ע�����Click(Sender: TObject);
    procedure ȡ��ע��Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure label_dll_pathClick(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
    procedure ˢ��Click(Sender: TObject);
    procedure ��������Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure edit_dll_pidChange(Sender: TObject);
    procedure edit_timer_setChange(Sender: TObject);
    procedure label_proc_pathClick(Sender: TObject);
  private
    { Private declarations }
    //InjectID : Cardinal;

  public
    { Public declarations }


  end;

function CustomSortProc(Item1, Item2: TListItem; ParamSort: Integer): Integer;stdcall;



var
  Form3: TForm3;
  m_bSort: Boolean = TRUE;

implementation

{$R *.dfm}
function LeftStrEx(in_str: string; in_len: Integer) : String;
begin
  if (in_len > 0) then
    begin
      Result := LeftStr(in_str, in_len);
    end
  else
    begin
      Result := LeftStr(in_str, Length(in_str) + in_len);
  end;
end;

function StrIndexOfList(in_list: TStringList; in_str: String) : Integer;
begin
  try
    begin
      Result := in_list.IndexOf(in_str);
    end;
  except
      Result := -2;
  end;
end;

function EnableDebugPriv : Boolean;
var
  hToken : THANDLE;
  tp : TTokenPrivileges;
  rl : Cardinal;
begin
  result := false;

  //�򿪽������ƻ�
  OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken);

  //��ý��̱���ΨһID
  if LookupPrivilegeValue(nil, 'SeDebugPrivilege', tp.Privileges[0].Luid) then
  begin
    tp.PrivilegeCount := 1;
    tp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    //����Ȩ��
    result := AdjustTokenPrivileges(hToken, False, tp, sizeof(tp), nil, rl);
  end;
end;

function InjectDll(const DllFullPath : string;
  const dwRemoteProcessId : Cardinal): Integer;
var
  hRemoteProcess, hRemoteThread,dwHandle: THANDLE;
  pszLibFileRemote : Pointer;
  pszLibAFilename: PwideChar;
  pfnStartAddr : TFNThreadStartRoutine;
  memSize, WriteSize, lpThreadId : Cardinal;
begin
  result := 0;
  // ����Ȩ�ޣ�ʹ������Է����������̵��ڴ�ռ�
  if EnableDebugPriv then
  begin
    //��Զ���߳� PROCESS_ALL_ACCESS ������ʾ�����е�Ȩ��
    hRemoteProcess := OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwRemoteProcessId );

    try

      // Ϊע���dll�ļ�·�������ڴ��С,����ΪWideChar,��Ҫ��2
      GetMem(pszLibAFilename, Length(DllFullPath) * 2 + 1);
      // ֮����Ҫת���� WideChar, ����Ϊ��DLLλ���������ַ���·����ʱ�������
      StringToWideChar(DllFullPath, pszLibAFilename, Length(DllFullPath) * 2 + 1);
      // ���� pszLibAFilename �ĳ��ȣ�ע�⣬�����ֽ�Ϊ��Ԫ�ĳ���
      memSize := (1 + lstrlenW(pszLibAFilename)) * sizeof(WCHAR);

      //ʹ��VirtualAllocEx������Զ�̽��̵��ڴ��ַ�ռ����DLL�ļ����ռ�
      pszLibFileRemote := VirtualAllocEx( hRemoteProcess, nil, memSize,
        MEM_COMMIT, PAGE_READWRITE);

      if Assigned(pszLibFileRemote) then
      begin

        //ʹ��WriteProcessMemory������DLL��·����д�뵽Զ�̽��̵��ڴ�ռ�
        if WriteProcessMemory(hRemoteProcess, pszLibFileRemote,
          pszLibAFilename, memSize, WriteSize) and (WriteSize = memSize) then
        begin

          lpThreadId := 0;
          dwHandle := 0;
          // ����LoadLibraryW����ڵ�ַ
          pfnStartAddr := GetProcAddress(LoadLibrary('Kernel32.dll'), 'LoadLibraryW');
          // ����Զ���߳�LoadLbraryW,ͨ��Զ���̵߳��ô����µ��߳�
          hRemoteThread := CreateRemoteThread(hRemoteProcess, nil, 0,
            pfnStartAddr, pszLibFileRemote, 0, lpThreadId);

          // �ȴ�LoadLibraryW �������
          WaitForSingleObject( hRemoteThread, INFINITE );
          // ���LoadLibraryW�ķ���ֵ,����dwHandle������
          GetExitCodeThread(hRemoteThread, dwHandle);

          // ���ִ�гɹ����ء�True;
          if (dwHandle <> 0) then
            result := dwHandle;

          // �ͷ�Ŀ�����������Ŀռ�
          VirtualFreeEx(hRemoteProcess, pszLibFileRemote, Length(DllFullPath)+1, MEM_DECOMMIT);
          // �ͷž��
          CloseHandle(hRemoteThread);
        end;
      end;
    finally
      // �ͷž��
      CloseHandle(hRemoteProcess);
    end;
  end;          
end;

function UnInjectDll(const DllFullPath : string;
  const dwRemoteProcessId : Cardinal) : Integer;
// ����ע���ȡ��ע����ʵ����ֻ࣬�����еĺ�����ͬ����
var
  hRemoteProcess, hRemoteThread : THANDLE;
  pszLibFileRemote : pchar;
  pszLibAFilename: PwideChar;
  pfnStartAddr : TFNThreadStartRoutine;
  memSize, WriteSize, lpThreadId, dwHandle, dwFreeHandle : Cardinal;
begin
  result := 0;

  // ����Ȩ�ޣ�ʹ������Է����������̵��ڴ�ռ�
  if EnableDebugPriv then
  begin
    //��Զ���߳� PROCESS_ALL_ACCESS ������ʾ�����е�Ȩ��
    hRemoteProcess := OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwRemoteProcessId );

    try

      // Ϊע���dll�ļ�·�������ڴ��С,����ΪWideChar,��Ҫ��2
      GetMem(pszLibAFilename, Length(DllFullPath) * 2 + 1);
      // ֮����Ҫת���� WideChar, ����Ϊ��DLLλ���������ַ���·����ʱ�������
      StringToWideChar(DllFullPath, pszLibAFilename, Length(DllFullPath) * 2 + 1);
      // ���� pszLibAFilename �ĳ��ȣ�ע�⣬�����ֽ�Ϊ��Ԫ�ĳ���
      memSize := (1 + lstrlenW(pszLibAFilename)) * sizeof(WCHAR);

      //ʹ��VirtualAllocEx������Զ�̽��̵��ڴ��ַ�ռ����DLL�ļ����ռ�
      pszLibFileRemote := VirtualAllocEx( hRemoteProcess, nil, memSize,
        MEM_COMMIT, PAGE_READWRITE);

      if Assigned(pszLibFileRemote) then
      begin

        //ʹ��WriteProcessMemory������DLL��·����д�뵽Զ�̽��̵��ڴ�ռ�
        if WriteProcessMemory(hRemoteProcess, pszLibFileRemote,
          pszLibAFilename, memSize, WriteSize) and (WriteSize = memSize) then
        begin

          // ����GetModuleHandleW����ڵ�ַ
          pfnStartAddr := GetProcAddress(LoadLibrary('Kernel32.dll'), 'GetModuleHandleW');
          //ʹĿ����̵���GetModuleHandleW�����DLL��Ŀ������еľ��
          hRemoteThread := CreateRemoteThread(hRemoteProcess, nil, 0,
            pfnStartAddr, pszLibFileRemote, 0, lpThreadId);
          // �ȴ�GetModuleHandle�������
          WaitForSingleObject(hRemoteThread,INFINITE);
          // ���GetModuleHandle�ķ���ֵ,����dwHandle������
          GetExitCodeThread(hRemoteThread, dwHandle);

          // ����FreeLibrary����ڵ�ַ
          pfnStartAddr := GetProcAddress(LoadLibrary('Kernel32.dll'), 'FreeLibrary');
          // ʹĿ����̵���FreeLibrary��ж��DLL
          hRemoteThread := CreateRemoteThread(hRemoteProcess, nil, 0,
            pfnStartAddr, Pointer(dwHandle), 0, lpThreadId);
          // �ȴ�FreeLibraryж�����
          WaitForSingleObject( hRemoteThread, INFINITE );

          // ���FreeLibrary �ķ���ֵ,����dwFreeHandle������
          GetExitCodeThread(hRemoteThread, dwFreeHandle);

          // ���ִ�гɹ����ء�True;
          if (dwFreeHandle <> 0) then
            result := dwHandle;

          // �ͷ�Ŀ�����������Ŀռ�
          VirtualFreeEx(hRemoteProcess, pszLibFileRemote, Length(DllFullPath)+1, MEM_DECOMMIT);
          // �ͷž��
          CloseHandle(hRemoteThread);
        end;
      end;
    finally
      // �ͷž��
      CloseHandle(hRemoteProcess);
    end;
  end;
end;

procedure GetProcInfo(list_view: TListView; dll_pid: TEdit);
var
  List:TStringList;
  I,J,Index:Integer;
  AItem:TListItem;
  AInfo:TProcInfo;
begin
  J := 0;
  List := TStringList.Create;
  try
  RunningProcessesList(List);

  if (dll_pid.Text <> '') and (StrIndexOfList(List, dll_pid.Text)=-1) then
    begin
      dll_pid.Text := '';
    end;

  list_view.Items.BeginUpdate;
  //list_view.Items.Clear();

  For I := 0 To list_view.Items.Count-1 do
  begin
     AItem := list_view.Items.Item[J];
     Index := StrIndexOfList(List, AItem.SubItems.Strings[0]);
     If Index<>-1 then  //�Ѵ���,�޸�����
     begin
       AInfo := TProcInfo(List.Objects[Index]);
       AItem.Caption := AInfo.ProcName;
       If AItem.SubItems.Count>3 then
       begin
         AItem.SubItems.Strings[0] := IntToStr(AInfo.PID);
         AItem.SubItems.Strings[1] := FormatDateTime('hh:nn:ss',AInfo.CPUTime);
         AItem.SubItems.Strings[2] := IntToStr(AInfo.MemSize)+' K';
         AItem.SubItems.Strings[3] := AInfo.FullName;
       end;
       AInfo.Free;
       List.Delete(Index); //ɾ��
       INC(J);
     end else    //�����Ѳ�����,ɾ��
         begin
           list_view.Items.Delete(J);
           DEC(J);
         end;
  end;

  For I := 0 To List.Count-1 do
    begin
      AInfo := TProcInfo(List.Objects[I]);
      AItem := list_view.Items.Add;
      AItem.Caption := AInfo.FileName;
      AItem.SubItems.Add(IntToStr(AInfo.PID));
      AItem.SubItems.Add(FormatDateTime('hh:nn:ss',AInfo.CPUTime));
      AItem.SubItems.Add(IntToStr(AInfo.MemSize)+' K');
      AItem.SubItems.Add(AInfo.FullName);
      AInfo.Free;
    end;

  finally
    list_view.Items.EndUpdate;
    List.Free;
  end;

end;

procedure TForm3.ע�����Click(Sender: TObject);
var
  Process : TProcessList;
  i,dll_addr : integer;
begin
  //������ EnumStuff��Ԫ��һ�����������Եõ���ǰ�����б�
  Process := GetProcessList;
  for i := Low(Process) to High(Process) do
    if ((Integer(Process[i].pid) = StrToInt(edit_proc_pid.Text)) and (edit_dll_pid.Text = '') and  FileExists(edit_dll_path.Text)) then
      begin
        dll_addr := InjectDll(edit_dll_path.Text, Process[i].pid);
        if ( dll_addr > 0) then
          begin
            edit_dll_pid.Text := IntToStr(Process[i].pid);
            edit_dll_addr.Text := Format('$%x',[dll_addr])
          end
        else
          begin
            ShowMessage('ע��  ʧ�ܣ���');
          end;
      end;
end;

procedure TForm3.ȡ��ע��Click(Sender: TObject);
begin
  if ((edit_dll_pid.Text <> '' ) and (StrToInt(edit_dll_pid.Text) > 0 ) and FileExists(edit_dll_path.Text)) then
    begin
      if (UnInjectDll(edit_dll_path.Text, StrToInt(edit_dll_pid.Text)) > 0) then
        begin
          edit_dll_pid.Text := '';
        end
      else
        begin
          ShowMessage('ȡ��ע��ʧ�ܣ���');
        end;
    end;
end;

procedure TForm3.ˢ��Click(Sender: TObject);
begin
  GetProcInfo(ListView1, edit_dll_pid);
end;


procedure TForm3.��������Click(Sender: TObject);
Const
  WarnMsg= '����: ��ֹ���̻ᵼ�²�ϣ�������Ľ����'+#10#13
          +'�������ݶ�ʧ��ϵͳ���ȶ����ڱ���ֹǰ��'+#10#13
          +'���̽�û�л��ᱣ����״̬�����ݡ�ȷʵ'+#10#13
          +'����ֹ�ý�����?';
var
  Process : TProcessList;
  i : integer;
begin
  //������ EnumStuff��Ԫ��һ�����������Եõ���ǰ�����б�
  Process := GetProcessList;
  for i := Low(Process) to High(Process) do
    if (edit_proc_pid.Text <> '') and (Integer(Process[i].pid) = StrToInt(edit_proc_pid.Text)) and
       (Application.MessageBox(WarnMsg,'�������������',MB_YESNO+MB_ICONWARNING)=IDYES ) then
      begin
          KillProcess(Process[i].pid);
          edit_proc_path.Text := '';
          edit_proc_pid.Text := '';
      end;
end;


procedure TForm3.edit_dll_pidChange(Sender: TObject);
begin
  if (edit_dll_pid.Text = '') then edit_dll_addr.Text := '';
end;

procedure TForm3.edit_timer_setChange(Sender: TObject);
begin
  if (edit_timer_set.Text <> '') and (StrToInt(edit_timer_set.Text) > 0) then Timer1.Interval := StrToInt(edit_timer_set.Text)*100;
end;

procedure TForm3.FormCreate(Sender: TObject);

begin
  GetProcInfo(ListView1, edit_dll_pid);
  edit_dll_path.Text := ExtractFilePath(ParamStr(0))+'DLL.dll';
  edit_dll_pid.Text := '';
  m_bSort := TRUE;
end;

procedure TForm3.label_dll_pathClick(Sender: TObject);
begin
  if OpenDialog1.InitialDir = '' then  OpenDialog1.InitialDir := ExtractFilePath(ParamStr(0));
  OpenDialog1.Filter := 'dll�ļ�(*.dll)|*.dll|�����ļ�(*.*)|*.*';
  if opendialog1.execute and FileExists(OpenDialog1.FileName) then edit_dll_path.Text := OpenDialog1.FileName;
end;


procedure TForm3.label_proc_pathClick(Sender: TObject);
begin
  if (FileExists(edit_proc_path.Text)) then
    ShellExecute(0,'open','Explorer.exe',PChar('/n,/select,'+edit_proc_path.Text ),0,SW_NORMAL);

end;

procedure TForm3.ListView1Click(Sender: TObject);
begin
  if ListView1.Selected <> nil then
    begin
      edit_proc_path.Text := ListView1.Selected.SubItems.Strings[3];
      edit_proc_pid.Text := ListView1.Selected.SubItems.Strings[0];
    end;
end;

procedure TForm3.Timer1Timer(Sender: TObject);
begin
    GetProcInfo(ListView1, edit_dll_pid);
end;



procedure TForm3.ListView1ColumnClick(Sender: TObject;
    Column: TListColumn);
begin
  ListView1.CustomSort(@CustomSortProc, Column.Index);
  m_bSort := not m_bSort;
end;

function CustomSortProc(Item1, Item2: TListItem;
    ParamSort: Integer): Integer; stdcall;
var
    stxt1, stxt2: string;
    txt1, txt2: Integer;
begin
  if (ParamSort <> 0) then
    begin
      try
        txt1 := 0; txt2 := 0;
        stxt1 := (Item1.SubItems.Strings[ParamSort - 1]);
        stxt2 := (Item2.SubItems.Strings[ParamSort - 1]);
        if (ParamSort = 3) then stxt1 := LeftStrEx(stxt1, -2);
        if (ParamSort = 3) then stxt2 := LeftStrEx(stxt2, -2);
        if (ParamSort = 1) or (ParamSort = 3) then txt1 := StrToInt(stxt1);
        if (ParamSort = 1) or (ParamSort = 3) then txt2 := StrToInt(stxt2);
        if m_bSort then
          begin
            Result := CompareText(stxt1, stxt2);
            if (ParamSort = 1) or (ParamSort = 3) then Result := txt1 - txt2;
          end
        else
          begin
            Result := -CompareText(stxt1, stxt2);
            if (ParamSort = 1) or (ParamSort = 3) then Result := -(txt1 - txt2);
        end;
      except
         Result := -1;
      end;
    end
  else
    begin
      if m_bSort then
        begin
          Result := CompareText(Item1.Caption, Item2.Caption);
        end
      else
        begin
        Result := -CompareText(Item1.Caption, Item2.Caption);
      end;
  end;
end;


{function GetProcIndexByStrPID(list:TStringList;str_pid: String): Integer;
var
  i_loop: integer;
begin
  Result := -1;
  For i_loop := 0 To list.Count-1 do
    begin
      if (i_loop = StrToInt(str_pid) ) then
        begin
          Result := i_loop;
        end;
    end;
end;}


end.
