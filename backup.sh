#!/bin/bash
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="backups/flows/$DATE"
mkdir -p "$BACKUP_DIR"

# Copia los datos de n8n (Workflows, credenciales, settings)
cp -r n8n_data "$BACKUP_DIR"

# Git commit (si es parte de un repo)
cd backups
git add .
git commit -m "Backup n8n $DATE"
cd ..
