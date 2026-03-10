@echo off
certutil -hashfile "%~1" SHA256 | findstr /v "hash CertUtil"
