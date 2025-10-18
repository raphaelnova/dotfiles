# Given a list of files, traverses the filesystem upwards
# searching for the first it can find. Useful to identify
# whether the cwd is inside a project folder (by finding
# e.g. a pom.xml or a package.json). Prints the full file
# path.
__marker_path () {
    local dir="$PWD"
    local markers=("$@")
    local marker
    while [[ "$dir" != "/" ]]; do
        for marker in "${markers[@]}"; do
            if [[ -f "$dir/$marker" ]]; then
                printf "%s/%s" "$dir" "$marker"
                return
            fi
        done
        dir="$(dirname "$dir")"
    done
}

# Prints a count of suspended jobs. Used in PS1 so I don't
# lose track of a suspended nvim and `exec bash` losing it
# in the void.
__bg_jobs () {
    local job_count
    # Count only suspended processes (not ending in &)
    job_count="$(jobs | grep -cvE '&$')"
    if [[ "$job_count" -gt 0 ]]; then
        printf " [%s]" "$job_count"
    fi
}

# Prints a short identifier to indicate the current Java
# version active. Used in PS1.
__javaversion () {
    if command -v java >/dev/null 2>&1 && [ -n "$(__marker_path pom.xml)" ]; then
        local version
        version="$(java -version 2>&1)"
        case "$version" in
            # Azul JDK
            *Zulu21*)     local JAVA_VERSION="z21" ;;
            *Zulu17*)     local JAVA_VERSION="z17" ;;
            *Zulu11*)     local JAVA_VERSION="z11" ;;

            # Eclipse Temurin
            *Temurin-23*) local JAVA_VERSION="t23" ;;
            *Temurin-25*) local JAVA_VERSION="t25" ;;

            # OpenJDK
            *build\ 21*)  local JAVA_VERSION="j21" ;;
            *build\ 17*)  local JAVA_VERSION="j17" ;;
            *build\ 11*)  local JAVA_VERSION="j11" ;;
            *build\ 1.8*) local JAVA_VERSION="j8"  ;;

            # What?
            *)            local JAVA_VERSION="??"  ;;
        esac

        # https://www.nerdfonts.com/cheat-sheet
        # nf-fae-coffe_beans e26a
        # nf-cod-coffee ec15
        printf " \\uec15 %s" "$JAVA_VERSION"
    fi
}

# Are we inside a Maven project folder? Prints the artifactId.
# Used in PS1.
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

# Are we inside a python venv? Prints the root folder name.
# Used in PS1.
__pyvenv () {
    if [ -n "$VIRTUAL_ENV" ]; then
        local ENV_NAME
        ENV_NAME="$(basename "$(dirname "$VIRTUAL_ENV")")"

        # https://www.nerdfonts.com/cheat-sheet
        # nf-dev-python e73c
        printf " \\ue73c %s" "$ENV_NAME"
    fi
}

# Are we inside a node project folder? Print the node version.
# Used in PS1
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

# Archetipe to generate a new Maven project. Because
# Maven archetype:generate commands are too verbose.
mvn_new_proj () {
    # TODO: maybe parse short options here?
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

# A fresh UUID sent to stdout and to xclip
uuid () {
    uuidgen | tee >(tr -d '\n' | xclip -sel clip)
}

# Given optional size and charset, generates a random string.
# Prints a string of 8 digits by default.
randStr () {
    local size="${1:-8}"
    local chars="${2:-0123456789}"

    for _ in $(seq 1 "$size"); do
        echo -n "${chars:RANDOM%${#chars}:1}"
    done
    echo
}

# Not my code. Prints the ANSI color pallete.
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

# Not mine either. Prints a 256 color pallete
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

# Gets the current java-alternative and sets its path to JAVA_HOME.
# Not necessary anymore now that I'm using SDKMAN, but I don't feel
# like throwing it away yet.
update_java_home () {
    local CURR_JAVAC_BIN
    CURR_JAVAC_BIN="$(update-alternatives --get-selections | awk '/^javac/{ print $3 }')"
    export JAVA_HOME="${CURR_JAVAC_BIN%/bin/javac}"
    echo "JAVA_HOME is now \"$JAVA_HOME\""
}

# Given a short identifier, sets a Java version from a set of
# java-alternatives. Not in use it anymore since I'm using
# SDKMAN.
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
    *)   echo "Version not recognized! Using default OpenJDK 21"
         JAVA_NAME="java-1.21.0-openjdk-amd64" ;;
    esac

    sudo update-java-alternatives --set "$JAVA_NAME"
    echo "Java is now \"$JAVA_NAME\""

    update_java_home
}

