unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,System.Diagnostics,Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.EditBox, FMX.NumberBox,
  FMX.Menus;

type
  TMainWindow = class(TForm)
    Generate: TButton;
    CountPoints: TButton;
    Pole: TImage;
    PointsMax: TNumberBox;
    Edit1: TEdit;
    MainMenu: TMainMenu;
    Lab1Menu: TMenuItem;
    Lab1Generate: TMenuItem;
    Computation: TAniIndicator;
    StatusBar: TStatusBar;
    Edit2: TEdit;
    Label1: TLabel;
    Lab1Stupid: TMenuItem;
    Lab1SmartPre: TMenuItem;
    Lab1Smart: TMenuItem;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure GenerateClick(Sender: TObject);
    procedure PointsMaxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Lab1GenerateClick(Sender: TObject);
    procedure PoleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PoleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure Lab1StupidClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  TSelector = record
    RectAB:TRectF;
    Top,Right,Bottom,Left:Single;
    P1,P2,P3,P4:TPointF;
  end;
var
  MainWindow: TMainWindow;
  Points: Array of TPointF;
  MaxX,MaxY: integer;
  PointsCount:integer;
  Stopwatch:TStopwatch;
  Selector:TSelector;
implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.Windows.fmx MSWINDOWS}
//------------------------------------------------------------------------------
//NaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaN_WATMAN
//------------------------------------------------------------------------------
procedure TMainWindow.PointsMaxChange(Sender: TObject);
begin
  PointsCount:=Trunc(PointsMax.Value);
end;

procedure SetBorder();
begin
  Selector.Left:=Math.MinValue([Selector.RectAB.Left,Selector.RectAB.Right]);
  Selector.Right:=Math.MaxValue([Selector.RectAB.Left,Selector.RectAB.Right]);
  Selector.Top:=Math.MinValue([Selector.RectAB.Top,Selector.RectAB.Bottom]);
  Selector.Bottom:=Math.MaxValue([Selector.RectAB.Top,Selector.RectAB.Bottom]);
end;

//Иницилизация при открытии
procedure TMainWindow.FormCreate(Sender: TObject);
var
  PoleRect:TRectF;
begin
  PointsCount:=Trunc(PointsMax.Value);
  MaxY:=Trunc(Pole.Height);
  MaxX:=Trunc(Pole.Width);

  Pole.Bitmap.Width:=Trunc(Pole.Width);
  Pole.Bitmap.Height:=Trunc(Pole.Height);
  PoleRect.Create(0,0,MaxX,MaxY);

  with Pole.Bitmap.Canvas do
  begin
    //Clear(TAlphaColors.White);
    //Stroke.Color := TColorRec.Black;
    //Stroke.Kind:= TBrushKind.None;
    //Stroke.Thickness := 1;
    BeginScene;
    DrawRect(PoleRect,0,0,AllCorners,100);
    //DrawLine(my_point_1, my_point_2, 1.0);
    EndScene;
  end;
  Selector.RectAB:=RectF(0+20-0.5,0+20-0.5,MaxX-20.5,MaxY-20.5);
  //Computation.Enabled:=true;
end;

procedure DrawPoints(); forward;

procedure GeneratePoints();
var
  i:Integer;
  x,y:Extended;
begin
  SetLength(Points,PointsCount);
  //Stopwatch.Start;
  for i := 1 to PointsCount do
  begin
    X:=Random(MaxX-100)+50-0.5;
    Y:=Random(MaxY-100)+50-0.5;
    Points[i]:=PointF(X,Y);
  end;
  //Stopwatch.Stop;
  //MainWindow.Edit1.Text:=IntToStr(Stopwatch.ElapsedMilliseconds);
  DrawPoints();
end;

procedure DrawPoints();
var
i:Integer;
//TempPoints:Array of TPointF;
begin
  //SetLength(TempPoints,PointsNumber);
  //TempPoints[i]:=PointF(Points[i].X-(Stroke.Thickness/2),Points[i].Y-(Stroke.Thickness/2));
  with MainWindow.Pole.Bitmap.Canvas do
  begin
    BeginScene;
    Clear(TAlphaColors.White);
    //DrawLine(Points[1],Points[5],1);
    for i := 1 to PointsCount do
      //DrawLine(TempPoints[i],TempPoints[i],100);
      DrawLine(Points[i],Points[i],100);
    DrawRect(Selector.RectAB,0,0,AllCorners,100);
    EndScene;
  end;
end;

procedure StupidCompute();
var
  i,Count: Integer;
begin
  //--
  SetBorder();
  Count:=0;
  Stopwatch.Reset;
  Stopwatch.Start;
  for i := 1 to PointsCount do
  //begin
    if math.InRange(Points[i].X,Selector.Left,Selector.Right) and math.InRange(Points[i].Y,Selector.Top,Selector.Bottom)
    then Inc(Count);
  //end;
  Stopwatch.Stop;
  MainWindow.Edit2.Text:=IntToStr(Stopwatch.ElapsedMilliseconds);
  MainWindow.Edit1.Text:=FloatToStr(Count);
end;

procedure SmartComputePre();
begin
  //--
end;

procedure SmartCompute();
begin
  //--
end;

procedure CheckRect();
begin
  SetBorder();
  with MainWindow do
  //Edit2.Text:=FloatToStr(Selector.Left);//FloatToStr(Selector.RectAB.Top);
  //StatusBar.
  //Selector.RectAB.Top
end;

//------------------------------------------------------------------------------
//Кнопки
//------------------------------------------------------------------------------

procedure TMainWindow.GenerateClick(Sender: TObject);
begin
  GeneratePoints();
end;

procedure TMainWindow.Lab1GenerateClick(Sender: TObject);
begin
  //StatusBar.tab
  GeneratePoints();
end;

procedure TMainWindow.Lab1StupidClick(Sender: TObject);
begin
  StupidCompute();
end;

procedure TMainWindow.PoleMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  case Button of
    TMouseButton.mbLeft   : Selector.RectAB.TopLeft:=PointF(X+0.5,Y+0.5);
    TMouseButton.mbRight  : Selector.RectAB.BottomRight:=PointF(X+0.5,Y+0.5);
  end;
  DrawPoints();
end;

procedure TMainWindow.PoleMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
  if ssLeft in Shift then
  begin
    Selector.RectAB.TopLeft:=PointF(X+0.5,Y+0.5);
    DrawPoints();
  end;
  if ssRight in Shift then
  begin
    Selector.RectAB.BottomRight:=PointF(X+0.5,Y+0.5);
    DrawPoints();
  end;
  CheckRect();
end;

end.



