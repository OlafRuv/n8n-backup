# n8n Local - Sistema de Backup y Restauración

## 🎯 Propósito del Proyecto

Este proyecto proporciona una solución completa para **automatizar el backup y restauración de instancias n8n** ejecutándose en Docker. Está diseñado para:

- **Proteger tus workflows** de n8n con backups automáticos
- **Versionar cambios** usando Git para control de versiones
- **Restaurar fácilmente** tus workflows en cualquier momento
- **Mantener la seguridad** excluyendo datos sensibles de los backups
- **Sincronizar** tus backups con repositorios remotos

## 🏗️ Arquitectura

```
n8n-local/
├── docker-compose.yml    # Configuración de n8n con Docker
├── backup.sh            # Script de backup automático
├── restore.sh           # Script de restauración
├── .gitignore           # Protección de datos sensibles
├── n8n_data/           # Datos de n8n (excluido de git)
└── backups/            # Backups versionados
    └── flows/
        ├── 2025-09-06_21-19-46/
        ├── 2025-09-06_21-20-13/
        └── 2025-09-06_21-20-57/
```

## 🚀 Instalación y Configuración

### Prerrequisitos
- Docker y Docker Compose
- Git
- Bash (Linux/macOS)

### 1. Clonar el repositorio
```bash
git clone <tu-repositorio>
cd n8n-local
```

### 2. Configurar n8n
```bash
# Iniciar n8n por primera vez
docker-compose up -d

# Acceder a n8n
# URL: http://localhost:5678
# Usuario: admin
# Contraseña: admin123
```

### 3. Configurar Git (opcional)
```bash
# Si quieres sincronizar con un repositorio remoto
git remote add origin <tu-repositorio-remoto>
git push -u origin main
```

## 📦 Uso del Sistema de Backup

### Backup Automático
```bash
# Ejecutar backup manual
./backup.sh
```

**¿Qué hace el backup?**
- ✅ Crea directorio con timestamp: `backups/flows/YYYY-MM-DD_HH-MM-SS/`
- ✅ Copia `database.sqlite` (workflows, credenciales, historial)
- ✅ Copia `binaryData/` (archivos adjuntos)
- ✅ Copia `nodes/` (nodos personalizados)
- ✅ Crea archivo de documentación del backup
- ✅ Hace commit a Git con mensaje descriptivo
- ✅ Sube cambios al repositorio remoto (si está configurado)

**Archivos EXCLUIDOS por seguridad:**
- ❌ `config` (contiene claves de encriptación)
- ❌ `ssh/` (claves SSH privadas)
- ❌ `*.log` (logs con información sensible)

### Programar Backups Automáticos

#### Con Cron (Linux/macOS)
```bash
# Editar crontab
crontab -e

# Agregar línea para backup cada 6 horas
0 */6 * * * cd /ruta/a/n8n-local && ./backup.sh >> backup.log 2>&1

# Backup diario a las 2 AM
0 2 * * * cd /ruta/a/n8n-local && ./backup.sh >> backup.log 2>&1
```

#### Con systemd (Linux)
```bash
# Crear servicio
sudo nano /etc/systemd/system/n8n-backup.service

# Crear timer
sudo nano /etc/systemd/system/n8n-backup.timer

# Habilitar y iniciar
sudo systemctl enable n8n-backup.timer
sudo systemctl start n8n-backup.timer
```

## 🔄 Restauración de Backups

### Ver Backups Disponibles
```bash
./restore.sh
```

### Restaurar un Backup Específico
```bash
./restore.sh 2025-09-06_21-20-57
```

**¿Qué hace la restauración?**
- ✅ Detiene n8n si está corriendo
- ✅ Restaura `database.sqlite` con todos los workflows
- ✅ Restaura `binaryData/` con archivos adjuntos
- ✅ Restaura `nodes/` personalizados
- ✅ Crea nueva clave de encriptación (por seguridad)
- ✅ Ajusta permisos correctamente
- ✅ Inicia n8n con los datos restaurados

