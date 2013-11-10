unit USettings;

interface

type
  TElemBase = (FragBase, DiffBase);
  TBaseColor = (red,green,blue,grayscale);

var
  FileName: string;
  ElemBase: TElemBase;
  FilterThresold: byte;
  BaseColor: TBaseColor;
  NeedMedianFilter, NeedWindowFilter: boolean;

implementation

end.
