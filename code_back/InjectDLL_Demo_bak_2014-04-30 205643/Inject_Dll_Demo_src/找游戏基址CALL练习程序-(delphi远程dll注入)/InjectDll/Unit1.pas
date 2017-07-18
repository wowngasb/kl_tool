unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, EnumStuff;

type
  TForm3 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    ComboBox1: TComboBox;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    InjectID: Cardinal;
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

function EnableDebugPriv: Boolean;
var
  hToken: THANDLE;
  tp: TTokenPrivileges;
  rl: Cardinal;
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

function InjectDll(const DllFullPath: string;
  const dwRemoteProcessId: Cardinal): boolean;
var
  hRemoteProcess, hRemoteThread: THANDLE;
  pszLibFileRemote: Pointer;
  pszLibAFilename: PwideChar;
  pfnStartAddr: TFNThreadStartRoutine;
  memSize, WriteSize, lpThreadId: Cardinal;
begin
  result := FALSE;
  // ����Ȩ�ޣ�ʹ������Է����������̵��ڴ�ռ�
  if EnableDebugPriv then
  begin
    //��Զ���߳� PROCESS_ALL_ACCESS ������ʾ�����е�Ȩ��
    hRemoteProcess := OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwRemoteProcessId);

    try

      // Ϊע���dll�ļ�·�������ڴ��С,����ΪWideChar,��Ҫ��2
      GetMem(pszLibAFilename, Length(DllFullPath) * 2 + 1);
      // ֮����Ҫת���� WideChar, ����Ϊ��DLLλ���������ַ���·����ʱ�������
      StringToWideChar(DllFullPath, pszLibAFilename, Length(DllFullPath) * 2 + 1);
      // ���� pszLibAFilename �ĳ��ȣ�ע�⣬�����ֽ�Ϊ��Ԫ�ĳ���
      memSize := (1 + lstrlenW(pszLibAFilename)) * sizeof(WCHAR);

      //ʹ��VirtualAllocEx������Զ�̽��̵��ڴ��ַ�ռ����DLL�ļ����ռ�
      pszLibFileRemote := VirtualAllocEx(hRemoteProcess, nil, memSize,
        MEM_COMMIT, PAGE_READWRITE);

      if Assigned(pszLibFileRemote) then
      begin

        //ʹ��WriteProcessMemory������DLL��·����д�뵽Զ�̽��̵��ڴ�ռ�
        if WriteProcessMemory(hRemoteProcess, pszLibFileRemote,
          pszLibAFilename, memSize, WriteSize) and (WriteSize = memSize) then
        begin

          lpThreadId := 0;
          // ����LoadLibraryW����ڵ�ַ
          pfnStartAddr := GetProcAddress(LoadLibrary('Kernel32.dll'), 'LoadLibraryW');
          // ����Զ���߳�LoadLbraryW,ͨ��Զ���̵߳��ô����µ��߳�
          hRemoteThread := CreateRemoteThread(hRemoteProcess, nil, 0,
            pfnStartAddr, pszLibFileRemote, 0, lpThreadId);

          // ���ִ�гɹ����ء�True;
          if (hRemoteThread <> 0) then
            result := TRUE;

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

function UnInjectDll(const DllFullPath: string;
  const dwRemoteProcessId: Cardinal): Boolean;
// ����ע���ȡ��ע����ʵ����ֻ࣬�����еĺ�����ͬ����
var
  hRemoteProcess, hRemoteThread: THANDLE;
  pszLibFileRemote: pchar;
  pszLibAFilename: PwideChar;
  pfnStartAddr: TFNThreadStartRoutine;
  memSize, WriteSize, lpThreadId, dwHandle: Cardinal;
begin
  result := FALSE;

  // ����Ȩ�ޣ�ʹ������Է����������̵��ڴ�ռ�
  if EnableDebugPriv then
  begin
    //��Զ���߳� PROCESS_ALL_ACCESS ������ʾ�����е�Ȩ��
    hRemoteProcess := OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwRemoteProcessId);

    try

      // Ϊע���dll�ļ�·�������ڴ��С,����ΪWideChar,��Ҫ��2
      GetMem(pszLibAFilename, Length(DllFullPath) * 2 + 1);
      // ֮����Ҫת���� WideChar, ����Ϊ��DLLλ���������ַ���·����ʱ�������
      StringToWideChar(DllFullPath, pszLibAFilename, Length(DllFullPath) * 2 + 1);
      // ���� pszLibAFilename �ĳ��ȣ�ע�⣬�����ֽ�Ϊ��Ԫ�ĳ���
      memSize := (1 + lstrlenW(pszLibAFilename)) * sizeof(WCHAR);

      //ʹ��VirtualAllocEx������Զ�̽��̵��ڴ��ַ�ռ����DLL�ļ����ռ�
      pszLibFileRemote := VirtualAllocEx(hRemoteProcess, nil, memSize,
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
          WaitForSingleObject(hRemoteThread, INFINITE);
          // ���GetModuleHandle�ķ���ֵ,����dwHandle������
          GetExitCodeThread(hRemoteThread, dwHandle);

          // ����FreeLibrary����ڵ�ַ
          pfnStartAddr := GetProcAddress(LoadLibrary('Kernel32.dll'), 'FreeLibrary');
          // ʹĿ����̵���FreeLibrary��ж��DLL
          hRemoteThread := CreateRemoteThread(hRemoteProcess, nil, 0,
            pfnStartAddr, Pointer(dwHandle), 0, lpThreadId);
          // �ȴ�FreeLibraryж�����
          WaitForSingleObject(hRemoteThread, INFINITE);

          // ���ִ�гɹ����ء�True;
          if hRemoteProcess <> 0 then
            result := TRUE;

          // �ͷ�Ŀ�����������Ŀռ�
          VirtualFreeEx(hRemoteProcess, pszLibFileRemote, Length(DllFullPath) + 1, MEM_DECOMMIT);
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

procedure TForm3.Button1Click(Sender: TObject);
var
  Process : TProcessList;
  i : integer;
begin
  //������ EnumStuff��Ԫ��һ�����������Եõ���ǰ�����б�
  Process := GetProcessList;
  for I := Low(Process) to High(Process) do
  begin
    if LowerCase(Process[i].name) = LowerCase(ComboBox1.Text) then
    begin
      InjectDll(ExtractFilePath(ParamStr(0))+'DLL.dll', Process[i].pid);
      InjectID := Process[i].pid;
      exit;
    end;
  end;
end;

procedure TForm3.Button2Click(Sender: TObject);
begin
  UnInjectDll(ExtractFilePath(ParamStr(0)) + 'DLL.dll', InjectID);
end;

procedure TForm3.Button3Click(Sender: TObject);
var
  Process : TProcessList;
  i : integer;
begin
  //������ EnumStuff��Ԫ��һ�����������Եõ���ǰ�����б�
  Process := GetProcessList;
  for I := Low(Process) to High(Process) do
    if LowerCase(Process[i].name) = LowerCase(ComboBox1.Text) then
    begin
      InjectDll(ExtractFilePath(ParamStr(0))+'DLL.dll', Process[i].pid);
      InjectID := Process[i].pid;
      exit;
    end;
end;

procedure TForm3.FormCreate(Sender: TObject);
var
  Process : TProcessList;
  i : integer;
begin
  //������ EnumStuff��Ԫ��һ�����������Եõ���ǰ�����б�
  Process := GetProcessList;
  for I := Low(Process) to High(Process) do
    ComboBox1.Items.Add(Process[i].name);
  ComboBox1.ItemIndex:= 0;
end;

end.

