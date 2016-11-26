unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.EditBox, FMX.NumberBox,
  FMX.Menus,
  System.Diagnostics,Math,System.Math.Vectors,System.Generics.Collections,System.Generics.Defaults;

type
  TMainWindow = class(TForm)
    Pole:         TImage;
    PointsMax:    TNumberBox;
    Computation:  TAniIndicator;
    Time1:        TEdit;
    Time2:        TEdit;
    RadioS:       TRadioButton;
    RadioC:       TRadioButton;
    RadioG:       TRadioButton;
    MainMenu:     TMainMenu;
    Lab2Menu:     TMenuItem;
    Lab2Generate: TMenuItem;
    Lab2GiftWrap: TMenuItem;
    Lab2Graham:   TMenuItem;
    //
    procedure PointsMaxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Lab2GenerateClick(Sender: TObject);
    procedure Lab2GiftWrapClick(Sender: TObject);
    procedure Lab2GrahamClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TSingleArray = Array of single;
var
  MainWindow:   TMainWindow;
  Points:       Array of TPointF;
  MaxX,MaxY:    Integer;
  PointsCount:  Integer;
  Stopwatch:    TStopwatch;

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

{
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
//}

{
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
//}

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
  R,Fi:Extended;
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
Temp:TPointF;
begin
  //TempPoints[i]:=PointF(Points[i].X-(Stroke.Thickness/2),Points[i].Y-(Stroke.Thickness/2));
  with MainWindow.Pole.Bitmap.Canvas do
  begin
    BeginScene;
    Clear(TAlphaColors.White);
    for i := 0 to PointsCount-1 do
    begin
      Temp:=PointF(Floor(Points[i].X)+0.5,Floor(Points[i].Y)+0.5);
      //DrawLine(Points[i],Points[i],100);
      DrawLine(Temp,Temp,100);
    end;
    EndScene;
  end;
end;

procedure GiftWrap();
var
  Start,NextP,i :Integer;
  MaxCos,CurCos :Single;
  HullList      :TList<Integer>;
  P1,P2         :TPointF;
  Polygon       :TPolygon;
begin
  HullList:=TList<Integer>.Create();

  Stopwatch.Reset;
  Stopwatch.Start;

  //Начальная точка(левая верхняя)
  Start:=0;
  for i := 1 to PointsCount-1 do
  begin
    if ((Points[i].X<Points[Start].X) or ((Points[i].X=Points[Start].X) and (Points[i].Y<Points[Start].Y))) then Start:=i;
  end;
  HullList.Add(Start);
  //Цикл
  while true do
  begin
    MaxCos:=-1;
    for i := 0 to PointsCount-1 do
    begin
      if ((HullList.Contains(i)) and (i<>Start)) then Continue;//Проверка точки на наличие в оболочке
      if HullList.Capacity=1 then
      begin
        P1:=PointF(0,-1);
        P2:=PointF(Points[i].X-Points[Start].X,Points[i].Y-Points[Start].Y);
      end
      else
      begin
        P1:=PointF(
          Points[HullList.Items[HullList.Count-1]].X-Points[HullList.Items[HullList.Count-2]].X,
          Points[HullList.Items[HullList.Count-1]].Y-Points[HullList.Items[HullList.Count-2]].Y
        );
        P2:=PointF(
          Points[i].X-Points[HullList.Items[HullList.Count-1]].X,
          Points[i].Y-Points[HullList.Items[HullList.Count-1]].Y
        );
      end;
      CurCos:=(P1.X*P2.X+P1.Y*P2.Y)/(sqrt(P1.X*P1.X+P1.Y*P1.Y)*sqrt(P2.X*P2.X+P2.Y*P2.Y));
      if CurCos>MaxCos then
      begin
        NextP:=i;
        MaxCos:=CurCos;
      end;

    end;
    if HullList.Contains(NextP) then break;
    HullList.Add(NextP);

    if false then
    begin
      MainWindow.Pole.Bitmap.Canvas.BeginScene();
      MainWindow.Pole.Bitmap.Canvas.DrawLine(Points[HullList.Items[HullList.Count-2]],Points[HullList.Items[HullList.Count-1]],100);
      MainWindow.Pole.Bitmap.Canvas.EndScene();
      Application.ProcessMessages;
      Sleep(100);
    end;
  end;
  Stopwatch.Stop;
  MainWindow.Time1.Text:=FloatToStr(Stopwatch.ElapsedMilliseconds/1000);

  //{
  SetLength(Polygon,HullList.Count);
  for i := 0 to HullList.Count-1 do
    Polygon[i]:=Points[HullList.Items[i]];
  MainWindow.Pole.Bitmap.Canvas.BeginScene();
  MainWindow.Pole.Bitmap.Canvas.DrawPolygon(Polygon,100);
  MainWindow.Pole.Bitmap.Canvas.EndScene();
  //}
  {
  MainWindow.Pole.Bitmap.Canvas.BeginScene();
  MainWindow.Pole.Bitmap.Canvas.DrawLine(Points[HullList.Items[HullList.Count-1]],Points[HullList.Items[0]],100);
  MainWindow.Pole.Bitmap.Canvas.EndScene();
  }
  HullList.Destroy;
end;

{------------------------------------------------------------------------------}

procedure Graham();
type
  PointAngle = record
    ID:Integer;
    Angle:Single;
  end;
var
  Start,NextP,i :Integer;
  //Cos           :Single;
  Comparer      :IComparer<PointAngle>;
  SortList      :TList<PointAngle>;
  HullList      :TList<Integer>;
  P1,P2         :TPointF;
  CurPoint      :PointAngle;
  Polygon       :TPolygon;
begin
  {Сравниватель по углам}
  Comparer:=TDelegatedComparer<PointAngle>.Create(
  function(const Left, Right: PointAngle): Integer
  begin
    Result := Round(Left.Angle - Right.Angle);
  end
  );
  //---------

  SortList:=TList<PointAngle>.Create(Comparer);
  HullList:=TList<Integer>.Create();

  Stopwatch.Reset;
  Stopwatch.Start;

  //Начальная точка(левая верхняя)
  Start:=0;
  for i := 1 to PointsCount-1 do
  begin
    if ((Points[i].X<Points[Start].X) or ((Points[i].X=Points[Start].X) and (Points[i].Y<Points[Start].Y))) then Start:=i;
  end;
  HullList.Add(Start);

  for i := 0 to PointsCount-1 do
  begin
    if i=HullList[0] then continue;
    P1:=PointF(0,-1);
    P2:=PointF(Points[i].X-Points[Start].X,Points[i].Y-Points[Start].Y);
    //Cos:=(P1.X*P2.X+P1.Y*P2.Y)/(sqrt(P1.X*P1.X+P1.Y*P1.Y)*sqrt(P2.X*P2.X+P2.Y*P2.Y));
    CurPoint.ID:=i;
    CurPoint.Angle:=(P1.X*P2.X+P1.Y*P2.Y)/(sqrt(P1.X*P1.X+P1.Y*P1.Y)*sqrt(P2.X*P2.X+P2.Y*P2.Y))+1;
    SortList.Add(CurPoint);
  end;
  SortList.Sort;
  for i := 0 to SortList.Count-1 do
    HullList.Add(SortList[i].ID);

  SetLength(Polygon,HullList.Count);
  for i := 0 to HullList.Count-1 do
    Polygon[i]:=Points[HullList.Items[i]];
  MainWindow.Pole.Bitmap.Canvas.BeginScene();
  MainWindow.Pole.Bitmap.Canvas.DrawPolygon(Polygon,100);
  MainWindow.Pole.Bitmap.Canvas.EndScene();

  HullList.Destroy;
  SortList.Destroy;
end;

//------------------------------------------------------------------------------
//Кнопки
//------------------------------------------------------------------------------
procedure TMainWindow.Lab2GenerateClick(Sender: TObject);
begin
  //StatusBar.tab
  PointsMax.ResetFocus;
  if RadioS.IsChecked then GeneratePointsSquare();
  if RadioC.IsChecked then GeneratePointsCircle();
  if RadioG.IsChecked then GeneratePointsGauss();
end;

procedure TMainWindow.Lab2GiftWrapClick(Sender: TObject);
begin
  GiftWrap();
end;

procedure TMainWindow.Lab2GrahamClick(Sender: TObject);
begin
  Graham();
end;

procedure TMainWindow.Button1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to 5 do
  begin
    GeneratePointsSquare();
    GiftWrap();
    Application.ProcessMessages;
    Sleep(500);
    GeneratePointsCircle();
    GiftWrap();
    Application.ProcessMessages;
    Sleep(500);
    GeneratePointsGauss();
    GiftWrap();
    Application.ProcessMessages;
    Sleep(500);
  end;
end;

end.
