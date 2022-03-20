# Configuration sur la machine où nous avons un total contrôle
## Accés au tunnel aux autres machines du réseau local
```Bash
vim /etc/ssh/sshd_config

AllowTcpForwarding yes
GatewayPorts yes
```
