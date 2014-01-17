unit UGlobal;

interface

type
  TBaseColor = (RGB_R, RGB_G, RGB_B, YIQ_Y, YIQ_I, YIQ_Q); // ������������� �������� �����
  TBaseType = (btFrag, btLDiff, btMDiff); // ��� ��������

const
  ElemH = 5; // ������ ����
  ElemW = 2; // ������ ����
  ElemSize = ElemH * ElemW; // ������ ����

  PicH = 480; // ������ �����
  PicW = 640; // ������ �����
  FrameBaseSize = PicH * PicW div ElemSize; // ���������� ���� � �����

  BaseType = btLDiff; // ��� ��������
  BitNum =8; // ������� ��������� ��� �������
  BaseColor = RGB_R; // �������� �����

{$IF BaseType in [btFrag,btLDiff]}
  maxBitNum = 8;
{$IFEND}
{$IF BaseType=btMDiff]}
  maxBitNum = 9;
{$IFEND}
{$IF BitNum=0}
  bpp = 8; // ������� �����
{$IFEND}
{$IF BitNum in [1..maxBitNum]}
  bpp = 1; // ������� �����
{$IFEND}

implementation

end.
