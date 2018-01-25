@ECHO OFF
REM Script que genera certificados ssl , en este caso para el apache (maws)
REM Dependencias: Java jdk 1.8.X en D:\usr\ y OpenSSL en D:\usr\maws\ (lo podeis cambiar en las variables más abajo)
REM Autor: Mikel Merino - MMERINOM@pge.elkarlan.euskadi.eus

CD D:\usr\
FOR /D /r %%G in ("jdk1.8.*") DO SET java_path=%%~nxG

SET url=eadm.jakina.ejgvdns
SET alias=mipc
SET validez=20000
SET java_bin=D:\usr\%java_path%\bin\
SET openssl=D:\usr\maws\OpenSSL\bin\
SET OPENSSL_CONF=D:\usr\maws\OpenSSL\bin\openssl.cnf
SET certs=D:\usr\maws\certs\
SET apache_ssl=D:\usr\maws\conf\ssl\
REM  En vez de apache weblogic ? SET weblogic=

REM ECHO java_bin = %java_bin%
REM ECHO openssl = %openssl%
REM ECHO certis = %certs%

ECHO *--__--***--__--**--__--*--__--***--__--**--__--*--__--*--__--***--__--**--__--*
ECHO.
ECHO                  GENERADOR CERTIFICADOS SSL EJIE-Desarrollo
ECHO.
ECHO *--__--***--__--**--__--*--__--***--__--**--__--*--__--*--__--***--__--**--__--*
ECHO.
ECHO Generando certificados SSL ...
%java_bin%keytool -genkey -keyalg RSA -alias %alias% -keystore %certs%DemoTrust.jks -validity %validez% -keysize 4096 -storetype JKS -ext SAN=dns:%url%
IF ERRORLEVEL 1 GOTO ERROR
%java_bin%keytool -export -alias %alias% -file %certs%%alias%.crt -keystore %certs%DemoTrust.jks
IF ERRORLEVEL 1 GOTO ERROR
%java_bin%keytool -export -alias %alias% -file  %certs%%alias%.der -keystore  %certs%DemoTrust.jks
IF ERRORLEVEL 1 GOTO ERROR
%java_bin%keytool -importkeystore -srckeystore %certs%DemoTrust.jks -destkeystore %certs%%alias%.p12 -deststoretype PKCS12
IF ERRORLEVEL 1 GOTO ERROR

ECHO.
ECHO Generando certificados para apache ...
%openssl%openssl x509 -inform der -in %certs%%alias%.der -out %certs%%alias%.crt
IF ERRORLEVEL 1 GOTO ERROR
%openssl%openssl pkcs12 -in %certs%%alias%.p12 -nodes -nocerts -out %certs%%alias%.key
IF ERRORLEVEL 1 GOTO ERROR

ECHO.
ECHO Terminando: copio certificados para servidor web apache bridge
copy %certs%%alias%.crt %apache_ssl% /b /v /y
copy %certs%%alias%.key %apache_ssl% /b /v /y

ECHO.
ECHO FIN : )
ECHO.
PAUSE
EXIT

:ERROR
ECHO.
ECHO Ha habido un error inesperado !   :(   :(     :(           :(
ECHO.
PAUSE
EXIT
