unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button3: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
type
  //��Ϸ���Զ���
  GameObj = class
    Blood: integer; //Ѫֵ
    Magic: integer; //ħ��ֵ
    BloodMax: integer; //Ѫֵ����
    MagicMax: integer; //ħ��ֵ����
    x: single; //X���� float;
    h: single; //h����
    y: single; //Y����
    grade: integer; //�ȼ�
  end;

  //�ֿ�ṹ
  TStor = record
    item:array[0..3] of integer;   //�ֿ���Ʒ����
  end;

  //��ɫ����
  Roleobj = class
  public
    N1: integer;
    N2: integer;
    roleA: GameObj;  //�����еĶ��� ������ N ����ַ
    Stor:TStor;      //�����еĽṹ ������ N ����ַ ��������������飩
  public
    constructor Create;
    destructor Destroy;
    function addvalues(val:Integer):byte; stdcall;   //���ڲ����ҵ�CALL   ������C/C++ ������ֵ��ʽ����
  end;
var
  Form1: TForm1;

  Role: Roleobj;   //�����һ�ַ�Ľ�ɫ����

implementation

{$R *.dfm}

constructor Roleobj.Create;
var i:integer;
begin
  inherited Create;
  for i:= 0 to 3 do
  begin
    Stor.item[i]:= i+$100;
  end;
  roleA:= GameObj.Create;
end;

destructor Roleobj.Destroy;
begin
  roleA.Free;
  inherited Destroy;
end;

function Roleobj.addvalues(val:Integer):byte; stdcall;
begin
    roleA.Blood := roleA.Blood - val;
    roleA.Magic := roleA.Magic - val;
    roleA.BloodMax := roleA.BloodMax + val;
    roleA.MagicMax := roleA.MagicMax + val;
    MessageBox(0,PChar('ִ�н�ɫ���� roleA.Blood = '+IntToStr(roleA.Blood)), 'OK��', 0);
    Result:= 100;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if Role = nil then
  begin
    role := Roleobj.Create; //��̬����һ���ڴ��role
    role.roleA.Blood := $272;
    role.roleA.Magic := $271;
    role.roleA.BloodMax := $300;
    role.roleA.MagicMax := $300;
    role.roleA.x := 100.1;
    role.roleA.h := 10.2;
    role.roleA.y := 200.3;
    Memo1.Lines.Add('role.roleA.Blood = $272');
    Memo1.Lines.Add('role.roleA.Magic = $271');
    Memo1.Lines.Add('role.roleA.BloodMax = $300');
    Memo1.Lines.Add('role.roleA.MagicMax = $300;');
  end;

end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if role <> nil then
  begin
    Role.addvalues($4);  //����CALl
    Memo1.Lines.Add('-----------------------------------');
    Memo1.Lines.Add('role.roleA.Magic = ' + IntToStr(role.roleA.Magic));
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if  Role<> nil then
    role.Free;
end;

end.

 