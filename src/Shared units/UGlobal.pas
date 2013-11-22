unit UGlobal;

interface

const
  FragH = 6;
  FragW = 5;
  FragSize = FragH * FragW;
  PicW = 640;
  PicH = 480;
  FrameBaseSize = PicH * PicW div FragSize;
  bpp = 1;
  quantizationStep = 256 div (1 shl UGlobal.bpp);
  BitNum = 1;

implementation

end.
