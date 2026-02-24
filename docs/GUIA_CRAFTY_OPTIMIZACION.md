# Guía de optimización y uso de Crafty

## Cuándo usar Crafty

Usa Crafty si necesitas:
- Panel multi-servidor para usuarios no técnicos.
- Gestión visual de consola, backups y permisos.
- Entorno similar a hosting game panel.

## Activar modo Crafty

```bash
scripts/create_server.sh mc-survival PAPER 6G 25565 crafty
scripts/stack.sh up crafty
```

Puertos importantes:
- `8000` HTTP
- `8443` HTTPS

## Optimización recomendada

1. RAM adecuada en `.env` (`MC_MEMORY`).
2. Distancias equilibradas:
   - `VIEW_DISTANCE=8`
   - `SIMULATION_DISTANCE=6`
3. Usar `scripts/optimize_server.sh balanced`.
4. Activar monitoreo (`ENABLE_MONITORING=true`).

## Buenas prácticas Crafty

- No dar permisos globales a todos los usuarios.
- Programar backups diarios.
- Aplicar updates de Crafty y del servidor de juego.
- Mantener whitelist en servidores privados.

