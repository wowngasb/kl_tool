@echo off
echo ��ã������õ�����ʱ�䵽�ˣ�
echo ���ѿ�ʼ��2011-5-22 19:41:48----��ʱΪ4380��
set /p word=��������˳�����Ȼ��f��s���мɱ�f��
if /i %word%==f  %systemroot%\system32\shutdown -f -s -t 10
if /i %word%==s  %systemroot%\system32\shutdown -f -s -t 150
cls
:yn
set /p word=����Yȡ���ػ�������N�˳���
if /i %word%==y %systemroot%\system32\shutdown -a&&goto :eof
if /i %word%==m %systemroot%\system32\shutdown -a&&goto :min
if /i %word%==r goto :start
if /i %word%==n (goto :eof) else (cls&&echo ��������,����R���¹ػ�!&&%systemroot%\system32\shutdown -a&&goto :yn)
:min
set /p word=����ȴ��ػ�ʱ�䣨��λ�����ӣ���Fǿ�ƹػ���R������
if /i %word%==0 (%systemroot%\system32\shutdown -f -s -t 30)&&goto :yn
if /i %word%==1 (%systemroot%\system32\shutdown -f -s -t 60)&&goto :yn
if /i %word%==2 (%systemroot%\system32\shutdown -f -s -t 120)&&goto :yn
if /i %word%==3 (%systemroot%\system32\shutdown -f -s -t 180)&&goto :yn
if /i %word%==4 (%systemroot%\system32\shutdown -f -s -t 240)&&goto :yn
if /i %word%==5 (%systemroot%\system32\shutdown -f -s -t 300)&&goto :yn
if /i %word%==f (%systemroot%\system32\shutdown -f -s -t 0)&&goto :yn
if /i %word%==r (%systemroot%\system32\shutdown -f -r -t 10&&goto :yn) else (cls&&echo ��������,���¹ػ�!&&goto :start)
