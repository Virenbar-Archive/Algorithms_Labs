unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,System.Diagnostics,Math,System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.EditBox, FMX.NumberBox,
  FMX.Menus;

type
  TMainWindow = class(TForm)
    Pole: TImage;
    PointsMax: TNumberBox;
    CountResult: TEdit;
    MainMenu: TMainMenu;
    Lab1Menu: TMenuItem;
    Lab1Generate: TMenuItem;
    Computation: TAniIndicator;
    StatusBar: TStatusBar;
    Time1: TEdit;
    Label1: TLabel;
    Lab1Stupid: TMenuItem;
    Lab1SmartPre: TMenuItem;
    Lab1Smart: TMenuItem;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Time2: TEdit;
    Time3: TEdit;
    RadioS: TRadioButton;
    RadioC: TRadioButton;
    RadioG: TRadioButton;
    procedure PointsMaxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Lab1GenerateClick(Sender: TObject);
    procedure PoleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PoleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure Lab1StupidClick(Sender: TObject);
    procedure Lab1SmartPreClick(Sender: TObject);
    procedure Lab1SmartClick(Sender: TObject);
    procedure PoleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
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
  TSingleArray = Array of single;
var
  MainWindow: TMainWindow;
  Points: Array of TPointF;
  MaxX,MaxY: integer;
  PointsCount:integer;
  Stopwatch:TStopwatch;
  Selector:TSelector;

  GSortX,GSortY:TSingleDynArray;
  DominationPoints:Array of array of integer;

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

  {
  Был затуп
  3-4
  | |
  2-1
  Точки прямоугольника
  }

  Selector.P1:=PointF(Selector.Right,Selector.Bottom);
  Selector.P2:=PointF(Selector.Left,Selector.Bottom);
  Selector.P3:=PointF(Selector.Left,Selector.Top);
  Selector.P4:=PointF(Selector.Right,Selector.Top);
end;

function SortArray(Sort:TSingleDynArray): TSingleDynArray;
var
  i,j:integer;
  temp:single;
begin
  for i := 0 to Length(Sort)-1 do
    for j := 0 to Length(Sort)-2-i do
      if Sort[j]>Sort[j+1] then
      begin
        temp:=Sort[j+1];
        Sort[j+1]:=Sort[j];
        Sort[j]:=temp;
      end;
  SetLength(Result,Length(Sort));
  Result:=Sort;
end;

function BinarySearch(Sort:TSingleDynArray;Value:Single):Integer;
var
  L,H:Integer;
  mid:integer;
begin
  L:=0;
  H:=Length(Sort)-1;
  while H-L>1 do
  begin
    mid:=(H+L) div 2;
    if Value<=Sort[mid] then H:=mid
    else L:=mid
  end;
  if Value<Sort[L] then
    Result:=L
  else
    Result:=H;
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

  Computation.Enabled:=false;
end;

procedure DrawPoints(); forward;

procedure GeneratePointsSquare();
var
  i:Integer;
  x,y:Extended;
begin
  SetLength(Points,PointsCount);
  for i := 0 to PointsCount-1 do
  begin
    X:=Random(MaxX-100)+50;
    Y:=Random(MaxY-100)+50;
    Points[i]:=PointF(X,Y);
  end;
  DrawPoints();
end;

procedure GeneratePointsCircle();
var
  i:Integer;
  x,y,R,Fi:Extended;
begin
  SetLength(Points,PointsCount);
  for i := 0 to PointsCount-1 do
  begin
    R:=Random((MaxY div 2)-100);
    Fi:=Random(360+1);
    Points[i]:=PointF(MaxX/2+R*sin(DegToRad(Fi)),MaxY/2+R*cos(DegToRad(Fi)));
  end;
  DrawPoints();
end;

procedure GeneratePointsGauss();
var
  i:Integer;
  x,y:Extended;
begin
  SetLength(Points,PointsCount);
  for i := 0 to PointsCount-1 do
  begin
    X:=math.RandG(MaxX/2,MaxX/8);
    Y:=math.RandG(MaxY/2,MaxY/8);
    Points[i]:=PointF(X,Y);
  end;
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
    for i := 0 to PointsCount-1 do
      //DrawLine(TempPoints[i],TempPoints[i],100);
      DrawLine(Points[i],Points[i],100);
    DrawRect(Selector.RectAB,0,0,AllCorners,100);
    EndScene;
  end;
