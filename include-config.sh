# Сборка образа $IMAGE
function docker_build() {
    IMAGE=$1
    IMG_NAME="$IMAGE"

    docker build -t $IMG_NAME $IMAGE
    if [[ "$(docker images -q $IMG_NAME 2> /dev/null)" == "" ]]; then
        docker build -t $IMG_NAME $IMAGE
    else
        echo "#####################################################################"
        echo "Docker image reused: $IMG_NAME"
        echo "#####################################################################"
    fi
}



# Запуск команды $CMD в образе $IMAGE
###############################################
## Чтобы права новых файлов не принадлежали пользователю-root, контейнер запускается от текущего пользователя  $(id -u):$(id -g) и  пробрасываются /etc/group /etc/passwd в режиме чтения
## $HOME из Docker монтируется в ~/.iceowl-docker-cache host-системы для того чтобы работали кэши инструментов управления зависимостями вроде sbt, maven и т.д.
###############################################
function docker_run_cmd() {
    IMAGE=$1
    CMD="$2 $3 $4 $5 $6 $7 $8 $9"
    IMG_NAME="$IMAGE"

    docker_build $IMAGE #> /dev/null

    HOME_CACHE="$HOME/.iceowl-docker-cache"
    mkdir -p $HOME_CACHE
    echo "HOME_CACHE: " $HOME_CACHE

    # Уникальное имя для контейнера
    CNTID="tmp_$(date +%Y-%m-%d.%H-%M-%S.%N)"

    docker run \
        --rm \
        -i \
        --name=$CNTID \
        -w /workspace \
        -v $(pwd):/workspace \
        -v /etc/group:/etc/group:ro \
        -v /etc/passwd:/etc/passwd:ro \
        -v $HOME_CACHE:$HOME:rw \
        -u $(id -u):$(id -g) \
        $IMG_NAME $CMD    

    echo "Exit from: " $@        
}

function docker_export() {
    IMAGE=$1
    EXPORT_TO=$2
    IMG_NAME="$IMAGE"

    docker_build $IMAGE #> /dev/null

    sudo mkdir -p $EXPORT_TO
    sudo chmod 777 $EXPORT_TO
    sudo chown $(id -u):$(id -g) $EXPORT_TO

    echo "/opt from IMAGE: " $IMG_NAME
    echo "EXPORT_TO: " $EXPORT_TO

    docker run --rm -ti \
        -v $EXPORT_TO:/target \
        $IMG_NAME cp -v -r /opt/haxelib/lime/. /target/

    sudo chmod -R a+rwx $EXPORT_TO
}