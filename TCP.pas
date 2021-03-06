unit TCP;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ScrollBox,
  FMX.Memo, FMX.Edit, FMX.Controls.Presentation, FMX.StdCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient;

type
  TForm1 = class(TForm)
    IdTCPClient1: TIdTCPClient;
    Button1: TButton;
    TxtMessage: TEdit;
    TxtServer: TEdit;
    TxtResults: TMemo;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  DRThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute;
  end;

var
  Form1: TForm1;
  TDRThread: DRThread;
  timer_count: Integer;
  str1: string;

implementation

{$R *.fmx}
function ServerHello (Host: string): RawByteString;
var
 Pack: string;
 begin
   Pack:= Format (
    '<?xml version=''1.0'' encoding=''UTF-8''?> ' +
    '<stream:stream to=''%S'' ' +
    'xmlns=''jabber:client'' ' +
    'xmlns:stream=''http://etherx.jabber.org/streams'' ' +
    'xml:l=''ru'' ' +
    'version=''1.0''>',
    [Host]);
  Result := UTF8Encode(Pack);
  Pack := EmptyStr;
 end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i: Integer;
  str: string[255];
begin
  if Button1.Text = 'Connect' then
  begin
    IdTCPClient1:= IdTCPClient1.Create(nil);
    str1 := TxtServer.Text;
    IdTCPClient1.Host := str1;
    IdTCPClient1.ConnectTimeout := 5000;
    IdTCPClient1.ReadTimeout := 1000;
    IdTCPClient1.Connect;
    IdTCPClient1.Socket.WriteLn(ServerHello(TxtServer.Text));
    if IdTCPClient1.Connected then
      TxtResults.Lines.Add(TimeToStr(Now)+ ' ' + TxtMessage.Text);
    TxtMessage.Text := '';
    TDRThread.Execute;
    Button1.Text:='Disconnect';
  end
  else
//  begin
//    IdTCPClient1.Disconnect;
//    Timer1.Enabled := false;
//    Button1.Text:='Connect';
//    timer_count:=0;
//  end;
end;

procedure DRThread.Execute;
var
  i: Integer;
begin
  with Form1 do
  begin
    Timer1.Enabled := true;
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  DRThread.Create;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if not IdTCPClient1.Connected then
  begin
    IdTCPClient1.Host := str1;
    IdTCPClient1.Connect;
    IdTCPClient1.Socket.WriteLn(TxtMessage.Text);
  end;
  if not IdTCPClient1.IOHandler.InputBufferIsEmpty then
  begin
    TxtResults.Lines.Add('Received: ' + IdTCPClient1.IOHandler.InputBufferAsString);
  end;
  inc(timer_count);
  if (timer_count > 10) then
  begin
    Timer1.Enabled := false;
    Button1.Text:='Connect';
    IdTCPClient1.Disconnect;
    timer_count:=0;
  end;
end;

end.
