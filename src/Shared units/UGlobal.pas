unit UGlobal;

interface

const
  FragH = 4;
  FragW = 2;
  FragSize = FragH * FragW;
  PicW = 320;
  PicH = 240;
  FrameBaseSize = PicH * PicW div FragSize;
  bpp = 8;
  quantizationStep = 256 div (1 shl UGlobal.bpp);

implementation

end.
