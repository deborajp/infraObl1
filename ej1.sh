#!/bin/bash

echo "Debora Jimenez (266908)"
echo "Magdalena Becerra (314825)"
echo "Nicolas Cabrera ()"

# Función para agregar un usuarios nuevo
crear_usuario(){
    while true; do
        read -p "Ingrese usuario nuevo:" usuario_nuevo
                    
        #Verificar que usuario no exista dentro del archivo usuarios.txt
        if grep -q "$usuario_nuevo:" usuarios.txt; then
            echo "Ya existe ese usuario. Ingrese uno nuevo."
        else
            read -p "Ingrese contraseña nueva:" contrasena_nueva
            echo "$usuario_nuevo:$contrasena_nueva" >> usuarios.txt
            echo "El usuario '$usuario_nuevo' ha sido agregado correctamente."
            break
        fi
    done
}

# Función para cambiar contraseña
cambiar_contrasena(){
    while true; do
        read -p "Ingrese su nombre de usuario: " usuario

        if grep -q "^$usuario:" usuarios.txt; then
            break  # Usuario existe
        else
            echo "El usuario '$usuario' no existe. Intente nuevamente."
        fi
    done

    cambio_exitoso=false

    while [ "$cambio_exitoso" = false ]; do
        read -p "Ingrese su contraseña actual: " contrasena_actual
        credenciales="$usuario:$contrasena_actual"

        if grep -q "^$credenciales$" usuarios.txt; then
            while [ "$cambio_exitoso" = false ]; do
                read -p "Ingrese la nueva contraseña: " nueva_contrasena

                # Verificar que la nueva contraseña no sea igual a la actual
                if [ "$nueva_contrasena" = "$contrasena_actual" ]; then
                    echo "La nueva contraseña no puede ser igual a la actual. Intente otra."
                    continue
                fi

                read -p "Confirme la nueva contraseña: " confirmar_contrasena

                if [ "$nueva_contrasena" = "$confirmar_contrasena" ]; then
                    sed -i "s/^$usuario:$contrasena_actual$/$usuario:$nueva_contrasena/" usuarios.txt
                    echo "Contraseña actualizada correctamente para el usuario '$usuario'."
                    cambio_exitoso=true
                else
                    echo "Las contraseñas nuevas no coinciden. Intente de nuevo."
                fi
            done
        else
            echo "Contraseña actual incorrecta. Intente nuevamente."
        fi
    done
}


# Funcion para validar usuario al ingreso
login(){
    while true; do
        read -p "Ingrese su nombre de usuario: " usuario
        read -p "Ingrese su contraseña: " contrasena

        credenciales="$usuario:$contrasena"

        if grep -q "^$credenciales$" usuarios.txt; then
            echo "Credenciales válidas. Bienvenido, $usuario"
            break
        else
           echo "Credenciales inválidas. Por favor, vuelva a intentar."
        fi
    done
}

# Funcion del menu
mostrar_menu(){
	echo "1. Crear nuevo usuario"
	echo "2. Cambiar contraseña"
	echo "3. Ingresar producto"
	echo "4. Vender producto"
	echo "5. Filtro de productos"
	echo "6. Crear reporte de pinturas"
	echo "7. Salir"
}

# Llamar a la función para loguearse
login

# Se muestra el menu siempre que se termine de ejecutar una opcion para de esta forma nunca perder los datos de las variables que se establecieron, por ejemplo en el caso del diccionario
while true; do
	mostrar_menu
    	read -p "Seleccione una opción:" opcion
    	case $opcion in
    	1) crear_usuario ;;
    	2) cambiar_contrasena ;;
        3) ingresar_producto ;;
        4) vender_producto ;;
        5) filtrar_productos ;;
        6) crear_reporte ;;
    	7) echo "!Hasta luego!"; exit ;;
    	*) echo "Opción no válida. Por favor, seleccione una opción válida." ;;
    	esac
done

# Función para agregar un producto nuevo
crear_producto(){
    while true; do
        read -p "Ingrese el tipo de producto:" tipo
        #Verifica que el tipo sea uno permitido
        if grep -q "^$tipo" tipoProducto.txt; then
            read -p "Ingrese el modelo de producto:" modelo
            read -p "Ingrese la cantidad del producto:" cantidad
            #Revisa si el producto de ese tipo y modelo existe para actualizar la cantidad
            if grep -q "^$tipo:$modelo:" productos.txt; then
                actualizar_cantidad_producto "$tipo" "$modelo" "$cantidad"
            else
                read -p "Ingrese una descripcion para el producto:" descripcion
                read -p "Ingrese el precio del producto (debe ser un numero entero):" precio
                precio=$(echo "scale=0; $precio/1 + 0.5/1" | bc)
                codigo=${tipo^^:0:3}
                echo "$codigo:$tipo:$modelo:$descripcion:$cantidad:$precio" >> productos.txt
                echo "El producto ha sido agregado correctamente."
                break
            fi
        else
            echo "Este tipo de producto no es permitido. Ingrese uno nuevo."
        fi
    done
}

actualizar_cantidad_producto() {
    local tipo="$1"
    local modelo="$2"
    local cantidad_a_sumar="$3"

    # Verifica si el producto existe
    if grep -q "^$tipo:$modelo:" productos.txt; then
        linea=$(grep "^$tipo:$modelo:" productos.txt)
        codigo=$(echo "$linea" | cut -d: -f1)
        descripcion=$(echo "$linea" | cut -d: -f4)
        cantidad_actual=$(echo "$linea" | cut -d: -f5)
        precio=$(echo "$linea" | cut -d: -f6)

        #A la cantidad ya existente se le suma la cantidad ingresada
        nueva_cantidad=$((cantidad_actual + cantidad_a_sumar))

        nueva_linea="$codigo:$tipo:$modelo:$descripcion:$nueva_cantidad:$precio"
        sed -i.bak "/^$tipo:$modelo:/c\\$nueva_linea" productos.txt
        echo "El producto ha sido actualizado correctamente."

    else
        echo "El producto $tipo:$modelo no existe."
    fi
}

filtrar_productos_tipo(){
    local tipo="$1"
    if [[ -z "$tipo" ]]; then 
        cat productos.txt
    else
        grep -i "^$tipo:" productos.txt
    fi
}
