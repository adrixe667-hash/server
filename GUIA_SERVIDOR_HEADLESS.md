# Plataforma tipo Crafty para servidores propios/privados (Minecraft y similares)

Esta guía está diseñada para montar una plataforma **estilo Crafty**: interfaz amigable, gestión centralizada, creación de servidores privados/propios y alta personalización, enfocada en **Minecraft** y otros juegos que permitan hosting dedicado.

Base de referencia solicitada:

- https://github.com/N-aksif-N/MineColab_Improved

---

## 1) Objetivo real de la plataforma

Construir una solución que se comporte “como Crafty”, es decir:

- Panel web fácil de usar para crear/arrancar/detener servidores.
- Gestión multi-servidor desde un solo sitio.
- Soporte para servidores privados (acceso por whitelist/roles).
- Configuración avanzada (mods/plugins, puertos, memoria, backups, reglas).
- Métricas en tiempo real de CPU/RAM/disco/red por servidor.
- Compatibilidad con múltiples launchers (especialmente en Minecraft Java) siempre que usen el protocolo estándar del servidor.

---

## 2) Arquitectura recomendada (tipo panel Crafty)

```text
[Usuario/Admin]
      |
      v
[Panel Web amigable]
      |
      +--> [Servicio API de orquestación]
      |         |
      |         +--> [Contenedor Minecraft #1]
      |         +--> [Contenedor Minecraft #2]
      |         +--> [Contenedor Terraria/Valheim/etc]
      |
      +--> [Métricas: Prometheus + cAdvisor + Node Exporter]
      +--> [Visualización: Grafana]
      +--> [Backups + almacenamiento persistente]
```

### Componentes sugeridos

1. **Panel web**:
   - Opción A (rápida): usar Crafty directamente.
   - Opción B (personalizable): Cockpit/Portainer + scripts + dashboard dedicado.

2. **Orquestación de servidores**:
   - Docker Compose por juego/instancia.
   - Plantillas para levantar servidores en 1 clic.

3. **Observabilidad**:
   - cAdvisor + Node Exporter + Prometheus + Grafana.

4. **Seguridad y acceso remoto**:
   - Reverse proxy (Traefik/Nginx).
   - HTTPS (Let’s Encrypt).
   - Roles de usuario y 2FA para panel.

---

## 3) Compatibilidad con launchers (Minecraft)

Para lograr “compatible con todos los launchers”, en la práctica:

- **Java Edition**:
  - Cualquier launcher que respete protocolo vanilla/modded puede conectarse.
  - Debe coincidir versión del servidor y modpack cuando aplique.

- **Cracked / premium**:
  - Si activas `online-mode=true` => validación oficial (premium).
  - Si activas `online-mode=false` => permite no premium, pero requiere más medidas de seguridad (auth plugins/proxy).

- **Bedrock**:
  - Requiere servidor Bedrock nativo o puente tipo Geyser/Floodgate en escenarios mixtos.

> Nota: “100% todos los launchers” no se garantiza universalmente por diferencias de mods, protocolo y autenticación; pero con configuración correcta se cubre la gran mayoría.

---

## 4) Diseño funcional de la interfaz amigable (como Crafty)

La interfaz debería incluir estos módulos:

1. **Dashboard principal**
   - Estado de todos los servidores (online/offline).
   - Uso de CPU/RAM por instancia.
   - Jugadores conectados en tiempo real.

2. **Gestión de instancias**
   - Crear servidor nuevo desde plantilla.
   - Botones visibles: **Encender**, **Apagar**, **Reiniciar** y **Forzar apagado (Kill)**.
   - Consola web en vivo.

3. **Configuración**
   - Variables de entorno (RAM, versión, tipo: Paper/Purpur/Fabric/Forge).
   - Edición de archivos (`server.properties`, `ops.json`, whitelist, etc.).
   - Programación de reinicios y tareas.

4. **Plugins / mods / packs**
   - Carga por archivo o URL.
   - Perfiles por tipo de servidor.

