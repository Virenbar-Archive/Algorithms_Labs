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
    Button1: TButton;
    Redraw: TButton;
    //
    procedure PointsMaxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Lab2GenerateClick(Sender: TObject);
    procedure Lab2GiftWrapClick(Sender: TObject);
    procedure Lab2GrahamClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure RedrawClick(Sender: TObject);
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
//Нахрен кривой антиалиасинг
function NoNoNo(Point:TPointF):TPointF;
begin
  Result:=PointF(Floor(Point.X)+0.5,Floor(Point.Y)+0.5);
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
    Clear(TAlphaColors.White);
    //DrawLine(my_point_1, my_point_2, 1.0);
    EndScene;
  end;
  Computation.Enabled:=false;
end;

{------------------------------------------------------------------------------}
//Отрисовка точек
procedure DrawPoints();
var
i:Integer;
begin
  with MainWindow.Pole.Bitmap.Canvas do
  begin
    BeginScene;
    Clear(TAlphaColors.White);
    for i := 0 to PointsCount-1 do
      DrawLine(NoNoNo(Points[i]),NoNoNo(Points[i]),100);
    EndScene;
  end;
end;

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

{------------------------------------------------------------------------------}
//Оборачивание подарка
procedure GiftWrap();
var
  Start,NextP,i :Integer;
  MaxCos,CurCos :Single;
  HullList      :TList<Integer>;
  P1,P2         :TPointF;
  Polygon       :TPolygon;
  T             :Integer;
