# Functions used on PS1
__git_branch ()
{
    git branch 2>/dev/null |\
    grep \*                |\
    sed -Ee's#\* (.*)#[\1]#'
}

__svn_branch ()
{
    svn info 2>/dev/null |\
    egrep ^URL           |\
    sed -Ee's#^.*/((trunk|branches|tags).*)#[\1]#'
}

# Prints a table with all FGs and BGs combinations
# (I don't remember where I got this from, but it's not mine)
colors ()
{
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

# cd into a folder and show its contents
# $ go [ls options] dir
go ()
{
    cd ${!#}            # last arg
    if [[ $? != 0 ]]; then return; fi

    ls ${@:1:$(($#-1))} # all but last

    #... Bash is gross, isn't it? Eek!
}

# creates a new dir and navigates inside
# $ mkcd [mkdir options] dir
mkcd ()
{
    mkdir $@
    if [[ $? != 0 ]]; then return; fi

    cd ${!#}
}

# Merges all pdf files in the current dir and outputs out.pdf
pdf_merge ()
{
    gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile=out.pdf *.pdf
}

# Outputs a grayscale copy of $1
pdf_grayscale ()
{
    gs -sOutputFile="grayscale-$1" \
       -sDEVICE=pdfwrite \
       -sColorConversionStrategy=Gray \
       -dProcessColorModel=/DeviceGray \
       -dCompatibilityLevel=1.4 \
       -dNOPAUSE \
       -dBATCH \
       "$1"
}

# Prints a random word from the dictionary
rword ()
{
    DICT=/usr/share/dict/words
    NWORDS=$(wc -l $DICT | cut -d' ' -f1)
    RAND=$(perl -e "print int rand($NWORDS)")
    awk -v lineno="$RAND" 'lineno==NR{print;exit}' $DICT | tr -d '\n'
}

