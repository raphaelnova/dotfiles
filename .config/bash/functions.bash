# Given a list of files, traverses the filesystem upwards
# searching for the first it can find. Useful to identify
# whether the cwd is inside a project folder (by finding
# e.g. a pom.xml or a package.json). Prints the full file
# path.
__marker_path() {
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

__job_count() {
  # Count only stopped and running jobs
  jobs | grep -cE 'Running|Stopped'
}

# Prints a count of suspended jobs. Used in PS1 so I don't
# lose track of a suspended nvim and `exec bash` losing it
# in the void.
__bg_jobs() {
  local job_count

  job_count="$(__job_count)"
  if [[ "${job_count}" -gt 0 ]]; then
    printf " [%s]" "${job_count}"
  fi
}

# Prompts at exit if there are any background jobs
# (because I keep creating orphan processes despite
# putting a count in my PS1)
exit() {
  local job_count
  local reply

  job_count="$(__job_count)"
  if (( job_count > 0 )); then
    # shellcheck disable=SC2162
    read -n1 -p "You have ${job_count} background job(s). Exit anyway? [y/N]: " reply
    [[ "${reply}" == "y" || "${reply}" == "Y" ]] || return
  fi

  builtin exit
}

# Prints a short identifier to indicate the current Java
# version active. Used in PS1.
__javaversion() {
  if command -v java >/dev/null 2>&1 && [ -n "$(__marker_path pom.xml)" ]; then
    local curr_version
    local output_version="??"

    curr_version="$(java -version 2>&1)"

    case "${curr_version}" in
    # Eclipse Temurin
    *Temurin-*)
      [[ "${curr_version}" =~ Temurin-([0-9]+) ]] &&
        output_version="${BASH_REMATCH[1]}-tem"
      ;;
    # Azul JDK
    *Zulu*)
      [[ "${curr_version}" =~ Zulu([0-9]+) ]] &&
        output_version="${BASH_REMATCH[1]}-zulu"
      ;;
    # Ubuntu OpenJDK
    *Ubuntu*)
      [[ "${curr_version}" =~ \(build\ ([0-9]+) ]] &&
        output_version="${BASH_REMATCH[1]}-ubuntu"
      ;;
    esac

    # https://www.nerdfonts.com/cheat-sheet
    # nf-fae-coffe_beans e26a
    # nf-cod-coffee ec15
    printf " \\ue26a %s" "${output_version}"
  fi
}

# Are we inside a Maven project folder? Prints the artifactId.
# Used in PS1.
__mvn_proj() {
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
__pyvenv() {
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
__nodejsversion() {
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
mvn_new_proj() {
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
uuid() {
  uuidgen | tee >(tr -d '\n' | xclip -sel clip)
}

# Given optional size and charset, generates a random string.
# Prints a string of 8 digits by default.
randStr() {
  local size="${1:-8}"
  local chars="${2:-0123456789}"

  for _ in $(seq 1 "$size"); do
    echo -n "${chars:RANDOM%${#chars}:1}"
  done
  echo
}

# Not my code. Prints the ANSI color pallete.
colors() {
  local T='gYw'

  echo -e "\n                 40m     41m     42m     43m\
     44m     45m     46m     47m"

  for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
    '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
    '  36m' '1;36m' '  37m' '1;37m'; do
    FG=${FGs// /}
    echo -en " $FGs \033[$FG  $T  "

    for BG in 40m 41m 42m 43m 44m 45m 46m 47m; do
      echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m"
    done
    echo

  done
  echo
}

colors_256() {
  256colors2.pl
}

colors_24bit() {
  truecolor-test.sh
}

# Gets the current java-alternative and sets its path to JAVA_HOME.
# Not necessary anymore now that I'm using SDKMAN, but I don't feel
# like throwing it away yet.
update_java_home() {
  local CURR_JAVAC_BIN
  CURR_JAVAC_BIN="$(update-alternatives --get-selections | awk '/^javac/{ print $3 }')"
  export JAVA_HOME="${CURR_JAVAC_BIN%/bin/javac}"
  echo "JAVA_HOME is now \"$JAVA_HOME\""
}

# Given a short identifier, sets a Java version from a set of
# java-alternatives. Not in use it anymore since I'm using
# SDKMAN.
set_java() {
  local JAVA_NAME
  case "$1" in
  z21) JAVA_NAME="zulu21-ca-amd64" ;;
  z17) JAVA_NAME="zulu17-ca-amd64" ;;
  z11) JAVA_NAME="zulu11-ca-amd64" ;;
  j21) JAVA_NAME="java-1.21.0-openjdk-amd64" ;;
  j17) JAVA_NAME="java-1.17.0-openjdk-amd64" ;;
  j11) JAVA_NAME="java-1.11.0-openjdk-amd64" ;;
  j8) JAVA_NAME="java-1.8.0-openjdk-amd64" ;;
  *)
    echo "Version not recognized! Using default OpenJDK 21"
    JAVA_NAME="java-1.21.0-openjdk-amd64"
    ;;
  esac

  sudo update-java-alternatives --set "$JAVA_NAME"
  echo "Java is now \"$JAVA_NAME\""

  update_java_home
}

