__marker_path () {
    local marker="$1"
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/$marker" ]]; then
            printf "%s/%s" "$dir" "$marker"
            return
        fi
        dir="$(dirname "$dir")"
    done
}

__bg_jobs () {
    local job_count
    job_count="$(jobs | wc -l)"
    if [[ "$job_count" -gt 0 ]]; then
        printf " [%s]" "$job_count"
    fi
}

__javaversion () {
    if command -v java >/dev/null 2>&1 && [ -n "$(__marker_path pom.xml)" ]; then
        local version
        version="$(java -version 2>&1)"
        case "$version" in
            *Zulu21*)     local JAVA_VERSION="z21" ;;
            *Zulu17*)     local JAVA_VERSION="z17" ;;
            *Zulu11*)     local JAVA_VERSION="z11" ;;
            *Temurin-23*) local JAVA_VERSION="t23" ;;
            *Temurin-25*) local JAVA_VERSION="t25" ;;
            *build\ 21*)  local JAVA_VERSION="j21" ;;
            *build\ 17*)  local JAVA_VERSION="j17" ;;
            *build\ 11*)  local JAVA_VERSION="j11" ;;
            *build\ 1.8*) local JAVA_VERSION="j8"  ;;
            *)            local JAVA_VERSION="??"  ;;
        esac

        # https://www.nerdfonts.com/cheat-sheet
        # nf-fae-coffe_beans e26a
        # nf-cod-coffee ec15
        printf " \\uec15 %s" "$JAVA_VERSION"
    fi
}

__mvn_proj () {
    local xpath="/*[name()='project']/*[name()='artifactId']/text()"
    local pom
    pom="$(__marker_path pom.xml)"
    if [[ -f "$pom" ]]; then
        local name
        name="$(xmllint --xpath "$xpath" "$pom")"

        # https://www.nerdfonts.com/cheat-sheet
        # nf-fa-feather_pointed ee34
        printf " \\uee34 %s" "$name"
    fi
}

__pyvenv () {
    if [ -n "$VIRTUAL_ENV" ]; then
        local ENV_NAME
        ENV_NAME="$(basename "$(dirname "$VIRTUAL_ENV")")"

        # https://www.nerdfonts.com/cheat-sheet
        # nf-dev-python e73c
        printf " \\ue73c %s" "$ENV_NAME"
    fi
}

__nodejsversion () {
    if command -v node >/dev/null 2>&1 && [ -n "$(__marker_path package.json)" ]; then
        local VERSION
        VERSION="$(node --version)"

        # Truncate zero minors (1.20.00.0 => 1.20)
        VERSION="${VERSION%%+(\.+(0))}"

        # https://www.nerdfonts.com/cheat-sheet
        # nf-dev-javascript (naked JS) e74e
        # nf-fa-square_js (JS in a box) f2ef
        printf " \\ue74e %s" "$VERSION"
    fi
}

mvn_new_proj () {
    local group_id="$1"
    local artifact_id="$2"
    local package=""
    local interactive="true"
    if [[ -n "$group_id" && -n "$artifact_id" ]]; then
        package="$group_id.$artifact_id"
        interactive="false"
    fi

    mvn archetype:generate \
      -DarchetypeGroupId=org.apache.maven.archetypes \
      -DarchetypeArtifactId=maven-archetype-quickstart \
      -DarchetypeVersion=1.5 \
      -DjavaCompilerVersion=21 \
      -Dversion=1.0-SNAPSHOT \
      -DgroupId="$group_id" \
      -DartifactId="$artifact_id" \
      -Dpackage="$package" \
      -DinteractiveMode="$interactive"
}

uuid () {
    uuidgen | tr -d '\n' | tee >(xclip -sel clip)
    echo
}

randStr () {
    local size="${1:-8}"
    local chars="${2:-0123456789}"

    for _ in $(seq 1 "$size"); do
        echo -n "${chars:RANDOM%${#chars}:1}"
    done
    echo
}

colors () {
    local T='gYw'

    echo -e "\n                 40m     41m     42m     43m\
     44m     45m     46m     47m"

    for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
               '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
               '  36m' '1;36m' '  37m' '1;37m'
    do
        FG=${FGs// /}
        echo -en " $FGs \033[$FG  $T  "

        for BG in 40m 41m 42m 43m 44m 45m 46m 47m
        do
            echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m"
        done
        echo

    done
    echo
}

colors_256 () {
    # 0-7: Standard colors
    # 8-15: High-intensity colors
    # 16-231: 6x6x6 color cube
    # 232-255: Grayscale ramp

    echo "FG: \\e[1m \\e[38;5;\${c}m \\e[0m"
    echo "BG: \\e[1m \\e[48;5;\${c}m \\e[0m"

    for c in {0..255} ; do
        (( c % 16 )) || echo -e "\e[0m"
        printf "\e[1m\e[48;5;${c}m %03d " "$c"
    done

    echo -e "\e[0m"
}

update_java_home () {
    local CURR_JAVAC_BIN
    CURR_JAVAC_BIN="$(update-alternatives --get-selections | awk '/^javac/{ print $3 }')"
    export JAVA_HOME="${CURR_JAVAC_BIN%/bin/javac}"
    echo "JAVA_HOME is now \"$JAVA_HOME\""
}

set_java () {
    local JAVA_NAME
    case "$1" in
    z21) JAVA_NAME="zulu21-ca-amd64" ;;
    z17) JAVA_NAME="zulu17-ca-amd64" ;;
    z11) JAVA_NAME="zulu11-ca-amd64" ;;
    j21) JAVA_NAME="java-1.21.0-openjdk-amd64" ;;
    j17) JAVA_NAME="java-1.17.0-openjdk-amd64" ;;
    j11) JAVA_NAME="java-1.11.0-openjdk-amd64" ;;
    j8)  JAVA_NAME="java-1.8.0-openjdk-amd64" ;;
    *)  echo "Version not recognized! Using default OpenJDK 21"
        JAVA_NAME="java-1.21.0-openjdk-amd64" ;;
    esac

    sudo update-java-alternatives --set "$JAVA_NAME"
    echo "Java is now \"$JAVA_NAME\""

    update_java_home
}

traverse_git_hist() {
    git log --pretty=format:"%H" \
        | cat - <(echo) \
        | tac \
        | while read -r line; do
              git show "$line"
          done
}

to_gif () {
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 input-video output-gif"
        exit 1
    fi

    ffmpeg -i "$1" \
        -vf " [0:v]fps=12,scale=480:-1,split[s0][s1];
              [s0]palettegen=stats_mode=diff[p];
              [s1][p]paletteuse=new=1" \
        -loop 0 "$2"
}
