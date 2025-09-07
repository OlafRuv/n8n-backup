#!/bin/bash
# Script para restaurar n8n desde un backup

if [ $# -eq 0 ]; then
    echo "❌ Error: Debes especificar la fecha del backup a restaurar"
    echo "💡 Uso: ./restore.sh YYYY-MM-DD_HH-MM-SS"
    echo "📁 Backups disponibles:"
    ls -la backups/flows/ | grep "^d" | awk '{print $9}' | grep -v "^\.$" | grep -v "^\.\.$"
    exit 1
fi

BACKUP_DATE="$1"
BACKUP_DIR="backups/flows/$BACKUP_DATE"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Error: No se encontró el backup con fecha $BACKUP_DATE"
    echo "📁 Backups disponibles:"
    ls -la backups/flows/ | grep "^d" | awk '{print $9}' | grep -v "^\.$" | grep -v "^\.\.$"
    exit 1
fi

echo "🔄 Iniciando restauración desde backup: $BACKUP_DATE"
echo "📁 Directorio de backup: $BACKUP_DIR"

# Verificar que n8n no esté corriendo
if docker ps | grep -q n8n; then
    echo "⚠️  n8n está corriendo. Deteniendo contenedor..."
    docker-compose down
fi

# Crear directorio n8n_data si no existe
mkdir -p n8n_data

# Restaurar database.sqlite
echo "📦 Restaurando database.sqlite..."
if [ -f "$BACKUP_DIR/database.sqlite" ]; then
    cp "$BACKUP_DIR/database.sqlite" n8n_data/
    echo "✅ database.sqlite restaurado"
else
    echo "❌ Error: No se encontró database.sqlite en el backup"
    exit 1
fi

# Restaurar binaryData
echo "📦 Restaurando binaryData..."
if [ -d "$BACKUP_DIR/binaryData" ]; then
    cp -r "$BACKUP_DIR/binaryData" n8n_data/
    echo "✅ binaryData restaurado"
else
    echo "⚠️  No se encontró binaryData en el backup"
fi

# Restaurar nodes personalizados
echo "📦 Restaurando nodes personalizados..."
if [ -d "$BACKUP_DIR/nodes" ]; then
    cp -r "$BACKUP_DIR/nodes" n8n_data/
    echo "✅ nodes restaurados"
else
    echo "⚠️  No se encontraron nodes personalizados en el backup"
fi

# Crear archivo config básico (sin claves sensibles)
echo "📝 Creando archivo config básico..."
cat > n8n_data/config << EOF
{
    "encryptionKey": "$(openssl rand -hex 16)"
}
EOF
echo "✅ Archivo config creado con nueva clave de encriptación"

# Ajustar permisos
echo "🔧 Ajustando permisos..."
chmod -R 755 n8n_data/

echo "✅ Restauración completada"
echo "🚀 Iniciando n8n..."
docker-compose up -d

echo "🎉 n8n restaurado y ejecutándose"
echo "🌐 Accede a: http://localhost:5678"
echo "👤 Usuario: admin"
echo "🔑 Contraseña: admin123"
echo ""
echo "⚠️  IMPORTANTE:"
echo "   - Las credenciales necesitarán ser reconfiguradas"
echo "   - Las claves SSH necesitarán ser reconfiguradas"
echo "   - Algunos workflows pueden necesitar ajustes"
