# Server Stack (Crafty / no-Crafty)

Proyecto base para crear y operar servidores (Minecraft y similares) con:

- Modo **Crafty** (panel dedicado).
- Modo **no-Crafty** (Portainer + scripts).
- Monitoreo (Prometheus + Grafana + exporters).
- Integración opcional con Home Assistant (webhook/MQTT).

## Inicio rápido

```bash
cp .env.example .env
scripts/quickstart.sh
scripts/create_server.sh mc-survival PAPER 6G 25565 nocrafty
scripts/stack.sh up nocrafty
```

Esqueleto UI de administración:
- `http://localhost:8088` (modo `nocrafty`)

## Comprobación integral del proyecto

```bash
scripts/validate_project.sh
```

## Documentación

- `GUIA_SERVIDOR_HEADLESS.md`
- `docs/USO_PROYECTO.md`
- `docs/GUIA_CRAFTY_OPTIMIZACION.md`
