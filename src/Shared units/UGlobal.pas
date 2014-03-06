unit UGlobal;

interface

type
  TBaseType = (btFrag, btLDiff, btMDiff);
  TBaseColor = (RGB_R, RGB_G, RGB_B, YIQ_Y, YIQ_I, YIQ_Q);
  TFilterType = (ftNone, ftAVG, ftMedian, ftThresold);

const
  ElemH = 2; // Высота окна
  ElemW = 9; // Ширина окна
  ElemSize = ElemH * ElemW; // Размер окна

  PicH = 536; // Высота кадра
  PicW = 720; // Ширина кадра
  FrameBaseSize = PicH * PicW div ElemSize; // Количество окон в кадре

{$IF (PicH mod ElemH <> 0) or (PicW mod ElemW <> 0)}
  ElemH = 0;
  ElemW = 0;
{$IFEND}

var
  BaseType: TBaseType;
  BaseColor: TBaseColor;
  GrayCode: boolean;
  BitNum, bpp: byte;
  FilterType: TFilterType;
  FilterParam: byte;

implementation

end.
