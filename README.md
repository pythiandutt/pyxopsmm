# pyxopsmm
Customer facing VM with Pythian Tools

Steps to be taken manually on a customer VM preferably OEL 9.x
as root
- Download marionette executable and save it to /usr/local/bin
- create /source ; cd /source 

If git access is avaialble
- git clone <this repository>
- chmod 777 <this repositry> 

Alternatively
- Download the repo source from <bucket>
- unzip 
- chmod 777 


 
## Root actions
in root.rule
create Certificate Request using openssl
Receive server  certificate from Cert Authority and upload to bucket
download customer server certificate from bucket
create user pythian
download nginx executable from <bucket>
download grafana executable from <bucket>


