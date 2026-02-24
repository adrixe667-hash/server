# Plataforma tipo Crafty para servidores propios/privados (Minecraft y similares)

Esta guía está diseñada para montar una plataforma **estilo Crafty**: interfaz amigable, gestión centralizada, creación de servidores privados/propios y alta personalización, enfocada en **Minecraft** y otros juegos que permitan hosting dedicado.

Base de referencia solicitada:

- https://github.com/N-aksif-N/MineColab_Improved

---


## Implementación incluida en este repositorio

Además de la guía, este repositorio ya incluye una base funcional:

- `docker-compose.yml` (Minecraft + panel + monitoreo)
- `.env.example` (configuración editable)
- `monitoring/prometheus.yml` (métricas)
- `scripts/quickstart.sh` (inicio rápido)
- `scripts/manage_server.sh` (start/stop/restart + comandos admin OP/deOP/give/kick/ban/mute)
- `scripts/backup.sh` (backup con retención)

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
   - Variables de entorno (RAM, versión, tipo: Paper/Purpur/Fabric/NeoFabric/NeoForge/Forge).
   - Edición de archivos (`server.properties`, `ops.json`, whitelist, etc.).
   - Programación de reinicios y tareas.

4. **Administración de chat (Minecraft)**
   - Acciones rápidas desde panel y consola: **dar OP**, **quitar OP**, **dar ítems**, **kick**, **ban**, **mute**.
   - Comandos preconfigurados sugeridos:
     - `/op <jugador>`
     - `/deop <jugador>`
     - `/give <jugador> <item> <cantidad>`
   - Historial/auditoría de comandos administrativos ejecutados desde el panel.

5. **Plugins / mods / packs**
   - Carga por archivo o URL.
   - Perfiles por tipo de servidor.
   - Validación de compatibilidad por versión (loader + API + versión de servidor).

6. **Skins personalizadas (Minecraft)**
   - Selector para modo premium (`online-mode=true`) o modo compatible con no-premium (`online-mode=false`).
   - Soporte de skins personalizadas mediante plugin/proxy (por ejemplo SkinRestorer en entornos no-premium).
   - Opción de política: permitir solo skins oficiales, o habilitar skins personalizadas por servidor.

7. **Backups y restauración**
   - Backups automáticos por horario.
   - Restaurar con 1 clic.

8. **Usuarios y permisos**
   - Owner/Admin/Moderador/Viewer.
   - Auditoría de acciones (logs de panel).

---

## 5) Selector de opciones fácil para usuario (modo asistente)

En la interfaz, agrega un asistente de 6 pasos con menús desplegables y presets:

1. **Juego**: Minecraft Java / Minecraft Bedrock / Terraria / Valheim.
2. **Tipo de servidor**: Vanilla / Paper / Purpur / Fabric / NeoFabric / NeoForge / Forge.
3. **Modo de acceso**: Privado (whitelist) / Público.
4. **Rendimiento**: Bajo (2G) / Medio (4G) / Alto (8G) / Extremo (12G+).
5. **Red**: IP pública / playit.gg / Cloudflare Tunnel / Tailscale.
6. **Seguridad**: 2FA panel, backup automático, anti-bot, logs de auditoría.

### Botones recomendados (UX simple)
- **Crear servidor**
- **Aplicar plantilla**
- **Encender**
- **Apagar**
- **Reiniciar**
- **Abrir consola**
- **Backup ahora**
- **Restaurar backup**

---

## 6) Stack base Docker (panel + monitoreo + ejemplo Minecraft)

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

### Código mejorado (plantillas con `.env` para uso fácil)

Archivo `.env` sugerido:

```env
MC_NAME=mc-survival
MC_TYPE=PAPER
MC_VERSION=LATEST
MC_MEMORY=6G
MC_PORT=25565
MC_ONLINE_MODE=TRUE
MC_ENABLE_WHITELIST=TRUE
```

Bloque `minecraft` mejorado en `docker-compose.yml`:

```yaml
minecraft:
  image: itzg/minecraft-server:latest
  container_name: ${MC_NAME}
  environment:
    EULA: "TRUE"
    TYPE: ${MC_TYPE}
    VERSION: ${MC_VERSION}
    MEMORY: ${MC_MEMORY}
    ONLINE_MODE: ${MC_ONLINE_MODE}
    ENABLE_WHITELIST: ${MC_ENABLE_WHITELIST}
  ports:
    - "${MC_PORT}:25565"
  volumes:
    - ./data/${MC_NAME}:/data
  restart: unless-stopped
```

