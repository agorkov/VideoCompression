unit UGlobal;

interface

const
  FragH = 5;
  FragW = 5;
  FragSize = FragH * FragW;
  PicW = 640;
  PicH = 480;
  FrameBaseSize = PicH * PicW div FragSize;
  bpp = 8;
  quantizationStep = 256 div (1 shl UGlobal.bpp);
  BitNum = 4;

implementation

end.
