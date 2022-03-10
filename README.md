# Connexion de type reverse SSH
Se connecter à un ordinateur se trouvant derrière un pare-feu ou bien derrière un réseau NAT.

![Schèma réseau](network.png)

## Besoins sur la machine A

| Un client SSH |
| :------------ |
| Un accès utilisateur |

## Contexte
Ce script permet d'avoir un accès SSH sur une machine se trouvant derrière Pare-feu ou un réseau NAT.
 

## Usage

1. Se connecter à un compte utilisateur sur la machine B puis Configurer l'ouverture du port 443 en entrée vers le port 22 sur la machine B.
2. Se connecter à un compte utilisateur sur la machine A puis exécuter le script (Création du tunnel).
3. Se connecter à un compte utilisateur sur la machine B puis lancer la connexion SSH.

## Testes

Vérifier que le port 2211 est en écoute sur la machine B.

```Bash
(echo >/dev/tcp/127.0.0.1/2211) &> /dev/null && echo "Port eb écoute" || echo "Port fermé"
```
