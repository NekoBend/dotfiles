@echo off
certutil -hashfile "%~1" MD5 | findstr /v "hash CertUtil"
