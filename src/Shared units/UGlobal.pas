unit UGlobal;

interface

type
  TBaseColor = (RGB_R, RGB_G, RGB_B, YIQ_Y, YIQ_I, YIQ_Q); // ������������� �������� �����
  TBaseType = (btFrag, btLDiff, btMDiff); // ��� ��������

const
  ElemH = 3; // ������ ����
  ElemW = 2; // ������ ����
  ElemSize = ElemH * ElemW; // ������ ����

  PicH = 480; // ������ �����
  PicW = 640; // ������ �����
  FrameBaseSize = PicH * PicW div ElemSize; // ���������� ���� � �����

  bpp = 8; // ������� �����

  BaseType = btMDiff; // ��� ��������
  BaseColor = RGB_R; // �������� �����
  BitNum = 0; // ������� ��������� ��� �������

implementation

end.