Con esto el usuario cambia opciones sin tocar YAML complejo.

---

## Compatibilidad específica: Fabric, NeoFabric y NeoForge

Para cubrir tu requisito de compatibilidad:

- **Fabric**: usar servidor compatible con Fabric Loader + API/mods de la misma versión de Minecraft.
- **NeoFabric**: validar que el modpack y las librerías estén preparadas para NeoFabric y versión exacta del loader.
- **NeoForge**: usar build de NeoForge alineado con la versión del servidor y dependencias del modpack.
- En el panel, define plantillas separadas por loader para evitar mezclar mods incompatibles entre Fabric/NeoFabric/NeoForge.

---

## 7) Configuración y personalización (checklist)

Para una experiencia realmente “tipo Crafty”:

- [ ] Templates por tipo de juego (vanilla, Paper, modded).
- [ ] Presets de recursos (2G, 4G, 8G, 12G RAM).
- [ ] Editor web de archivos de configuración.
- [ ] Consola RCON/STDIN integrada en panel.
- [ ] Botones directos en UI: Encender / Apagar / Reiniciar / Forzar apagado.
- [ ] Acciones admin de chat: dar/quitar OP, dar ítems, ban/kick/mute con auditoría.
- [ ] Sistema de tareas programadas (backup/restart/update).
- [ ] Control de acceso por usuarios y roles.
- [ ] Soporte de skins personalizadas con política configurable por servidor.
- [ ] Compatibilidad de mods validada por versión y tipo de loader (Fabric/NeoFabric/NeoForge/Forge).
- [ ] Logs centralizados y exportables.

---

## 8) Servidores privados: buenas prácticas

- Activar whitelist y lista de operadores.
- Separar servidor público y privado en instancias distintas.
- Usar proxy (Velocity/Bungee) para redes de servidores.
- Implementar backups incrementales + snapshots diarios.
- Limitar recursos por instancia para evitar caídas globales.

### Seguridad recomendada para **todos** los servidores

- Activar firewall por host/proyecto (UFW o nftables) con política deny-by-default.
- Aislar cada instancia en red Docker propia y abrir solo puertos necesarios.
- Habilitar autenticación fuerte en panel (2FA) + contraseñas robustas.
- Usar roles mínimos necesarios (principio de mínimo privilegio).
- Configurar antispam/antibot y protección DDoS en capa proxy/túnel.
- Aplicar actualizaciones regulares de imágenes, plugins y panel.
- Mantener rotación de logs + alertas automáticas (caídas, picos RAM/CPU, intentos fallidos).

---

## 9) Publicación online y túneles compatibles

Opciones recomendadas para exponer servidores privados/públicos:

1. **playit.gg**
   - Útil cuando no puedes abrir puertos o estás detrás de CGNAT.
   - Configuración rápida para publicar puertos de juego.

2. **Cloudflare Tunnel**
   - Recomendado para panel web y APIs administrativas con HTTPS.
   - Ideal para ocultar IP real del host.

3. **Tailscale / Headscale**
   - Excelente para administración privada entre administradores.
   - Acceso seguro sin exponer puertos de gestión.

4. **IP pública + NAT/port forwarding**
   - Opción clásica con máximo control, requiere hardening completo.

> Sugerencia práctica: usar Cloudflare Tunnel para el panel, y playit.gg o puertos directos solo para tráfico de juego.

---

## 10) Integración con MineColab_Improved

Para migrar desde la base indicada:

1. Mantén la lógica de instalación inicial si te simplifica despliegue.
2. Pasa cada servidor a contenedor dedicado y persistente.
3. Añade panel amigable para operaciones diarias (estilo Crafty).
4. Separa observabilidad en stack independiente.
5. Crea plantillas por juego para despliegue rápido.

Resultado: misma facilidad de uso, pero más robusto, portable y fácil de escalar.

---

## 11) Comandos operativos rápidos

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

## 12) Instrucciones de uso (paso a paso para usuario final)

1. **Abrir panel** en navegador (`https://TU-DOMINIO:9443` o dominio del proxy).
2. **Crear instancia** con el botón `Crear servidor`.
3. Elegir en el selector:
   - juego,
   - tipo (Paper/Fabric/NeoFabric/NeoForge/etc),
   - RAM,
   - modo privado/público.
4. Pulsar **Aplicar plantilla** para cargar configuración base segura.
5. Configurar administración:
   - whitelist,
   - operadores,
   - permisos por rol en panel.
