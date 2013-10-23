unit UGlobal;

interface

const
  FragH = 2;
  FragW = 1;
  FragSize = FragH * FragW;
  PicW = 640;
  PicH = 480;
  FrameBaseSize = PicH * PicW div FragSize;
  bpp = 4;
  quantizationStep = 256 div (1 shl UGlobal.bpp);

implementation

end.
