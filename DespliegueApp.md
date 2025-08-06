# Challenge Mini Hackathon - Allison Blanco y Kendall Reyes

## ``Provedor PaaS Railway``

**Railway** es una plataforma *PaaS* (Platform as a Service) que permite desplegar, alojar y administrar aplicaciones web y bases de datos fácilmente. Su principal enfoque es ofrecer una experiencia de desarrollo simple y rápida, integrando herramientas como GitHub, entornos de desarrollo en la nube, bases de datos (como PostgreSQL, MySQL y Redis), y despliegue automático.

## ``¿Cómo desplegar la aplicación Laravel?``

1. Creado el proyecto Laravel y el repositorio de este mismo, accedemos a nuestro proveedor railway con: https://railway.com/. 

2. Una vez allí, debemos de hacer inicio de sesión con la cuenta registrada en **GitHub**, para poder acceder a nuestro repositorio creado con anterioridad. 

    ``a.`` Iniciado sesión, damos click en **New** -> **Deploy from GitHub repo**. 

    ``b.`` Selecciona el repositorio del proyecto. 

3. Creado el servicio del proyecto, debemos de crear la base de datos, en este caso se puede utilizar **``MySQL``** o **``Postgres``**. 
   
    ``a.`` Le damos en el botón **Create** -> **Database** -> **Add MySQL**. 

4. Creada la base de datos, debemos de configurar las variables del proyecto, con el fin de conectar nuestra app con la base de datos. 
   
    ``a.`` Accedemos al servicio de nuestro proyecto, en este caso con el nombre **Hackathon**.

    ``b.`` Vamos al apartado de **Variables**. 
    
    ``c.`` Le damos en **{} Raw Editor** y pegamos las variables siguientes:

        APP_NAME="Laravel"
        APP_ENV="local"
        APP_KEY="base64:WcCCM6kfwp2/HjDiW8t4Ynf72ugoLyBQMrS+/2d0y0w="
        APP_DEBUG="true"
        APP_URL="http://hackathon-production-60d5.up.railway.app"

        APP_LOCALE="en"
        APP_FALLBACK_LOCALE="en"
        APP_FAKER_LOCALE="en_US"
        APP_MAINTENANCE_DRIVER="file"

        PHP_CLI_SERVER_WORKERS="4"

        BCRYPT_ROUNDS="12"

        LOG_CHANNEL="stack"
        LOG_STACK="single"
        LOG_LEVEL="debug"
        LOG_DEPRECATIONS_CHANNEL="null"

        DATABASE_URL="${{MySQL.MYSQL_URL}}"
        DB_CONNECTION="mysql"
        DB_HOST="mysql.railway.internal"
        DB_PORT="3306"
        DB_DATABASE="railway"
        DB_USERNAME="root"
        DB_PASSWORD="yHkktPKwuIrHpEsNtubmUAXnbhzTLmUQ"

        SESSION_DRIVER="file"
        SESSION_LIFETIME="120"
        SESSION_ENCRYPT="false"
        SESSION_PATH="/"
        SESSION_DOMAIN="null"

        QUEUE_CONNECTION="database"

        CACHE_STORE="database"

        BROADCAST_CONNECTION="log"

        FILESYSTEM_DISK="local"

        MAIL_MAILER="log"
        MAIL_SCHEME="null"
        MAIL_HOST="127.0.0.1"
        MAIL_PORT="2525"
        MAIL_USERNAME="null"
        MAIL_PASSWORD="null"
        MAIL_FROM_ADDRESS="hello@example.com"
        MAIL_FROM_NAME="${APP_NAME}"

        REDIS_CLIENT="phpredis"
        REDIS_HOST="127.0.0.1"
        REDIS_PASSWORD="null"
        REDIS_PORT="6379"

        MEMCACHED_HOST="127.0.0.1"

        AWS_ACCESS_KEY_ID=""
        AWS_SECRET_ACCESS_KEY=""
        AWS_DEFAULT_REGION="us-east-1"
        AWS_BUCKET=""
        AWS_USE_PATH_STYLE_ENDPOINT="false"
        
        VITE_APP_NAME="${APP_NAME}"

5. Seguidamente, nos ubicamos en el apartado **Settings** y allí debemos de verificar lo siguiente:

    ``a.`` Que la **Branch conectada** esté en ``main``. 

    ``b.`` Tener una **Public Networking** como la siguiente: *``hackathon-production-60d5.up.railway.app``*, con el puerto: *``8080``*. 

    ``c.`` Un **TCP Proxy** con el puerto *``9000``*, debido a que es el de **php artisan serve**.

    ``d.`` En el apartado **Deploy** -> **Custom Start Command**, agregamos:
```bash
php artisan serve --host=0.0.0.0 --port=8080
```

6. Y por último, se puede realizar la migración de la base de datos y deployar la app. 

```bash
$ php artisan config:clear
php artisan migrate --force
```

## ``Cosas a tomar en cuenta``

1. En el archivo **.env**, en la variable específica ``DATABASE_URL``, debemos de poner las configuraciones de railway públicas, porque localmente no se podría acceder a las privadas a la hora de ejecutar las migraciones. 

2. También, verificar en el archivo **``config/database.php``** que la configuración de la URL de cada base de datos, aparezca como la hayamos definido en el .env, en este caso está definida como ``DATABASE_URL``. Quiere decir lo siguiente:

```php
#Si aparece:

'url' => env('DB_URL')

# La debemos de cambiar por:

'url' => env('DATABASE_URL')
```

3. En nuestro archivo **.env** local, en las variables relacionadas a las bases de datos, solo necesasitamos las siguientes:

```php
DB_CONNECTION="mysql"
DATABASE_URL="mysql://root:yHkktPKwuIrHpEsNtubmUAXnbhzTLmUQ@hopper.proxy.rlwy.net:10084/railway"
```

Esto debido a que así definimos que estamos usando **mysql** y en la segunda variable estamos usando las configuraciones de la base de datos desde railway, por lo tanto se acceden a través de ``mysql://root:yHkktPKwuIrHpEsNtubmUAXnbhzTLmUQ@hopper.proxy.rlwy.net:10084/railway``, las cuales son las configuraciones públicas. **``Para obtener estas, hacemos lo siguiente:``**

``a.`` Accedemos a nuestro servicio de la base de datos en nuestro proveedor PaaS.

``b.`` Vamos al apartado **Data**. Allí aparecerá un una opción que dice: **Connect to MySQL** junto con el botón **Connect**. 

``c.`` Dado una vez en el botón Connect, aparecen dos apartados: **Private Network** y **Public Network**. Nos ubicamos en el segundo.

``d.`` Allí se muestran varias opciones, pero en nuestro caso necesitamos **Connection URL** ya que esa es la que tenemos en nuestras variables de entorno, específicamente en la de ``DATABASE_URL``. 

4. En nuestra variable de entorno *``SESSION_DRIVER``*, laravel busca una tabla llamada **sessions** debido a que estaba en **database**, por lo tanto, lo cambiamos a:

```php
SESSION_DRIVER=file
```

5. A la hora de deployarlo mostraba un error (**Class "App\Providers\URL" not found`**), que faltaba importar la clase **URL** en nuestros proveedores de servicios. Para ello nos ubicamos en ``app/Providers/AppServiceProvider.php`` y agregamos lo siguiente: 

```php
use Illuminate\Support\Facades\URL;
```