# Configuration automatique

```Bash
vim /etc/systemd/system/autossh.service

[Unit]
Description=Reverse SSH 
After=network.target

[Service]
User=autossh
ExecStart=/usr/bin/autossh -M 0 -f -N -T -q -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -R 2222:localhost:22 user@serveurB
ExecStop=killall -s KILL autossh
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
```
