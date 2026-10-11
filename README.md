# Quick Start Guide

## Start the server

Getting the server up takes one Compose command. Docker, with the Compose plugin, must already be installed. TCP port 25565 and UDP port 19132 must be free. The first start needs internet access so Compose can pull the images and download Paper, ViaVersion, ViaBackwards, and Geyser. No other setup is required: `.env` is already in the repo.

On the Docker host:

```bash
cd /opt
git clone https://github.com/mbechc/Minecraft.git
cd /opt/Minecraft
docker compose up -d
```

`docker compose up -d` starts Paper, Geyser, and backups in the background. Geyser and backups wait until Paper is healthy. The sections below are checks and optional settings. They are not extra steps to get the server running.

## Check that it stays up

From `/opt/Minecraft`:

```bash
docker compose ps
ss -ltn sport = :25565
ss -lun sport = :19132
```

`docker compose ps` shows `minecraft-server` as `healthy`, and `geyser` and `backups` as `Up`.

Java is listening when TCP port 25565 is open:

```text
LISTEN 0 4096 0.0.0.0:25565 0.0.0.0:*
```

Bedrock is listening when UDP port 19132 is open:

```text
UNCONN 0 0 0.0.0.0:19132 0.0.0.0:*
```

## Operator

`MINECRAFT_SERVER_OPS` in `.env` is `DrBech`. On startup the server writes that player to `minecraft-server-data/ops.json` at level 4, so that player can run every command.

In the game, DrBech runs commands with a leading `/`.

From the host, the console is:

```bash
cd /opt/Minecraft
docker compose exec minecraft-server rcon-cli op PlayerName
```

To elevate another player, add the name to `MINECRAFT_SERVER_OPS` (comma-separated) and run `docker compose up -d` again, or op them once with the `rcon-cli` command above.

## Limit who can join

With `MINECRAFT_SERVER_WHITELIST` empty, `white-list` stays `false` and any player can join.

To allow only named players, set a comma-separated list in `.env`:

```text
MINECRAFT_SERVER_WHITELIST=DrBech,OtherPlayer
```

A non-empty list turns `white-list` and `enforce-whitelist` on. Apply it with:

```bash
cd /opt/Minecraft
docker compose up -d
```

Use each player's name as it appears on this server. Bedrock players use the name they join with.

## Backups

The `backups` service starts after Paper is healthy. The container runs `backup loop`. `MINECRAFT_SERVER_INITIAL_DELAY` is `0`, so the first tar backup runs immediately, then the loop sleeps for `MINECRAFT_SERVER_BACKUP_INTERVAL` (`23h`). Each run deletes backups older than `MINECRAFT_SERVER_PRUNE_BACKUPS_DAYS` (`7` days). Files are stored in `minecraft-server-data-backups`.

Take one now with:

```bash
cd /opt/Minecraft
docker compose exec backups backup now
```

## Router NAT

Docker on (EXAMPLE) `192.168.88.5` listens on TCP `25565` for Java and UDP `19132` for Bedrock.

On the router, forward both to that host:

| Who is outside | Protocol | Public port | Destination |
| --- | --- | --- | --- |
| Java | TCP | 25565 | 192.168.88.5 port 25565 |
| Bedrock | UDP | 19132 | 192.168.88.5 port 19132 |

Reserve `192.168.88.5` (EXAMPLE) for this machine in DHCP so the forwards still point at it after a reboot. Players outside connect to the router's public address on those ports.
