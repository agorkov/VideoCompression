unit UGlobal;

interface

type
  TBaseColor = (RGB_R, RGB_G, RGB_B, YIQ_Y, YIQ_I, YIQ_Q); // Анализируемый цветовой канал
  TBaseType = (btFrag, btLDiff, btMDiff); // Тип элемента

const
  ElemH = 3; // Высота окна
  ElemW = 2; // Ширина окна
  ElemSize = ElemH * ElemW; // Размер окна

  PicH = 480; // Высота кадра
  PicW = 640; // Ширина кадра
  FrameBaseSize = PicH * PicW div ElemSize; // Количество окон в кадре

  bpp = 8; // Глубина цвета

  BaseType = btMDiff; // Тип элемента
  BaseColor = RGB_R; // Цветовой канал
  BitNum = 0; // Битовая плоскость для анализа

implementation

end.
