c = indicator_c(DSM);
cnc = indicator_cnc(DSM);
os = indicator_os(DSM);
[i1,i2,i3,i4,i5,i6] = indicators(DSM);
xdensity = indicator_xdensity(DSM);
tdensity = indicator_tdensity(DSM);

[XDUR,VADUR] = indicator_duration(PDM, 1);
[NSLACK,PCTSLACK,XSLACK,XSLACK_R,TOTSLACK_R,MAXCPL,NFREESLK,PCTFREESLK,XFREESLK] = indicator_slack(PDM, 1);

[RF,RU,PCTR,DMND,XDMND,RS,RC,UTIL,XUTIL,TCON,XCON,OFACT,TOTOFACT,UFACT,TOTUFACT] = indicators_resource(PSM,num_r_resources,constr);

arlf = indicator_arlf(PDM, 1);