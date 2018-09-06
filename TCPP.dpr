program TCPP;

uses
  System.StartUpCopy,
  FMX.Forms,
  TCP in 'TCP.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
