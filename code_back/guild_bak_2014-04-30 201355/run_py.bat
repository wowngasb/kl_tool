@echo off
MODE con: COLS=120 LINES=15
cls
echo   ���������ڳ�ʼ���С���
color 1a
echo.
set/p=  ��<nul
for /L %%i in (1 1 36) do set /p a=��<nul&ping /n 1 127.0.0.1>nul
echo                                                              ����� 100%%
echo.

MODE con: COLS=120 LINES=30
title  ��������������XXX

:menu
echo.
echo.
echo                  ������������������������������������������
echo                  ��ѡ����Ҫ���еĳ���Ȼ�󰴻س�ִ��
echo                  ������������������������������������������

echo.
echo      ��1��.xxx_guild_player_fwq.py      ��2��.xxx_guild_sina.py 
echo.  
echo      ��3��.xxx_guild_laoyuegou.py       ��4��.xxx_guild_list_check.py  
echo. 
echo      ��5��.xxx_guild_player_check.py    ��6��.json_mysqlexU.py      
echo. 
echo      ��7��.down_ah.py	��8��.get_status.py   ��9��.�ػ�  ��0��.�˳�  
echo.
echo.
echo.
:opt
set /p run= ����������ѡ��:
IF NOT "%run%"=="" SET run=%run:~0,1%
if /i "%run%"=="1" goto mark_1
if /i "%run%"=="2" goto mark_2
if /i "%run%"=="3" goto mark_3
if /i "%run%"=="4" goto mark_4
if /i "%run%"=="5" goto mark_5
if /i "%run%"=="6" goto mark_6
if /i "%run%"=="7" goto mark_7
if /i "%run%"=="8" goto mark_8
if /i "%run%"=="9" goto mark_9
if /i "%run%"=="0" goto exit

echo ������Ч�����������룬����������Ŷ��
echo.
goto menu


:mark_1
@ECHO    xxx_guild_player_fwq.py ��ִ�У��� 
@ECHO    ע�⣬�������ʱ�ܾã�Ĭ�Ͻ�����ػ� ����
@ECHO.
@ping -n 2 127.0.0.1 >nul
@ECHO    ��������ִ��.........
@ECHO.

python xxx_guild_player_fwq.py 

@ping -n 3 127.0.0.1 >nul
@ECHO    ���������׼���ػ� ����
shutdown123.bat

@ping -n 3 127.0.0.1 >nul

@ECHO    ������ִ����ϣ��밴���������...
@PAUSE >NUL
goto menu



@echo off
:mark_2
@ECHO    xxx_guild_sina.py ��ִ�У���
@ECHO.
@ping -n 2 127.0.0.1 >nul
@ECHO    ��������ִ��.........
@ECHO.

python xxx_guild_sina.py  

@ping -n 3 127.0.0.1 >nul

@ECHO    ������ִ����ϣ��밴���������...
@PAUSE >NUL
goto menu



@echo off 
:mark_3
@ECHO    xxx_guild_laoyuegou.py��ִ�У���
@ECHO.
@ping -n 2 127.0.0.1 >nul
@ECHO    ��������ִ��.........
@ECHO.

python xxx_guild_laoyuegou.py 

@ping -n 3 127.0.0.1 >nul

@ECHO    ������ִ����ϣ��밴���������...
@PAUSE >NUL
goto menu

@echo off 
:mark_4
@ECHO    xxx_guild_list_check.py��ִ�У���
@ECHO.
@ping -n 2 127.0.0.1 >nul
@ECHO    ��������ִ��.........
@ECHO.

python xxx_guild_list_check.py 

@ping -n 3 127.0.0.1 >nul

@ECHO    ������ִ����ϣ��밴���������...
@PAUSE >NUL
goto menu

@echo off 
:mark_5
@ECHO    xxx_guild_player_check.py��ִ�У���
@ECHO.
@ping -n 2 127.0.0.1 >nul
@ECHO    ��������ִ��.........
@ECHO.

python xxx_guild_player_check.py 

@ping -n 3 127.0.0.1 >nul

@ECHO    ������ִ����ϣ��밴���������...
@PAUSE >NUL
goto menu

 

@echo off 
:mark_6
@ECHO    json_mysqlexU.py��ִ�У���
@ECHO.
@ping -n 2 127.0.0.1 >nul
@ECHO    ��������ִ��.........
@ECHO.

python json_mysqlexU.py 

@ping -n 3 127.0.0.1 >nul

@ECHO    ������ִ����ϣ��밴���������...
@PAUSE >NUL
goto menu


@echo off 
:mark_7
@ECHO    down_ah.py��ִ�У���
@ECHO.
@ping -n 2 127.0.0.1 >nul
@ECHO    ��������ִ��.........
@ECHO.

python down_ah.py 

@ping -n 3 127.0.0.1 >nul

@ECHO    ������ִ����ϣ��밴���������...
@PAUSE >NUL
goto menu



@echo off 
:mark_8
@ECHO    get_status.py��ִ�У���
@ECHO.
@ping -n 2 127.0.0.1 >nul
@ECHO    ��������ִ��.........
@ECHO.

python get_status.py 

@ping -n 3 127.0.0.1 >nul

@ECHO    ������ִ����ϣ��밴���������...
@PAUSE >NUL
goto menu


@echo off
:mark_9
@ECHO    ��ѡ���� �ػ���ִ�У���
@ECHO.
@ping -n 2 127.0.0.1 >nul
@ECHO    ��������ִ��.........

shutdown123.bat

@ping -n 3 127.0.0.1 >nul

@ECHO    ������ִ����ϣ��밴���������...
@PAUSE >NUL
goto menu