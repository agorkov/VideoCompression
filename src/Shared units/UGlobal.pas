unit UGlobal;

interface

type
  TBaseColor = (RGB_R, RGB_G, RGB_B, YIQ_Y, YIQ_I, YIQ_Q); // Анализируемый цветовой канал
  TBaseType = (btFrag, btLDiff, btMDiff); // Тип элемента

const
  ElemH = 5; // Высота окна
  ElemW = 2; // Ширина окна
  ElemSize = ElemH * ElemW; // Размер окна

  PicH = 480; // Высота кадра
  PicW = 640; // Ширина кадра
  FrameBaseSize = PicH * PicW div ElemSize; // Количество окон в кадре

  BaseType = btLDiff; // Тип элемента
  BitNum =8; // Битовая плоскость для анализа
  BaseColor = RGB_R; // Цветовой канал

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

implementation

end.
