unit USettings;

interface

type
  TElemBase = (FragBase, DiffBase);
  TBaseColor = (RGB_R, RGB_G, RGB_B, YIQ_Y, YIQ_I, YIQ_Q);

var
  FileName: ANSIstring;
  ElemBase: TElemBase;
  FilterThresold: byte;
  BaseColor: TBaseColor;
  NeedMedianFilter, NeedWindowFilter: boolean;

implementation

end.
