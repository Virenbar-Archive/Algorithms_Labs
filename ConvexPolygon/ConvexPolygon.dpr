program ConvexPolygon;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {MainWindow},
  BTree in 'BTree.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainWindow, MainWindow);
  Application.Run;
end.
