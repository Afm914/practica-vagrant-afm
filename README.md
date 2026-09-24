## Proyecto SAD
## 1. Contexto

En este repositorio se encuentra la simulacion de una PYME estandar minima para pruebas de seguridad.

Se contruiran automaticamente 6 maquinas en 3 redes distintas: una red lan para empleados, una de gestion con un IDP y otra de dmz para un proxy y un servidor web.

## 2. Despliegue

1. Paso 1

Descarga del repositorio por termimal
```bash
git clone https://github.com/Afm914/practica-vagrant-afm.git
```
Y entramos en la carpeta
```bash
cd practica-vagrant-afm
```
2. Paso 2

Creamos y encendemos todas las maquinas con el comando:
```
vagrant up
```

Podemos comporbar si estan levantadas con

```
vagrant status
```
Y podemos acceder a ellas con 
```
vagrant ssh "nombre de la maquina"
```
Para apagarlas su usa el comando
```
vagrant halt
```
Y para borrarlas el comando
```
vagrant destroy
```