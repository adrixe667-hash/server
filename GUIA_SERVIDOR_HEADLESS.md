# Guía rápida: servidores tipo Crafty (Minecraft y similares)

Esta guía quedó sintetizada para uso real: crear, optimizar y operar servidores con modo **Crafty** o **no-Crafty**.

## 1) Qué incluye el proyecto

- `docker-compose.yml`: stack con perfiles (`crafty`, `nocrafty`, `monitoring`, `homeassistant`).
- `.env.example`: plantilla de configuración del servidor y optimización.
- `scripts/create_server.sh`: crea servidor con validación y progreso.
- `scripts/quickstart.sh`: valida entorno y deja listo para levantar.
- `scripts/stack.sh`: levanta/baja/reinicia stack por modo.
- `scripts/manage_server.sh`: comandos admin (OP, deOP, give, kick, ban, mute).
- `scripts/backup.sh`: backup con retención.
- `scripts/ha_event.sh`: eventos a Home Assistant.
- `scripts/validate_project.sh`: validación integral del proyecto.
- `web/index.html`: esqueleto de página de visualización/administración (modo no-Crafty).

## 2) Modo Crafty vs no-Crafty

### Crafty
- Panel especializado para game hosting.
- Recomendado para usuarios no técnicos y gestión multi-servidor.

### no-Crafty
- Portainer + scripts.
- Más ligero para VPS pequeños.

## 3) Flujo de creación del servidor

![Flujo de la plataforma tipo Crafty](docs/assets/flujo_ejemplo.svg)


```bash
scripts/check_dependencies.sh
scripts/create_server.sh mc-survival PAPER 6G 25565 nocrafty
scripts/optimize_server.sh balanced
scripts/stack.sh up nocrafty
```

> Puedes cambiar `nocrafty` por `crafty`.

## 4) Porcentajes de avance y finalización

Los scripts críticos ahora muestran progreso:

- `create_server.sh`: progreso de creación + `FINALIZADO`.
- `quickstart.sh`: progreso de validaciones + `FINALIZADO`.
- `stack.sh`: progreso de acción (`up/down/restart/ps`) + `FINALIZADO`.

## 5) Compatibilidad de nombre

El nombre del servidor debe cumplir:

- regex: `^[a-z0-9-]+$`
- válido: `mc-survival`, `fabric-1`
- inválido: `Mi Servidor`, `server_01`, `pvp#1`

## 6) Optimización recomendada

Variables principales en `.env`:

- `MC_MEMORY`
- `USE_AIKAR_FLAGS`
- `JVM_XX_OPTS`
- `VIEW_DISTANCE`
- `SIMULATION_DISTANCE`
- `MAX_TICK_TIME`

Perfiles rápidos:

```bash
scripts/optimize_server.sh low
scripts/optimize_server.sh balanced
scripts/optimize_server.sh high
```

## 7) Uso de Crafty (resumen)

```bash
scripts/create_server.sh mc-survival PAPER 6G 25565 crafty
scripts/stack.sh up crafty
```

Puertos típicos de Crafty:
- `8000` (HTTP)
- `8443` (HTTPS)

## 8) Seguridad mínima

- Usa `online-mode=true` para premium cuando aplique.
- Activa whitelist en privados.
- Cambia `RCON_PASSWORD`.
- Usa backups diarios.
- Limita puertos expuestos y usa túnel si estás en CGNAT.

## 9) Home Assistant

Opciones:

1. Webhook con `scripts/ha_event.sh`
2. MQTT con perfil `homeassistant` (servicio `mosquitto`)

Ejemplo:

```bash
HA_WEBHOOK_URL="https://ha.tudominio/api/webhook/mc_event" \
  scripts/ha_event.sh server_up "Servidor iniciado"
```

## 10) Esqueleto de página de visualización y administración

- Ruta: `web/index.html`
- Estilos: `web/styles.css`
- Interacción base: `web/app.js`
- URL en ejecución (modo `nocrafty`): `http://localhost:8088`

Este esqueleto está preparado para conectar un backend (API) que ejecute los scripts (`create_server`, `stack`, `manage_server`, `backup`).

## 11) Dónde ver más detalle

- `README.md`
- `docs/USO_PROYECTO.md`
- `docs/GUIA_CRAFTY_OPTIMIZACION.md`
