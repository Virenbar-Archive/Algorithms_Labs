unit BTree;

interface
  type
     TBTreeNode=class
      fRightChild : tbtreenode;
      fLeftChild  : tbtreenode;
      fData       : integer;
      constructor Create(Data:integer);
      destructor Destroy;
      procedure Insert(num:integer);
      //procedure OutputInAscendingOrder(TSL:TStringList);
      //procedure OutputInDescendingOrder(TSL:TStringList);
    end;
implementation

constructor TBTreeNode.Create(Data:integer);
begin
   fData:=data;
   fRightChild:=nil;
   fLeftChild:=nil;
end;

destructor TBTreeNode.Destroy;
begin
   if fRightChild<>nil then fRightChild.Free;
   if fLeftChild<>nil  then fLeftChild.Free;
end;


procedure TBTreeNode.Insert(num:integer);
begin
   if (num<fData) then
      if fLeftChild=nil then fLeftChild:=TBTreeNode.Create(num)
      else                   fLeftChild.Insert(num)
   else
      if fRightChild=nil then fRightChild:=TBTreeNode.Create(num)
      else                    fRightChild.Insert(num)
end;

{procedure TBTreeNode.OutputInAscendingOrder(TSL:TStringList);
begin
if TSL=nil then exit;

   if fLeftChild<>nil then fLeftChild.OutputInAscendingOrder(TSL);
   TSL.Add(IntToStr(fData));
   if fRightChild<>nil then fRightChild.OutputInAscendingOrder(TSL);
end;

procedure TBTreeNode.OutputInDescendingOrder(TSL:TStringList);
begin
if TSL=nil then exit;

   if fRightChild<>nil then fRightChild.OutputInDescendingOrder(TSL);
   TSL.Add(IntToStr(fData));
   if fLeftChild<>nil then fLeftChild.OutputInDescendingOrder(TSL);
end;}
end.