# Calculates how many lines a string will take on screen, taking
# into consideration the line wraps over the number of columns.
calc_lines() {
  local output="$1"
  local term_width
  term_width="$(tput cols 2>/dev/null || echo 80)"

  fold --width "$term_width" <(echo "$output") | wc -l
}

# Gets git commit hashes from the history and shows each commit
# in chronological order. Accepts `git log` ranges to limit the
# number of commits to show and displays a number of commits of
# context.
traverse_git_hist() {
  local header_style="\e[1;31m"
  local counter_style="\e[34m"
  local reset="\e[0m"

  local commits
  readarray -t commits < <(git log --reverse --oneline --color=always "$@")
  local total_commits="${#commits[@]}"
  local digits="${#total_commits}"

  # How many commits to show before and after the current commit
  local context=2

  local header="${header_style}== COMMITS (OLDEST TO NEWEST): ==${reset}"
  local start_prompt="Press Q to quit, or Enter to iterate over all these commits. "
  local counter_fmt="${counter_style}%${digits}d/%d${reset}"

  local total_lines
  total_lines="$(
    calc_lines "$(
      echo "${header}"
      printf "%s\n" "${commits[@]}"
      echo -e "\n$start_prompt"
    )"
  )"

  # Pages with color if in terminal and output exceeds term height
  if [[ -t 1 && $total_lines -gt $(tput lines) ]]; then
    local pager="less -R"
  else
    local pager="cat"
  fi

  clear

  {
    # Prints the full list of commits to iterate over
    #
    # 01/12 > a1b2c3d4 Commit msg
    # 02/12   a1b2c3d4 Commit msg
    # 03/12   a1b2c3d4 Commit msg
    # ...
    #
    echo -e "$header"
    for ((i = 0; i < total_commits; i++)); do
      # shellcheck disable=SC2059
      printf "$counter_fmt" "$((i + 1))" "$total_commits"
      if [[ $i == 0 ]]; then
        printf " > "
      else
        printf "   "
      fi
      printf "%s\n" "${commits[i]}"
    done
    echo
  } | $pager

  read -p "$start_prompt" -rsn 1 choice
  [[ "$choice" =~ ^[qQ]$ ]] && return

  local first=true
  for ((i = 0; i < total_commits; i++)); do
    # We already showed a list and a prompt for the first commit, this is for
    # the second onwards. Show commit surrounded by a context and prompts for
    # continuing.
    if ! $first; then

      # Adjust context window start and end indexes
      if ((i < context)); then
        # Commit is before the middle of the window
        start=0
        end=$((4 < total_commits ? 4 : total_commits - 1))
      elif ((i > total_commits - context - 1)); then
        # Commit after the middle of the window
        local window_size=$((context * 2 + 1))
        start=$((total_commits - window_size < 0 ? 0 : total_commits - window_size))
        end=$((total_commits - 1))
      else
        # Commit at the middle
        start=$((i - context))
        end=$((i + context))
      fi

      # Printing the context window
      ((start > 0)) && echo "..." || echo
      for ((j = start; j <= end; j++)); do
        # 02/12   abcd1234 Commit msg
        # 03/12 > abcd1234 Commit msg
        # 04/12   abcd1234 Commit msg

        # shellcheck disable=SC2059
        printf "$counter_fmt" "$((j + 1))" "$total_commits"

        if ((j == i)); then
          printf " > %s\n" "${commits[j]}"
        else
          printf "   %s\n" "${commits[j]}"
        fi
      done
      ((end < total_commits - 1)) && echo "..." || echo

      echo
      read -p "Press Q to quit, S to skip or Enter to continue." -rsn 1 choice
      [[ "$choice" =~ ^[qQ]$ ]] && return
      [[ "$choice" =~ ^[sS]$ ]] && clear && continue
    fi

    clear
    local commit_hash
    commit_hash="$(echo -n "${commits[i]}" | sed 's/\x1B\[[0-9;]*m//g' | cut -d' ' -f1)"
    # Print colors with -R, force pager with -+F
    GIT_PAGER="less -R -+F" git show "$commit_hash"

    first=false
    clear
  done
}

# Given a video file, outputs a 480w gif from it.
to_gif() {
  local video="$1"
  local gif="${2:-${video%.*}.gif}"

  ffmpeg -hide_banner -loglevel error \
    -i "${video}" \
    -vf " [0:v]fps=12,scale=480:-1,split[s0][s1];
              [s0]palettegen=stats_mode=diff[p];
              [s1][p]paletteuse=new=1" \
    -loop 0 "${gif}"
}

# Gets a video and an SRT file, fixes the text encoding and EOL
# and outputs a new video with the subtitles in it.
subtitle() {
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
    -map 1 \
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
trace_script() {
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
delta_trace() {
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
