# Wordpress Docker
Wordpress theme/plugin development and deployment using docker

## Requirements

* Docker

## Development
Uses docker-compose for local development

### Getting Started

Start the server for local development
```bash
bash bin/dev.sh
```

### Project Structure
```
bin
  ├─ dev.sh             # Script to start the development sever
  ├─ entrypoint.sh      # Custom script to append to the original entrypoint.sh of wordpress
  ├─ pre-entrypoint.sh  # DATABASE_URL parsing to wordpress envs
wp-content
  ├─ themes             # (Options - Only if you are making custom theme)
     ├─ custom-theme    # The name of the custom theme 
  ├─ plugins            # (Optional - Only if you are making custom plugin)
     ├─ custom-plugin   # The name of the custom plugin             
docker-compose.dev.yml  # Docker compose for local development
Dockerfile              # Dockerfile used to build the production container
.gitignore              # list of files to ignore
README.md               # you are here
```
For Local theme development create wp-content/themes/your-theme-name inside the project as per the project structure. And un-comment line no 46 in Dockerfile to
```bash
COPY wp-content/themes/* /usr/src/wordpress/wp-content/themes/
```

For Local plugin development create wp-content/plugin/your-plugin-name inside the project as per the project structure. And un-comment line no 48 in Dockerfile to
```bash
COPY wp-content/plugins/* /usr/src/wordpress/wp-content/plugins/
```

## Production Deployment - Dokku wordpress docker deployment on digital ocean

### 1. [Create a droplet](https://cloud.digitalocean.com/droplets/new) on digitalocean
- Choose one click dokku app on ubuntu 16.04 (Choose Stable release)
- Choose a size - $5/mo (Depending on your requirement)
- Choose a datacenter region - Region closest to your target audience
- Select additional options
  - Private Networking - optional
  - Backups - optional
  - IPv6 - optional
  - User Data - optional
- Add your SSH keys
  - [How To Use SSH Keys with DigitalOcean Droplets](https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets)
- Finalize and Create
  - How many droplets? - optional (1 will suffice)
  - Choose a hostname - optional

### 2. Point your domain name to the Public IP address of the digital ocean

### 3. [Setup initial server](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-16-04)

### 4. Setup Dokku
```bash
export APP_NAME=the-app-name
export DOMAIN_NAME=my-domain.com
dokku apps:create $APP_NAME
mkdir -p "$HOME/dokku/data/storage/$APP_NAME-plugins"
sudo chown 32767:32767 "$HOME/dokku/data/storage/$APP_NAME-plugins"
dokku storage:mount $APP_NAME $HOME/dokku/data/storage/$APP_NAME-plugins:/var/www/html/wp-content/plugins
mkdir -p "$HOME/dokku/data/storage/$APP_NAME-uploads"
sudo chown 32767:32767 "$HOME/dokku/data/storage/$APP_NAME-uploads"
dokku storage:mount $APP_NAME $HOME/dokku/data/storage/$APP_NAME-uploads:/var/www/html/wp-content/uploads
sudo dokku plugin:install https://github.com/dokku/dokku-mysql.git
dokku mysql:create $APP_NAME-database
dokku mysql:link $APP_NAME-database $APP_NAME

#Add the git remote locally on your development machine (Don't run these commented statements on the sever)
#git remote add production dokku@ip-address-of-droplet:the-app-name ($APP_NAME)
#git push production master
dokku domains:add $APP_NAME $DOMAIN_NAME
sudo dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git
sudo dokku config:set --no-restart --global DOKKU_LETSENCRYPT_EMAIL=you@example.com
sudo dokku letsencrypt $APP_NAME
sudo dokku letsencrypt:cron-job --add
```


### 5. To keep deploying updates manually
```bash
git push production master
```

### 5. To Deploy using circleci
- Replace hostname with ip/domain-name in .circleci/config.yml
- Replace app-name with deployed dokku app-name in .circle/config.yml
- Sign in to circleci.com and click “Add Projects”
- Find the repo for your app and click “Build project”
- Create a ssh key pair so CircleCI can deploy to Dokku
```bash
ssh dokku
cd ~/.ssh
ssh-keygen -t rsa    # save as circleci.id_rsa
sudo dokku ssh-keys:add circleci ./circleci.id_rsa.pub
cat ~/.ssh/circleci.id_rsa
```
- Copy & paste your private key into CircleCI (Project Settings > SSH Permissions > Add SSH Key)
- Push a commit to your master branch or merge a pull request to see your app deployed to Dokku