#!/bin/bash

# Colores para la interfaz de usuario
VERDE='\033[0;32m'
AZUL='\033[0;34m'
AMARILLO='\033[1;33m'
ROJO='\033[0;31m'
NC='\033[0m' # Sin color (Reset)

# Encabezado inicial
echo -e "${AZUL}==================================================${NC}"
echo -e "${AZUL}          GESTOR DE USUARIOS MYSQL/MARIADB        ${NC}"
echo -e "${AZUL}==================================================${NC}"
echo ""

# 1. Solicitar credenciales del Administrador de MySQL
echo -e "${AMARILLO}[+] Credenciales de Administrador (Root o similar)${NC}"
read -p "Usuario admin de MySQL [root]: " MYSQL_ADMIN
MYSQL_ADMIN=${MYSQL_ADMIN:-root}

# Leer la contraseña del admin de forma oculta
read -s -p "Contraseña de $MYSQL_ADMIN: " MYSQL_ADMIN_PASS
echo -e "\n"

# Probar la conexión antes de continuar
mysql -u"$MYSQL_ADMIN" -p"$MYSQL_ADMIN_PASS" -e ";" 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${ROJO}[!] Error: No se pudo conectar a MySQL con esas credenciales.${NC}"
    exit 1
fi
echo -e "${VERDE}[✓] Conexión con el administrador verificada.${NC}\n"

# 2. Menú de Selección de Acción
echo -e "${AMARILLO}[+] ¿Qué acción deseas realizar?${NC}"
echo -e "1) Crear un nuevo usuario"
echo -e "2) Modificar los permisos de un usuario"
echo -e "3) ${ROJO}Eliminar un usuario existente${NC}"
read -p "Selecciona una opción (1-3): " ACCION

echo ""

ASIGNAR_PERMISOS="n"

# ==========================================
# OPCIÓN 1: CREAR NUEVO USUARIO
# ==========================================
if [ "$ACCION" == "1" ]; then

    echo -e "${AMARILLO}[+] Configuración del Nuevo Usuario${NC}"
    read -p "Nombre del nuevo usuario: " NUEVO_USUARIO
    if [ -z "$NUEVO_USUARIO" ]; then
        echo -e "${ROJO}[!] El nombre de usuario no puede estar vacío.${NC}"
        exit 1
    fi

    read -p "Host de conexión (ej. localhost, %, 192.168.1.5) [localhost]: " HOST_USUARIO
    HOST_USUARIO=${HOST_USUARIO:-localhost}

    # Leer la contraseña del nuevo usuario de forma oculta
    read -s -p "Contraseña para $NUEVO_USUARIO: " NUEVO_PASS
    echo ""
    read -s -p "Confirme la contraseña: " NUEVO_PASS_CONFIRM
    echo -e "\n"

    if [ "$NUEVO_PASS" != "$NUEVO_PASS_CONFIRM" ]; then
        echo -e "${ROJO}[!] Las contraseñas no coinciden.${NC}"
        exit 1
    fi

    # Creación del usuario en la base de datos
    echo -e "${AZUL}[*] Creando usuario en MySQL...${NC}"
    SQL_CREATE="CREATE USER '${NUEVO_USUARIO}'@'${HOST_USUARIO}' IDENTIFIED BY '${NUEVO_PASS}';"
    mysql -u"$MYSQL_ADMIN" -p"$MYSQL_ADMIN_PASS" -e "$SQL_CREATE" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo -e "${VERDE}[✓] Usuario '${NUEVO_USUARIO}'@'${HOST_USUARIO}' creado con éxito.${NC}\n"
    else
        echo -e "${ROJO}[!] Error al crear el usuario. ¿Quizás ya existe?${NC}"
        exit 1
    fi

    # Preguntar si quiere añadir permisos
    read -p "¿Desea asignar permisos a este usuario ahora mismo? (s/n): " ASIGNAR_PERMISOS
    echo ""

# ==========================================
# OPCIÓN 2: MODIFICAR USUARIO EXISTENTE
# ==========================================
elif [ "$ACCION" == "2" ]; then

    echo -e "${AMARILLO}[+] Modificar Permisos de Usuario Existente${NC}"

    # Listar usuarios actuales
    echo -e "${AZUL}[*] Usuarios actuales en el sistema (User @ Host):${NC}"
    mysql -u"$MYSQL_ADMIN" -p"$MYSQL_ADMIN_PASS" -e "SELECT User, Host FROM mysql.user;" 2>/dev/null | grep -Ev "User|Host" | sed 's/\t/ @ /' | sed 's/^/  - /'
    echo ""

    read -p "Introduce el nombre del usuario: " NUEVO_USUARIO
    read -p "Introduce su host de conexión (ej. localhost, %): " HOST_USUARIO

    if [ -z "$NUEVO_USUARIO" ] || [ -z "$HOST_USUARIO" ]; then
        echo -e "${ROJO}[!] El usuario y el host son campos obligatorios.${NC}"
        exit 1
    fi

    ASIGNAR_PERMISOS="s"

