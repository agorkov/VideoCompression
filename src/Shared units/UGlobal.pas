unit UGlobal;

interface

type
  TBaseColor = (RGB_R, RGB_G, RGB_B, YIQ_Y, YIQ_I, YIQ_Q); // Анализируемый цветовой канал
  TBaseType = (btFrag, btLDiff, btMDiff); // Тип элемента
  TFilterType = (ftNone, ftAVG, ftMedian);

const
  ElemH = 3; // Высота окна
  ElemW = 2; // Ширина окна
  ElemSize = ElemH * ElemW; // Размер окна

  PicH = 384; // Высота кадра
  PicW = 510; // Ширина кадра
  FrameBaseSize = PicH * PicW div ElemSize; // Количество окон в кадре

  BaseType = btFrag; // Тип элемента
  BitNum = 0; // Битовая плоскость для анализа
  BaseColor = RGB_R; // Цветовой канал
  GrayCode = false; // Преобразование в коды Грея

  FilterType = ftNone;
  FilterH = 3;
  FilterW = 3;

{$IF BaseType in [btFrag,btLDiff]}
  maxBitNum = 8;
{$IFEND}
{$IF BaseType=btMDiff]}
  maxBitNum = 9;
{$IFEND}
{$IF BitNum=0}
  bpp = 8; // Глубина цвета
{$IFEND}
{$IF BitNum in [1..maxBitNum]}
  bpp = 1; // Глубина цвета
{$IFEND}
{$IF (PicH mod ElemH <> 0) or (PicW mod ElemW <> 0)}
  ElemH = 0;
  ElemW = 0;
{$IFEND}

implementation

end.
