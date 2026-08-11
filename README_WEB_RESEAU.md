# Build web et partage reseau

Ce document explique comment generer le frontend Flutter Web, le relier au
backend Django sur le reseau local, puis le partager a l'equipe.

## 1. Pourquoi le login pouvait echouer

Le build web etait servi sur `http://10.0.34.69:8090`, mais le frontend
appelait encore `http://localhost:8000/api`.

Depuis un autre appareil, `localhost` designe cet appareil lui-meme, pas le PC
qui heberge Django. Le login echouait donc a cause d'une URL d'API incorrecte,
pas forcement a cause du mot de passe.

Le frontend accepte maintenant une surcharge d'URL via :

```bash
--dart-define=API_BASE_URL=http://10.0.34.69:8000/api
```

## 2. Configuration backend reseau local

Fichier : `POS_Backend/.env`

Variables importantes :

```env
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,10.0.34.69
CORS_ALLOWED_ORIGINS=http://localhost:8080,http://127.0.0.1:8080,http://10.0.34.69:8090
```

Ensuite lancer Django sur toutes les interfaces :

```bash
cd POS_Backend
source ../.venv/bin/activate
python manage.py runserver 0.0.0.0:8000
```

## 3. Build Flutter Web pour le reseau

Depuis `POS_Frontend` :

```bash
flutter build web --dart-define=API_BASE_URL=http://10.0.34.69:8000/api
```

Le resultat est genere dans :

```text
POS_Frontend/build/web
```

## 4. Servir le build en local sur le reseau

Option simple pour tests internes :

```bash
cd POS_Frontend/build/web
python3 -m http.server 8090 --bind 0.0.0.0
```

Acces depuis le meme reseau :

```text
http://10.0.34.69:8090
```

## 5. Partager le build a l'equipe

### Option A - acces direct sur ton PC

Si ton PC reste allume et joignable sur le reseau :

- frontend : `http://10.0.34.69:8090`
- backend : `http://10.0.34.69:8000/api`

### Option B - envoyer une archive

```bash
cd POS_Frontend
zip -r web-build.zip build/web
```

Puis envoyer `web-build.zip` a un membre de l'equipe.

Attention : ouvrir `index.html` directement ne suffit pas toujours. Il faut
servir le contenu avec Apache, Nginx ou un petit serveur statique.

## 6. Deploiement avec Apache

Copier le build :

```bash
sudo mkdir -p /var/www/pos-web
sudo cp -r POS_Frontend/build/web/* /var/www/pos-web/
sudo chown -R www-data:www-data /var/www/pos-web
sudo chmod -R 755 /var/www/pos-web
```

Exemple de VirtualHost :

```apache
<VirtualHost *:80>
    ServerName 10.0.34.69
    DocumentRoot /var/www/pos-web

    <Directory /var/www/pos-web>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/pos-web_error.log
    CustomLog ${APACHE_LOG_DIR}/pos-web_access.log combined
</VirtualHost>
```

Fichier `.htaccess` pour Flutter Web :

```apache
RewriteEngine On
RewriteBase /
RewriteRule ^index\.html$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.html [L]
```

Activation :

```bash
sudo a2enmod rewrite
sudo a2ensite pos-web.conf
sudo systemctl reload apache2
```

## 7. Procedure de mise a jour

A chaque nouvelle version :

```bash
cd POS_Frontend
flutter build web --dart-define=API_BASE_URL=http://10.0.34.69:8000/api
```

Si tu utilises Apache :

```bash
sudo rm -rf /var/www/pos-web/*
sudo cp -r build/web/* /var/www/pos-web/
sudo systemctl reload apache2
```

## 8. Checklist si le login ne marche pas

1. Verifier que Django tourne sur `0.0.0.0:8000`
2. Verifier que le frontend a ete build avec le bon `API_BASE_URL`
3. Verifier `DJANGO_ALLOWED_HOSTS`
4. Verifier `CORS_ALLOWED_ORIGINS`
5. Verifier que le port `8000` est joignable depuis les autres machines
6. Si besoin, recompiler puis republier `build/web`
