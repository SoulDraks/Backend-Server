# Backend Server — Inventario Sala Server

Backend Node.js + Express + MySQL/MariaDB para el inventario de sala server.

## 1. Configuracion

Renombra `.env.example` como `.env` y configura las credenciales de tu Laragon/MySQL:

```env
PORT=3000
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASS=
DB_NAME=serverdesk
```

## 2. Ejecutar

```bash
npm install
npm run server
```

Al iniciar, el backend ejecuta `sql/serverdesk.sql`. La base, tablas, vista y datos iniciales se crean solas.

## 3. Endpoints

- `GET /api/estado` — devuelve modelos, equipos y ultimos 500 movimientos.
- `GET /api/modelos` — modelos de maquinas.
- `GET /api/equipos` — inventario completo.
- `GET /api/pendientes` — equipos actualmente prestados.
- `POST /api/equipos` — crea o actualiza uno o varios equipos.
- `POST /api/movimientos` — registra uno o varios movimientos.
- `POST /api/borrar` — elimina un equipo o movimiento.
