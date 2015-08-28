# install a sandbox m2.dev site
set -e
wd=$(pwd)

# use a bare clone to keep up-to-date local mirror of master
if [[ ! -d "$CACHE_DIR/m2.repo" ]]; then
    echo "Cloning remote repository to local mirror. This could take a while..."
    git clone --bare -q "https://github.com/magento/magento2.git" "$CACHE_DIR/m2.repo"
    cd "$CACHE_DIR/m2.repo"
    git remote add origin "https://github.com/magento/magento2.git"
    git fetch -q
else
    cd "$CACHE_DIR/m2.repo"
    git fetch -q || true
fi

# install or update codebase from local mirror
if [[ ! -d "$SITES_DIR/m2.dev" ]]; then
    echo "Setting up site from scratch. This could take a while..."
    
    mkdir -p "$SITES_DIR/m2.dev"
    git clone -q "$CACHE_DIR/m2.repo" "$SITES_DIR/m2.dev"

    cd "$SITES_DIR/m2.dev"
    composer install -q --prefer-dist
    mkdir -p /server/_var/m2.dev
    ln -s "/server/_var/m2.dev/{session,log,generation,composer_home,view_preprocessed}" "var/"

    >&2 echo "Note: please add a record to your /etc/hosts file for m2.dev and re-run the vhost generator"
else
    cd "$SITES_DIR/m2.dev"
    git pull -q
    rm -rf "var/{session,log,generation,composer_home,view_preprocessed}/*"
    composer install -q --prefer-dist
fi

# either install or upgrade database
code=
mysql -e 'use m2_dev' || code="$?"
if [[ $code ]]; then
    mysql -e 'create database m2_dev'
    
    bin/magento setup:install -q \
        --admin-user=admin \
        --admin-firstname=Admin \
        --admin-lastname=Admin \
        --admin-email=user@example.com \
        --admin-password=A123456 \
        --db-host=dev-db \
        --db-user=root \
        --db-name="m2_dev"
else
    bin/magento setup:upgrade -q
fi

cd "$wd"
