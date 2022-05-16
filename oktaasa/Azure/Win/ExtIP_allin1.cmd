@Echo off
for /f "tokens=1* delims=: " %%A in (
  'nslookup myip.opendns.com. resolver1.opendns.com 2^>NUL^|find "Address:"'
  ) Do set ExtIP=%%B
  Echo External IP is : %ExtIP%
  set message=AccessAddress:
  echo %message% %ExtIP% > C:\Windows\System32\config\systemprofile\AppData\Local\scaleft\sftd.yaml
  net stop scaleft-server-tools && net start scaleft-server-tools
