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

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
var
  i: integer;
  str: string[255];
begin
  IdTCPClient1.Host := TxtServer.Text;
  IdTCPClient1.Connect;
  IdTCPClient1.Socket.WriteLn(TxtMessage.Text);
  if IdTCPClient1.Connected then
    TxtResults.Lines.Add(TimeToStr(Now) + TxtMessage.Text);
  TxtMessage.Text := '';
end;

procedure DRThread.Execute;
var
  s: string;
  i: integer;
begin
  with Form1 do
  begin
    while not Terminated do
      if TDRThread.Terminated then
        break;
    if not IdTCPClient1.Connected then
      Exit;
    if IdTCPClient1.IOHandler.InputBufferIsEmpty then
      Exit;
    s := IdTCPClient1.IOHandler.InputBufferAsString;
    TxtResults.Lines.Add('Received: ' + s);
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  DRThread.Create;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  s: string;
begin
  TDRThread.Execute;
end;

end.