# Gets git commit hashes from the history and shows each
# commit in chronological order. Make sure not to use it
# in large projects because this is not limiting how many
# commits to show.
traverse_git_hist() {
    git log --pretty=format:"%H" \
        | cat - <(echo) \
        | tac \
        | while read -r line; do
              git show "$line"
          done
}

# Given a video file, outputs a 480w gif from it.
to_gif () {
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 input-video output-gif"
        exit 1
    fi
    local video="$1"
    local gif="$2"

    ffmpeg -hide_banner -log_level error \
        -i "$video" \
        -vf " [0:v]fps=12,scale=480:-1,split[s0][s1];
              [s0]palettegen=stats_mode=diff[p];
              [s1][p]paletteuse=new=1" \
        -loop 0 "$gif"
}

# Gets a video and an SRT file, fixes the text encoding and EOL
# and outputs a new video with the subtitles in it.
subtitle () {
    local movie="$1"
    local subs="$2"
    local dest="${3:-output.mkv}"

    local mime
    local encoding

    encoding="$(file --brief --mime-encoding "$subs")"
    if [[ ! "$encoding" == "utf-8" ]]; then
        local temp_subs
        temp_subs="$(mktemp /tmp/subs_XXXXX.srt)"
        iconv -f "$encoding" -t "utf-8" <"$subs" >"$temp_subs"
        cp "$temp_subs" "$subs"
        rm "$temp_subs"
        echo "Converted from $encoding to utf-8."
    fi

    mime="$(file --brief "$subs")"
    if [[ "$mime" =~ "CRLF line terminators" ]]; then
        dos2unix --quiet "$subs"
        echo "Converted from DOS EOL to Unix EOL."
    fi

    echo "Processing..."
    ffmpeg -hide_banner -loglevel error \
       -i "$movie" -i "$subs" \
       -map 0:v \
       -map 0:a \
       -map 1   \
       -map_metadata -1 \
       -map_chapters -1 \
       -codec copy \
       -metadata:s:a:0 language=eng \
       -metadata:s:s:0 language=por \
       -disposition:s:0 +default+forced \
       "$dest" -y
}

# Executes a script with trace on (-x) and prepends each line
# with a timestamp of seconds and nanos. Useful for profiling
# a script to see where it takes time.
trace_script () {
    # shellcheck disable=SC2016
    # SC2016: Single quotes don't expand expr (that's the goal)
    local time_fmt='+ $(date "+%s.%N")'$'\t'
    local script="$1"

    eval "printf '%s<start>\n' \"$time_fmt\""
    PS4="$time_fmt" bash -x "$script" 2>&1
}

# Gets the output of `trace_script` and outputs each line with
# the time elapsed since the previous line (i.e. the time spent
# running that given line). Filter it with `sort -nr` to order
# them by slowest first.
delta_trace () {
    local src # empty string = awk reads from stdin
    [[ $# -gt 0 ]] && src="$1"

    awk '
        NR == 1 {
            $1="";
            printf "0.000000  %s\n", $0;
            last = $2;
        }
        NR > 1 && /^\+/ {
            diff = $2 - last;
            $1="";
            printf "%.6f  %s\n", diff, $0;
            last = $2
        }
    ' "$src"
}
