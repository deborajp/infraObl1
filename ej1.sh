#!/bin/bash

echo "Debora Jimenez (266908)"
echo "Magdalena Becerra (314825)"
echo "Nicolas Cabrera (307905)"

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
 

# Función para agregar un producto nuevo
crear_producto(){
    while true; do
        read -p "Ingrese el tipo de producto:" tipo
        #Verifica que el tipo sea uno permitido
        if grep -iwq "^$tipo" tipoProducto.txt; then
            codigo=${tipo^^}
            codigo=${codigo:0:3}
            read -p "Ingrese el modelo de producto:" modelo
            read -p "Ingrese la cantidad del producto:" cantidad
            #Revisa si el producto de ese tipo y modelo existe para actualizar la cantidad
            if grep -iwq "^$codigo:$tipo:$modelo:" productos.txt; then
                actualizar_cantidad_producto "$codigo" "$tipo" "$modelo" "$cantidad"
            else
                read -p "Ingrese una descripcion para el producto:" descripcion
                read -p "Ingrese el precio del producto (debe ser un numero entero):" precio
                #precio=$(echo "scale=0; $precio/1 + 0.5/1" | bc)
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
    local codigo="$1"
    local tipo="$2"
    local modelo="$3"
    local cantidad_a_sumar="$4"
    linea=$(grep -iw "^$codigo:$tipo:$modelo:" productos.txt)
    if [[ -n "$linea" ]]; then
        descripcion=$(echo "$linea" | cut -d: -f4)
        cantidad_actual=$(echo "$linea" | cut -d: -f5)
        precio=$(echo "$linea" | cut -d: -f6)

        #Calcula lanueva cantidad del producto
        nueva_cantidad=$((cantidad_actual + cantidad_a_sumar))

        nueva_linea="$codigo:$tipo:$modelo:$descripcion:$nueva_cantidad:$precio"
        sed -i.bak "s|^$codigo:$tipo:$modelo:.*|$nueva_linea|" productos.txt
        echo "El producto ha sido actualizado correctamente."
    else
        echo "El producto $tipo:$modelo no existe."
    fi
}


# Funcion para vender un producto
vender_producto() {
    echo " Venta de Productos"

    if [ ! -s productos.txt ]; then
        echo "No hay productos registrados"
        return
    fi

    echo "Lista de Productos disponibles:"
    nl -w2 -s ". " productos.txt

    total=0

    while true; do
        read -p "Ingrese el numero del producto a comprar (0 para terminar) " num

        if [ "$num" -eq 0 ]; then
            break
        fi

        linea=$(head -n "$num" productos.txt | tail -n 1)

        if [ -z "linea" ]; then
            echo "Numero invalido"
            continue
        fi

        codigo=$(echo "$linea" | cut -d: -f1)
        tipo=$(echo "$linea" | cut -d: -f2)
        modelo=$(echo "$linea" | cut -d: -f3)
        descripcion=$(echo "$linea" | cut -d: -f4)
        stock=$(echo "$linea" | cut -d: -f5)
        precio=$(echo "$linea" | cut -d: -f6)

        echo "Seleccionado: $tipo - $modelo"
        echo "Stock disponible: $stock unidades"
        echo "Precio unitario: $precio"

        read -p "Ingrese cantidad a comprar: " cantidad
        
        if [ "$cantidad" -le 0 ]; then
        echo "La cantidad debe ser mayor que 0"
        continue
fi

        if [ "$cantidad" -gt "$stock" ]; then
            echo "No hay suficiente stock disponible"
            continue
        fi

        nuevo_stock=$(($stock - $cantidad))
        total_item=$(($cantidad * $precio))
        total=$(($total + $total_item))

        # Actualizar el archivo productos.txt
        sed -i.bak "${num}s|.*|$nueva_linea|" productos.txt

        echo "Compra realizada: $cantidad unidades de $modelo por \$$total_item"
    done

    echo "Total de la compra : \$$total"


}


filtrar_productos_tipo(){
    read -p "Ingrese el tipo de producto que busca:" tipo
    if [[ -z "$tipo" ]]; then 
        cat productos.txt
    else
        grep -i "^$tipo:" productos.txt
    fi
}

# Función para crear reporte de pinturas (todos los productos)
crear_reporte() {
    carpeta_datos="./Datos"
    archivo_reporte="$carpeta_datos/datos.csv"

    # Crear carpeta Datos si no existe
    if [ ! -d "$carpeta_datos" ]; then
        mkdir "$carpeta_datos"
    fi

    # Verificar que existan productos registrados
    if [ ! -s productos.txt ]; then
        echo "No hay productos registrados para generar el reporte."
        return
    fi

    # Crear archivo CSV con encabezados
    echo "Codigo,Tipo,Modelo,Descripcion,Cantidad,Precio" > "$archivo_reporte"

    # Convertir los : a , para formato CSV
    awk -F: '{print $1","$2","$3","$4","$5","$6}' productos.txt >> "$archivo_reporte"

    echo "Reporte generado correctamente en: $archivo_reporte"
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
        3) crear_producto ;;
        4) vender_producto ;;
        5) filtrar_productos_tipo ;;
        6) crear_reporte ;;
    	7) echo "!Hasta luego!"; exit ;;
    	*) echo "Opción no válida. Por favor, seleccione una opción válida." ;;
    	esac
done