### ⚠️ Consideraciones Post-Restauración

**Después de restaurar necesitarás:**
1. **Reconfigurar credenciales** - APIs, bases de datos, servicios externos
2. **Reconfigurar claves SSH** - Conexiones SSH
3. **Verificar workflows** - Algunos pueden necesitar ajustes menores
4. **Cambiar contraseña** - La contraseña de n8n sigue siendo `admin123`

## 🔒 Seguridad

### Datos Protegidos
El sistema está diseñado para **NUNCA** incluir datos sensibles en los backups:

- **Claves de encriptación** - Se excluyen del backup
- **Credenciales reales** - Están encriptadas en la base de datos
- **Claves SSH** - Se excluyen completamente
- **Logs sensibles** - Se excluyen del backup

### Archivo .gitignore
```gitignore
# n8n Data Directory - Datos sensibles de n8n
n8n_data/

# Archivos de base de datos
*.sqlite
*.sqlite3
*.db

# Archivos de configuración sensibles
config
*.env
.env*

# Archivos de credenciales SSH
ssh/
*.pem
*.key
id_rsa*
id_ed25519*
```

## 📊 Monitoreo y Logs

### Ver Logs de Backup
```bash
# Si usas cron con redirección a archivo
tail -f backup.log

# Ver commits recientes
git log --oneline -10

# Ver estado del repositorio
git status
```

### Verificar Integridad de Backups
```bash
# Listar todos los backups
ls -la backups/flows/

# Ver información de un backup específico
cat backups/flows/2025-09-06_21-20-57/backup_info.txt

# Verificar tamaño de la base de datos
ls -lh backups/flows/*/database.sqlite
```

## 🛠️ Mantenimiento

### Limpiar Backups Antiguos
```bash
# Eliminar backups más antiguos que 30 días
find backups/flows -type d -mtime +30 -exec rm -rf {} \;

# O mantener solo los últimos 10 backups
ls -t backups/flows/ | tail -n +11 | xargs -I {} rm -rf backups/flows/{}
```

### Actualizar n8n
```bash
# Hacer backup antes de actualizar
./backup.sh

# Actualizar imagen de n8n
docker-compose pull
docker-compose up -d
```

### Respaldo del Repositorio
```bash
# Crear respaldo completo del proyecto
tar -czf n8n-backup-$(date +%Y%m%d).tar.gz \
    --exclude=n8n_data \
    --exclude=backups \
    .
```

## 🚨 Solución de Problemas

### Error: "Falló el push al repositorio remoto"
```bash
# Verificar conexión
git remote -v

# Hacer push manual
git push origin main

# Verificar credenciales de Git
git config --list
```

### Error: "No se encontró database.sqlite"
```bash
# Verificar que n8n esté corriendo
docker ps | grep n8n

# Verificar directorio de datos
ls -la n8n_data/

# Reiniciar n8n
docker-compose restart
```

### Error: "Permisos denegados"
```bash
# Ajustar permisos
chmod +x backup.sh restore.sh
chmod -R 755 n8n_data/
```

## 📈 Mejores Prácticas

1. **Backups regulares** - Programa backups automáticos
2. **Pruebas de restauración** - Prueba la restauración periódicamente
3. **Monitoreo** - Revisa logs regularmente
4. **Versionado** - Usa Git para control de versiones
5. **Seguridad** - Nunca incluyas datos sensibles en backups
6. **Documentación** - Mantén documentados tus workflows importantes

## 🤝 Contribuciones

Si encuentras bugs o quieres mejorar el sistema:

1. Crea un issue describiendo el problema
2. Fork el repositorio
3. Crea una rama para tu feature
4. Envía un pull request

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver archivo `LICENSE` para más detalles.

## 🆘 Soporte

Si necesitas ayuda:

1. Revisa la sección de solución de problemas
2. Consulta los logs de backup
3. Verifica la configuración de Git
4. Crea un issue en el repositorio

---

**¡Mantén tus workflows de n8n seguros y siempre respaldados!** 🚀
