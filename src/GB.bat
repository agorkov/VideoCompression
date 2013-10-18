set Window=-W
set Median=-M

start GetBase %1 d RGB.R %Window% %Median% %1.RGB.R
start GetBase %1 d RGB.G %Window% %Median% %1.RGB.G
start GetBase %1 d RGB.B %Window% %Median% %1.RGB.B

start GetBase %1 d YIQ.Y %Window% %Median% %1.YIQ.Y
start GetBase %1 d YIQ.I %Window% %Median% %1.YIQ.I
start GetBase %1 d YIQ.Q %Window% %Median% %1.YIQ.Q