6. Pulsar **Encender** para iniciar.
7. Verificar en consola que no hay errores de mods/plugins.
8. Probar conexión desde launcher compatible con la misma versión.
9. Activar backup automático y alertas (CPU/RAM/caída).
10. Operación diaria:
    - **Reiniciar** para cambios de mods,
    - **Apagar** antes de mantenimiento,
    - **Backup ahora** antes de actualizaciones.

---

## 13) Dudas frecuentes (FAQ)

**1) ¿Se puede compatibilidad total con todos los mods?**
No al 100%. Depende de versión de Minecraft, loader (Fabric/NeoFabric/NeoForge/Forge), dependencias y conflictos entre mods.

**2) ¿Qué hago si un mod no carga?**
Revisar logs, confirmar versión exacta del loader, API requerida y librerías faltantes. Probar en plantilla limpia.

**3) ¿Cómo activo skins personalizadas?**
En premium usa autenticación oficial. En no-premium, habilita plugin/proxy compatible (ej. SkinRestorer) y define política de skins.

**4) ¿playit.gg o Cloudflare Tunnel?**
- playit.gg: muy práctico para puertos de juego con CGNAT.
- Cloudflare Tunnel: ideal para panel web/API con HTTPS y ocultar IP.

**5) ¿Cómo doy o quito OP rápido?**
Desde panel en acciones admin o consola:
- `/op <jugador>`
- `/deop <jugador>`

**6) ¿Cómo evitar que entren usuarios no autorizados?**
Activa whitelist, usa roles mínimos, habilita 2FA en panel y limita puertos expuestos.

---

## 14) Resumen final


Si buscas algo “como Crafty” pero adaptable a Minecraft y juegos similares:

- Usa panel amigable + contenedores por servidor.
- Añade monitoreo en tiempo real con Grafana/Prometheus.
- Implementa roles, backups, consola web y plantillas.
- Añade funciones admin de chat (OP, deOP, give, kick, ban, mute) con auditoría.
- Ajusta compatibilidad de launcher según versión/mods/autenticación.
- Publica con playit.gg, Cloudflare Tunnel, Tailscale o puertos directos según tu red.

Con esta base tendrás una experiencia de administración sencilla para usuarios finales y suficiente control para personalización avanzada.

---

## 15) Ideas para mejorar el proyecto (roadmap recomendado)

Si quieres subir el nivel del proyecto de "guía" a "plataforma sólida", estas son mejoras con alto impacto:

### Prioridad alta (rápidas y útiles)

1. **Plantillas 1-clic por tipo de servidor**
   - Vanilla, Paper, Purpur, Fabric, NeoFabric, NeoForge.
   - Cada plantilla con validaciones mínimas (versión, RAM, puertos, whitelist).

2. **Asistente de diagnóstico automático**
   - Botón `Diagnosticar` que revise:
     - puertos ocupados,
     - errores de permisos,
     - conflictos de mods/plugins,
     - falta de memoria.

3. **Backups con retención inteligente**
   - Política por defecto: diarios (7), semanales (4), mensuales (3).
   - Restauración guiada con vista previa de fecha/tamaño.

4. **Alertas en tiempo real**
   - Telegram/Discord/email para:
     - servidor caído,
     - RAM > 85%,
     - CPU alta sostenida,
     - backup fallido.

### Prioridad media (escalabilidad)

5. **Sistema de plugins del panel**
   - Permitir módulos externos para comandos, tickets, economía, etc.

6. **Panel multi-nodo**
   - Un panel central para gestionar varios hosts.
   - Balanceo por carga para repartir instancias.

7. **Marketplace privado de plantillas/modpacks**
   - Catálogo interno con versiones verificadas.
   - Instalación con un clic y rollback.

### Prioridad avanzada (nivel producción)

8. **CI/CD para actualizaciones seguras**
   - Pipeline de pruebas de arranque antes de aplicar updates en producción.

9. **Observabilidad avanzada**
   - Dashboards por jugador/latencia/TPS y trazas de eventos críticos.

10. **Hardening completo de seguridad**
   - SSO/OAuth2 para panel, rotación automática de secretos y auditoría centralizada.

### Métrica de éxito recomendada

- Tiempo de creación de servidor: **< 3 minutos**.
- Tasa de fallos por actualización: **< 5%**.
- Tiempo medio de recuperación (MTTR): **< 10 minutos**.
- Éxito de backups: **> 99%**.

