unit UGlobal;

interface

const
  FragH = 1;
  FragW = 1;
  FragSize = FragH * FragW;
  PicW = 320;
  PicH = 240;
  FrameBaseSize = PicH * PicW div FragSize;
  bpp = 4;
  quantizationStep = 256 div (1 shl UGlobal.bpp);

implementation

end.
