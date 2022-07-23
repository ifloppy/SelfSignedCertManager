unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  lclintf;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Label1: TLabel;
    Label2: TLabel;
    ListBox1: TListBox;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure refreshRootTitle();
begin
  if (FileExists(Application.Location+'certs\RootIssuer.pvk')
  and FileExists(Application.Location+'certs\RootIssuer.cer')) then
     begin
       Form1.Label2.Caption:='找到根证书文件';
       Form1.Label2.Font.Color:=clGreen;
     end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  CN, O, OU: string;
begin
  if MessageDlg('重写根证书', '你确定要这么做吗?这将会把现有证书删除!', mtConfirmation,
  [ mbNo, mbYes], 0) = mrNo then exit;
  CN:=InputBox('CN', '证书名称', '');
  O:=InputBox('O', '组织', '');
  OU:=InputBox('OU', '组织单元', '');
  DeleteFile(Application.Location+'certs\RootIssuer.pvk');
  DeleteFile(Application.Location+'certs\RootIssuer.cer');
  SysUtils.ExecuteProcess(Application.Location+'makecert',
  '-n "CN='+CN+',O='+O+',OU='+OU+'" '+
  '-r -sv "'+Application.Location+'certs\RootIssuer.pvk" "'+
  Application.Location+'certs\RootIssuer.cer"', []);
  refreshRootTitle();
end;

procedure TForm1.Button2Click(Sender: TObject);
var
   sr : TSearchRec;
   directory: string;
begin
  ListBox1.Clear;
  directory:=Application.Location+'certs';
   try
     if FindFirst(IncludeTrailingPathDelimiter(directory) + '*.*', faDirectory, sr) < 0 then
       Exit
     else
     repeat
       if ((sr.Attr and faDirectory <> 0) AND (sr.Name <> '.') AND (sr.Name <> '..')) then
         ListBox1.Items.Add(sr.Name);
     until FindNext(sr) <> 0;
   finally
     SysUtils.FindClose(sr) ;
   end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  CN, O, OU: string;
begin
  CN:=InputBox('CN', '证书名称', '');
  O:=InputBox('O', '组织', '');
  OU:=InputBox('OU', '组织单元', '');
  if DirectoryExists(Application.Location+'certs\'+CN)
  then RmDir(Application.Location+'certs\'+CN);
  MkDir(Application.Location+'certs\'+CN);


  SysUtils.ExecuteProcess(Application.Location+'makecert',
  '-n "CN='+CN+',O='+O+',OU='+OU+'" '+
  '-iv "'+Application.Location+'certs\RootIssuer.pvk" -ic "'+
  Application.Location+'certs\RootIssuer.cer" '+
  '-sv "'+Application.Location+'certs\'+CN+'\cert.pvk" "'+
  Application.Location+'certs\'+CN+'\cert.cer"', []);


  SysUtils.ExecuteProcess(Application.Location+'cert2spc',
  '"'+Application.Location+'certs\'+CN+'\cert.cer" '+
  '"'+Application.Location+'certs\'+CN+'\cert.spc"', []);


  SysUtils.ExecuteProcess(Application.Location+'pvk2pfx',
  '-pvk "'+Application.Location+'certs\'+CN+'\cert.pvk" -spc '+
  '"'+Application.Location+'certs\'+CN+'\cert.spc" -pfx '+
  '"'+Application.Location+'certs\'+CN+'\cert.pfx"', []);

  Button2Click(nil);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if ListBox1.GetSelectedText = '' then Exit;
  if not DirectoryExists(Application.Location+'certs\'+ListBox1.GetSelectedText)
  then exit;
  RmDir(Application.Location+'certs\'+ListBox1.GetSelectedText);
  Button2Click(nil);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  if ListBox1.GetSelectedText = '' then Exit;
  if not DirectoryExists(Application.Location+'certs\'+ListBox1.GetSelectedText)
  then exit;
  OpenDocument(Application.Location+'certs\'+ListBox1.GetSelectedText);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  OpenURL('https://www.iruanp.com');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  if not DirectoryExists(Application.Location+'certs') then
     CreateDir(Application.Location+'certs');
  refreshRootTitle();
  Button2Click(nil);
  Label1.Caption := 'iruanp.com'+LineEnding+
  'Floppy Beta Studio 软盘君制作'+LineEnding+
  '自豪地使用LazarusIDE进行开发';
end;



end.