5. **Skins personalizadas (Minecraft)**
   - Selector para modo premium (`online-mode=true`) o modo compatible con no-premium (`online-mode=false`).
   - Soporte de skins personalizadas mediante plugin/proxy (por ejemplo SkinRestorer en entornos no-premium).
   - Opción de política: permitir solo skins oficiales, o habilitar skins personalizadas por servidor.

6. **Backups y restauración**
   - Backups automáticos por horario.
   - Restaurar con 1 clic.

7. **Usuarios y permisos**
   - Owner/Admin/Moderador/Viewer.
   - Auditoría de acciones (logs de panel).

---

## 5) Stack base Docker (panel + monitoreo + ejemplo Minecraft)

```yaml
version: "3.9"

services:
  minecraft:
    image: itzg/minecraft-server:latest
    container_name: mc-survival
    environment:
      EULA: "TRUE"
      TYPE: "PAPER"
      VERSION: "LATEST"
      MEMORY: "6G"
      ENABLE_WHITELIST: "TRUE"
      ONLINE_MODE: "TRUE"
    ports:
      - "25565:25565"
    volumes:
      - ./data/minecraft-survival:/data
    restart: unless-stopped

  # Panel amigable (puedes sustituir por Crafty o panel propio)
  portainer:
    image: portainer/portainer-ce:latest
    container_name: panel-portainer
    ports:
      - "9443:9443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./data/portainer:/data
    restart: unless-stopped

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker:/var/lib/docker:ro
    restart: unless-stopped

  node_exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    restart: unless-stopped

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - ./monitoring/grafana:/var/lib/grafana
    restart: unless-stopped
```

---

## 6) Configuración y personalización (checklist)

Para una experiencia realmente “tipo Crafty”:

- [ ] Templates por tipo de juego (vanilla, Paper, modded).
- [ ] Presets de recursos (2G, 4G, 8G, 12G RAM).
- [ ] Editor web de archivos de configuración.
- [ ] Consola RCON/STDIN integrada en panel.
- [ ] Botones directos en UI: Encender / Apagar / Reiniciar / Forzar apagado.
- [ ] Sistema de tareas programadas (backup/restart/update).
- [ ] Control de acceso por usuarios y roles.
- [ ] Soporte de skins personalizadas con política configurable por servidor.
- [ ] Logs centralizados y exportables.

---

## 7) Servidores privados: buenas prácticas

- Activar whitelist y lista de operadores.
- Separar servidor público y privado en instancias distintas.
- Usar proxy (Velocity/Bungee) para redes de servidores.
- Implementar backups incrementales + snapshots diarios.
- Limitar recursos por instancia para evitar caídas globales.

---

## 8) Integración con MineColab_Improved

Para migrar desde la base indicada:

1. Mantén la lógica de instalación inicial si te simplifica despliegue.
2. Pasa cada servidor a contenedor dedicado y persistente.
3. Añade panel amigable para operaciones diarias (estilo Crafty).
4. Separa observabilidad en stack independiente.
5. Crea plantillas por juego para despliegue rápido.

Resultado: misma facilidad de uso, pero más robusto, portable y fácil de escalar.

---

## 9) Comandos operativos rápidos

```bash
# Levantar toda la plataforma
docker compose up -d

# Ver consumo en tiempo real
docker stats

# Ver logs de Minecraft
docker logs -f mc-survival

# Reiniciar solo un servidor
docker restart mc-survival

# Backup rápido
tar -czf backups/mc-survival-$(date +%F-%H%M).tar.gz data/minecraft-survival
```

---

## 10) Resumen final

Si buscas algo “como Crafty” pero adaptable a Minecraft y juegos similares:

- Usa panel amigable + contenedores por servidor.
- Añade monitoreo en tiempo real con Grafana/Prometheus.
- Implementa roles, backups, consola web y plantillas.
- Ajusta compatibilidad de launcher según versión/mods/autenticación.

Con esta base tendrás una experiencia de administración sencilla para usuarios finales y suficiente control para personalización avanzada.
