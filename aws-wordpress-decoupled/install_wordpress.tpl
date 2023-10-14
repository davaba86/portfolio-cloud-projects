#!/bin/bash

### Update and upgrade the Ubuntu system
sudo apt update && sudo apt upgrade -y

### Install NGINX 
sudo apt install -y nginx=1.18.0-0ubuntu1.4
sudo systemctl enable nginx --now

### Install PHP
sudo apt install -y php7.4 php7.4-cli php7.4-curl php7.4-fpm php7.4-gd php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-xml

### NGINX - default
sudo tee /etc/nginx/sites-available/default <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;

    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location /health {
        return 200 OK;
    }
}
EOF
sudo systemctl reload nginx

### Install WP
curl https://wordpress.org/wordpress-6.3.1.tar.gz -o /tmp/wordpress-6.3.1.tar.gz
sudo tar -xvzf /tmp/wordpress-6.3.1.tar.gz -C /var/www/
sudo mv /var/www/wordpress /var/www/${wp_domain}
sudo chown -R root:root /var/www/${wp_domain}
cd /var/www/${wp_domain}

### Configure WP
sudo cp wp-config-sample.php wp-config.php
sudo tee /var/www/${wp_domain}/wp-config.php <<EOF
<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/documentation/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', '${db_name}' );

/** Database username */
define( 'DB_USER', '${db_user}' );

/** Database password */
define( 'DB_PASSWORD', '${db_password}' );

/** Database hostname */
define( 'DB_HOST', '${db_host}' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
\$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/documentation/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https')
    \$_SERVER['HTTPS'] = 'on';

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
EOF

### NGINX - WP
sudo tee /etc/nginx/sites-available/${wp_domain} <<EOF
server {
    listen 80;

    server_name ${wp_domain} www.${wp_domain};
    root /var/www/${wp_domain};

    index index.php index.html;

    access_log /var/log/nginx/${wp_domain}.access.log;
    error_log /var/log/nginx/${wp_domain}.error.log;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
    }
    
    location ~ /\.ht {
        deny all;
    }

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)\$ {
        expires max;
        log_not_found off;
    }

    location /health {
        return 200 OK;
    }
}
EOF

sudo unlink /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/${wp_domain} /etc/nginx/sites-enabled/${wp_domain}
sudo systemctl reload nginx
