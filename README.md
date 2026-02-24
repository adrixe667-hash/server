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
# ejecutable refinado (todo en uno):
scripts/run_admin_ui.sh
```

Esqueleto UI de administración:
- `http://localhost:8088` (modo `nocrafty`)

## Comprobación integral del proyecto

```bash
scripts/validate_project.sh
```

## Ejecutable refinado

```bash
scripts/run_admin_ui.sh
```

Arranca la experiencia de administración no-Crafty con validaciones, progreso y endpoints.

## Documentación

- `GUIA_SERVIDOR_HEADLESS.md`
- `docs/USO_PROYECTO.md`
- `docs/GUIA_CRAFTY_OPTIMIZACION.md`
