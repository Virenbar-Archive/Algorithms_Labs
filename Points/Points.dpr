program Points;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {MainWindow};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainWindow, MainWindow);
  Application.Run;
end.
