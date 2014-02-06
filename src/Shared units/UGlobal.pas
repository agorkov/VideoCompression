unit UGlobal;

interface

type
  TBaseColor = (RGB_R, RGB_G, RGB_B, YIQ_Y, YIQ_I, YIQ_Q); // ������������� �������� �����
  TBaseType = (btFrag, btLDiff, btMDiff); // ��� ��������

const
  ElemH = 4; // ������ ����
  ElemW = 2; // ������ ����
  ElemSize = ElemH * ElemW; // ������ ����

  PicH = 536; // ������ �����
  PicW = 720; // ������ �����
  FrameBaseSize = PicH * PicW div ElemSize; // ���������� ���� � �����

  BaseType = btLDiff; // ��� ��������
  BitNum = 7; // ������� ��������� ��� �������
  BaseColor = RGB_R; // �������� �����
  GrayCode = true; //�������������� � ���� ����

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

{$IF (PicH mod ElemH <> 0) or (PicW mod ElemW <> 0)}
  ElemH = 0;
  ElemW = 0;
{$IFEND}

implementation

end.
