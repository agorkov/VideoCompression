unit UGlobal;

interface

const
  FragH = 5;
  FragW = 4;
  FragSize = FragH * FragW;
  PicW = 640;
  PicH = 480;
  FrameBaseSize = PicH * PicW div FragSize;
  bpp = 4;
  quantizationStep = 256 div (1 shl UGlobal.bpp);
  BitNum = 0;

implementation

end.