# ==========================================
# OPCIÓN 3: ELIMINAR USUARIO
# ==========================================
elif [ "$ACCION" == "3" ]; then

    echo -e "${ROJO}[+] Eliminar Usuario de MySQL${NC}"

    # Listar usuarios actuales
    echo -e "${AZUL}[*] Usuarios actuales en el sistema (User @ Host):${NC}"
    mysql -u"$MYSQL_ADMIN" -p"$MYSQL_ADMIN_PASS" -e "SELECT User, Host FROM mysql.user;" 2>/dev/null | grep -Ev "User|Host" | sed 's/\t/ @ /' | sed 's/^/  - /'
    echo ""

    read -p "Nombre del usuario a eliminar: " USER_DROP
    read -p "Host de conexión del usuario (ej. localhost, %): " HOST_DROP

    if [ -z "$USER_DROP" ] || [ -z "$HOST_DROP" ]; then
        echo -e "${ROJO}[!] Campos incompletos. Operación cancelada.${NC}"
        exit 1
    fi

    # Confirmación de seguridad de destrucción
    echo -e "\n${ROJO}[!] ADVERTENCIA: Esta acción borrará al usuario '${USER_DROP}'@'${HOST_DROP}' de forma permanente.${NC}"
    read -p "¿Estás completamente seguro de continuar? (s/N): " CONFIRMAR_DROP

    if [[ "$CONFIRMAR_DROP" =~ ^[Ss]$ ]]; then
        echo -e "${AZUL}[*] Eliminando usuario...${NC}"
        SQL_DROP="DROP USER '${USER_DROP}'@'${HOST_DROP}';"
        mysql -u"$MYSQL_ADMIN" -p"$MYSQL_ADMIN_PASS" -e "$SQL_DROP" 2>/dev/null

        if [ $? -eq 0 ]; then
            echo -e "${VERDE}[✓] Usuario '${USER_DROP}'@'${HOST_DROP}' eliminado correctamente.${NC}"
        else
            echo -e "${ROJO}[!] Error al eliminar al usuario. Verifica si el nombre y el host coinciden exactamente.${NC}"
        fi
    else
        echo -e "${AMARILLO}[*] Operación cancelada por el usuario.${NC}"
    fi

else
    echo -e "${ROJO}[!] Opción no válida. Saliendo del script...${NC}"
    exit 1
fi


# ==========================================
# BLOQUE COMPARTIDO: ASIGNACIÓN DE PERMISOS
# ==========================================
if [[ "$ASIGNAR_PERMISOS" =~ ^[Ss]$ ]]; then
    echo -e "${AMARILLO}[+] Configuración de Privilegios para '${NUEVO_USUARIO}'@'${HOST_USUARIO}'${NC}"

    # Listar bases de datos disponibles
    echo -e "${AZUL}[*] Bases de datos actuales:${NC}"
    mysql -u"$MYSQL_ADMIN" -p"$MYSQL_ADMIN_PASS" -e "SHOW DATABASES;" 2>/dev/null | grep -Ev "Database|information_schema|performance_schema|sys|mysql" | sed 's/^/  - /'
    echo ""

    read -p "Nombre de la base de datos (use * para todas): " DB_NAME
    DB_NAME=${DB_NAME:-*}

    read -p "Nombre de la tabla (deja vacío para todas): " TABLE_NAME
    TABLE_NAME=${TABLE_NAME:-*}

    echo -e "\nSeleccione el tipo de privilegios:"
    echo -e "1) ${VERDE}TODOS los privilegios${NC} (ALL PRIVILEGES)"
    echo -e "2) ${AZUL}Solo Lectura${NC} (SELECT)"
    echo -e "3) ${AMARILLO}Lectura y Escritura${NC} (SELECT, INSERT, UPDATE, DELETE)"
    echo -e "4) ${AMARILLO}Lectura y Escritura sin borrado${NC} (SELECT, INSERT, UPDATE)"
    read -p "Opción (1-4) [1]: " OPCION_PERMISOS
    OPCION_PERMISOS=${OPCION_PERMISOS:-1}

    case $OPCION_PERMISOS in
        2) PRIVILEGIOS="SELECT" ;;
        3) PRIVILEGIOS="SELECT, INSERT, UPDATE, DELETE" ;;
        4) PRIVILEGIOS="SELECT, INSERT, UPDATE" ;;
        1|*) PRIVILEGIOS="ALL PRIVILEGES" ;;
    esac

    echo -e "\n${AZUL}[*] Aplicando permisos...${NC}"
    SQL_GRANT="GRANT ${PRIVILEGIOS} ON ${DB_NAME}.${TABLE_NAME} TO '${NUEVO_USUARIO}'@'${HOST_USUARIO}'; FLUSH PRIVILEGES;"
    mysql -u"$MYSQL_ADMIN" -p"$MYSQL_ADMIN_PASS" -e "$SQL_GRANT" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo -e "${VERDE}[✓] Permisos (${PRIVILEGIOS}) aplicados correctamente sobre '${DB_NAME}.*'.${NC}"
    else
        echo -e "${ROJO}[!] Error al aplicar los privilegios. Asegúrate de que el usuario existe.${NC}"
    fi
fi

echo -e "\n${VERDE}==================================================${NC}"
echo -e "${VERDE}          ¡Proceso finalizado con éxito!          ${NC}"
echo -e "${VERDE}==================================================${NC}\n"
