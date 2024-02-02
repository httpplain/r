FROM mcr.microsoft.com/windows/servercore:ltsc2019

ARG AUTH_TOKEN
ARG PASSWORD=rootuser

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Invoke-WebRequest -Uri 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-windows-amd64.zip' -OutFile 'ngrok.zip'; \
    Expand-Archive -Path 'ngrok.zip' -DestinationPath 'ngrok'; \
    Remove-Item -Path 'ngrok.zip' -Force

RUN Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0; \
    Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'; \
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 1; \
    New-LocalUser -Name 'runneradmin' -Password (ConvertTo-SecureString -AsPlainText 'P@ssw0rd!' -Force); \
    net user runneradmin /add; \
    net localgroup administrators runneradmin /add; \
    echo "c:\\ngrok\\ngrok.exe authtoken ${AUTH_TOKEN}" >> C:\\docker.bat; \
    echo "c:\\ngrok\\ngrok.exe tcp 3389" >> C:\\docker.bat

RUN .\docker.bat

EXPOSE 3389
