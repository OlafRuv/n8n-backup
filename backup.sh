#!/bin/bash
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="backups/flows/$DATE"
mkdir -p "$BACKUP_DIR"

echo "🔄 Iniciando backup de n8n - $DATE"

# Copia SOLO los datos importantes (excluyendo archivos sensibles)
echo "📦 Copiando database.sqlite..."
cp n8n_data/database.sqlite "$BACKUP_DIR/"

echo "📦 Copiando binaryData..."
cp -r n8n_data/binaryData "$BACKUP_DIR/"

echo "📦 Copiando nodes personalizados..."
cp -r n8n_data/nodes "$BACKUP_DIR/"

# Crear archivo de información del backup
echo "📝 Creando archivo de información..."
cat > "$BACKUP_DIR/backup_info.txt" << EOF
Backup de n8n
Fecha: $DATE
Contenido:
- database.sqlite (workflows, credenciales, historial)
- binaryData/ (archivos adjuntos)
- nodes/ (nodos personalizados)

Archivos EXCLUIDOS por seguridad:
- config (contiene claves de encriptación)
- ssh/ (claves SSH privadas)
- *.log (logs con información sensible)
EOF

echo "✅ Backup completado en: $BACKUP_DIR"

# Git commit desde el directorio raíz (donde está el repo)
echo "📝 Haciendo commit al repositorio..."
git add "$BACKUP_DIR"
git commit -m "Backup n8n $DATE - workflows y datos importantes"

echo "🎉 Backup y commit completados exitosamente"
