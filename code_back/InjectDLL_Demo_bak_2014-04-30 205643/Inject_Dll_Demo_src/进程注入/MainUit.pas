unit MainUit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  function HookOn(lpHwnd:HWND;lpType:Longint):Longint;stdcall;external 'Hook32.dll' name 'HookOn';
  function HookOff:Boolean;stdcall;external 'Hook32.dll' name 'HookOff';

implementation

{$R *.dfm}
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //hookoff;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  h1:HWND;
begin
  h1:=FindWindow(NIL,'�û���½-A�ɡ�����ʽ����');//���Ǵ��ڵľ����Ҫ�Լ��ҵ�����д�롣
  HookOn(h1,WH_KEYBOARD);
end;

end.
