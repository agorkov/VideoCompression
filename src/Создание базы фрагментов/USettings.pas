unit USettings;

interface

type
  TBaseColor = (RGB_R, RGB_G, RGB_B, YIQ_Y, YIQ_I, YIQ_Q);
  TBaseType = (btFrag, btLDiff, btMDiff);

const
  BaseType = btMDiff;
  BitNum = 8;

var
  FileName: string;
  BaseColor: TBaseColor;

implementation

end.