begin
  HullList:=TList<Integer>.Create();
  //На старт
  Stopwatch.Reset;
  //Внимание
  Stopwatch.Start;
  for T := 1 to 1000 do
  begin
    HullList.Clear;
    //Начальная точка(левая верхняя)
    Start:=0;
    for i := 1 to PointsCount-1 do
    begin
      if 
        ((Points[i].X<Points[Start].X) or {Вероятность крайне мала \/}
        ((Points[i].X=Points[Start].X) and (Points[i].Y<Points[Start].Y))) 
      then Start:=i;
    end;
    HullList.Add(Start);
    //Цикл
    while true do
    begin
      MaxCos:=-1;
      for i := 0 to PointsCount-1 do
      begin
        if ((HullList.Contains(i)) and (i<>Start)) then Continue;{Проверка точки на наличие в оболочке}
        if HullList.Capacity=1 then
        begin{Для второй точки}
          P1:=PointF(0,-1);
          P2:=PointF(Points[i].X-Points[Start].X,Points[i].Y-Points[Start].Y);
        end
        else
        begin{Для остальных точек}
          P1:=PointF(
            Points[HullList.Items[HullList.Count-1]].X-Points[HullList.Items[HullList.Count-2]].X,
            Points[HullList.Items[HullList.Count-1]].Y-Points[HullList.Items[HullList.Count-2]].Y
          );
          P2:=PointF(
            Points[i].X-Points[HullList.Items[HullList.Count-1]].X,
            Points[i].Y-Points[HullList.Items[HullList.Count-1]].Y
          );
        end;
        CurCos:=(P1.X*P2.X+P1.Y*P2.Y)/(sqrt(P1.X*P1.X+P1.Y*P1.Y)*sqrt(P2.X*P2.X+P2.Y*P2.Y));//Косинус угла
        if CurCos>MaxCos then
        begin
          NextP:=i;
          MaxCos:=CurCos;
        end;

      end;
      if HullList.Contains(NextP) then break;
      HullList.Add(NextP);

      {
      with  MainWindow.Pole.Bitmap.Canvas do
      begin
        BeginScene();
        DrawLine(Points[HullList.Items[HullList.Count-2]],Points[HullList.Items[HullList.Count-1]],100);
        EndScene();
        Application.ProcessMessages;
        Sleep(100);
      end;
      //}
    end;
  end;
  Stopwatch.Stop;
  MainWindow.Time1.Text:=FloatToStr(Stopwatch.ElapsedMilliseconds/1000/1000);

  //{
  SetLength(Polygon,HullList.Count);
  for i := 0 to HullList.Count-1 do
    Polygon[i]:=NoNoNo(Points[HullList[i]]);
  with  MainWindow.Pole.Bitmap.Canvas do
  begin
    BeginScene();
    DrawPolygon(Polygon,100);
    EndScene();
  end;
  //}
  {
  MainWindow.Pole.Bitmap.Canvas.BeginScene();
  MainWindow.Pole.Bitmap.Canvas.DrawLine(Points[HullList.Items[HullList.Count-1]],Points[HullList.Items[0]],100);
  MainWindow.Pole.Bitmap.Canvas.EndScene();
  }
  HullList.Destroy;
end;

{------------------------------------------------------------------------------}
//Оптимальный метод
procedure Graham();
type
  PointAngle = record
    ID:Integer;
    Angle:Integer;
  end;
var
  Start,i       :Integer;
  Comparer      :IComparer<PointAngle>;
  SortList      :TList<PointAngle>;
  HullList      :TList<Integer>;
  P0,P1,P2      :TPointF;
  CurPoint      :PointAngle;
  Polygon       :TPolygon;
  T             :Integer;
begin
  {Сравниватель по углам}
  Comparer:=TDelegatedComparer<PointAngle>.Create(
  function(const Left, Right: PointAngle): Integer
  begin
    Result := Left.Angle - Right.Angle;
  end
  );
  //---------
  SortList:=TList<PointAngle>.Create(Comparer);
  HullList:=TList<Integer>.Create();

  Stopwatch.Reset;
  Stopwatch.Start;
  for T := 1 to 1000 do
  begin
    SortList.Clear;
    HullList.Clear;
    //Начальная точка(левая верхняя)
    Start:=0;
    for i := 1 to PointsCount-1 do
    begin
      if ((Points[i].X<Points[Start].X) or ((Points[i].X=Points[Start].X) and (Points[i].Y<Points[Start].Y))) then Start:=i;
    end;
    HullList.Add(Start);
    //Создание списка с углами
    for i := 0 to PointsCount-1 do
    begin
      if i=HullList[0] then continue;
      P1:=PointF(0,-1);
      P2:=PointF(Points[i].X-Points[Start].X,Points[i].Y-Points[Start].Y);
      CurPoint.ID:=i;
      CurPoint.Angle:=Round((P1.X*P2.X+P1.Y*P2.Y)/(sqrt(P1.X*P1.X+P1.Y*P1.Y)*sqrt(P2.X*P2.X+P2.Y*P2.Y))*1000000000);
      SortList.Add(CurPoint);
    end;
    SortList.Sort;{Сортировка}
    for i := 0 to SortList.Count-1 do
      HullList.Add(SortList[i].ID);
    HullList.Add(Start);

    i:=0;
    P0:=Points[HullList[i]];
    P1:=Points[HullList[i+1]];
    P2:=Points[HullList[i+2]];
    //Цикл
    while true do
    begin
      if (P1.X - P0.X)*(P2.Y - P0.Y) - (P2.X - P0.X)*(P1.Y - P0.Y)>=0 then
      begin
        HullList.Delete(i+1);//P1
        if i>0 then Dec(i);
        P0:=Points[HullList[i]];
        P1:=Points[HullList[i+1]];
        P2:=Points[HullList[i+2]];
      end
      else
      begin
        Inc(i);
        P0:=Points[HullList[i]];
        P1:=Points[HullList[i+1]];
        P2:=Points[HullList[i+2]];
      end;
      {Проверка на конечность}
      if HullList[i+2]=HullList[HullList.Count-1] then break;
    end;
  end;
  Stopwatch.Stop;
  MainWindow.Time2.Text:=FloatToStr(Stopwatch.ElapsedMilliseconds/1000/1000);

  SetLength(Polygon,HullList.Count-1);
  for i := 0 to HullList.Count-1-1 do
    Polygon[i]:=NoNoNo(Points[HullList.Items[i]]);
  with  MainWindow.Pole.Bitmap.Canvas do
  begin
    BeginScene();
    DrawPolygon(Polygon,100);
    Stroke.Color := TAlphaColors.Red;
    for i := 0 to HullList.Count-1-1 do
      DrawLine(NoNoNo(Points[HullList.Items[i]]),NoNoNo(Points[HullList.Items[i]]),100);
    Stroke.Color := TAlphaColors.Black;
    EndScene();
  end;
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

procedure TMainWindow.RedrawClick(Sender: TObject);
begin
  DrawPoints();
end;

procedure TMainWindow.Button1Click(Sender: TObject);
var
  I:integer;
begin
  for I := 1 to 10 do
  begin
    GeneratePointsGauss();
    Graham();
    Sleep(500);
    Application.ProcessMessages;
  end;
  Pole.Bitmap.Canvas.BeginScene();
  Pole.Bitmap.Canvas.DrawLine(PointF(100,100),PointF(200,200),100);
  Pole.Bitmap.Canvas.EndScene();
end;

end.