end;

procedure StupidCompute();
var
  i,Count,T,Time: Integer;
begin
  //MainWindow.Computation.Enabled:=true;
  //MainWindow.Computation.Visible:=true;

  Stopwatch.Reset;
  Stopwatch.Start;
  for T := 1 to 100000 do
  begin
    Count:=0;
    for i := 0 to PointsCount-1 do
      if math.InRange(Points[i].X,Selector.Left,Selector.Right) and math.InRange(Points[i].Y,Selector.Top,Selector.Bottom)
      then Inc(Count);
  end;
  Stopwatch.Stop;
  MainWindow.Time1.Text:=FloatToStr(Stopwatch.ElapsedMilliseconds/100000/1000);
  MainWindow.CountResult.Text:=IntToStr(Count);

  //MainWindow.Computation.Enabled:=false;
  //MainWindow.Computation.Visible:=false;
end;

procedure SmartComputePre();
var
  i,j,c,Count:integer;
  SortX,SortY:TSingleDynArray;
begin
  Stopwatch.Reset;
  Stopwatch.Start;

  SetLength(SortX,PointsCount+1);
  SetLength(SortY,PointsCount+1);
  for i := 0 to PointsCount-1 do begin
    SortX[i]:=Points[i].X;
    SortY[i]:=Points[i].Y;
  end;
  SortX[PointsCount]:=MaxX;
  SortY[PointsCount]:=MaxY;
  SortX:=SortArray(SortX);
  SortY:=SortArray(SortY);

  SetLength(DominationPoints,PointsCount+1,PointsCount+1);
  for i := 0 to Length(SortX)-1 do
    for j := 0 to Length(SortY)-1 do begin
      Count:=0;
      for c := 0 to PointsCount-1 do
        if (Points[c].X<SortX[i]) and (Points[c].Y<SortY[j]) then Inc(Count);

      DominationPoints[i][j]:=Count;
    end;

  Stopwatch.Stop;
  GSortX:=SortX;
  GSortY:=SortY;
  MainWindow.Time2.Text:=FloatToStr(Stopwatch.ElapsedMilliseconds/1000);
end;

procedure SmartCompute();
var
  T,DomP1,DomP2,DomP3,DomP4:Integer;
begin
  Stopwatch.Reset;
  Stopwatch.Start;
  for T := 1 to 1000000 do
  begin
    DomP1:=DominationPoints[BinarySearch(GSortX,Selector.P1.X)][BinarySearch(GSortY,Selector.P1.Y)];
    DomP2:=DominationPoints[BinarySearch(GSortX,Selector.P2.X)][BinarySearch(GSortY,Selector.P2.Y)];
    DomP3:=DominationPoints[BinarySearch(GSortX,Selector.P3.X)][BinarySearch(GSortY,Selector.P3.Y)];
    DomP4:=DominationPoints[BinarySearch(GSortX,Selector.P4.X)][BinarySearch(GSortY,Selector.P4.Y)];
  end;
  Stopwatch.Stop;
  MainWindow.Time3.Text:=FloatToStr(Stopwatch.ElapsedMilliseconds/1000000/1000);
  //MainWindow.Time3.Text:=IntToStr(Stopwatch.ElapsedTicks);
  MainWindow.CountResult.Text:=IntToStr(DomP1-DomP2-DomP4+DomP3);
  //TArray.BinarySearch() ;
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
//Lab1
procedure TMainWindow.Lab1GenerateClick(Sender: TObject);
begin
  //StatusBar.tab
  PointsMax.ResetFocus;
  if RadioS.IsChecked then GeneratePointsSquare();
  if RadioC.IsChecked then GeneratePointsCircle();
  if RadioG.IsChecked then GeneratePointsGauss();
end;
procedure TMainWindow.Lab1StupidClick(Sender: TObject);
begin
  StupidCompute();
end;
procedure TMainWindow.Lab1SmartPreClick(Sender: TObject);
begin
  SmartComputePre();
end;
procedure TMainWindow.Lab1SmartClick(Sender: TObject);
begin
  SmartCompute();
end;
//--

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

procedure TMainWindow.PoleMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  SetBorder;
end;

end.



