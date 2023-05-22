# file: fzf-tools.xtx

# Define the accept-line widget function
function fzf_command_widget() {
    local full_command=$BUFFER

    case "$full_command" in
        ls*)
            BUFFER="$full_command | fzf -m --cycle +s \
                --preview='echo {}' \
                --preview-window right:50% \
                --layout='reverse-list'  \
                --color bg:#222222,preview-bg:#333333"
        ;;
        man*)
            BUFFER="fzf_man $full_command"
        ;;
        printenv* | env*)
            BUFFER="$full_command | fzf -m --cycle +s \
                --preview='echo {}' \
                --preview-window down:10% \
                --layout='reverse-list'  \
                --color bg:#222222,preview-bg:#333333"
        ;;
        set)
            BUFFER="$full_command | fzf -m --cycle +s \
                --preview='echo {}' \
                --preview-window down:10% \
                --layout='reverse-list'  \
                --color bg:#222222,preview-bg:#333333"
        ;;
        grep*)
            BUFFER="$full_command | fzf -i -m --cycle +s \
                --preview='echo {}' \
                --preview-window down:10% \
                --layout='reverse-list'  \
                --color bg:#222222,preview-bg:#333333"
        ;;
        find*)
            BUFFER="$full_command | fzf -i -m --cycle +s \
                --preview='echo {}' \
                --preview-window down:10% \
                --layout='reverse-list'  \
                --color bg:#222222,preview-bg:#333333"
        ;;
        'ps aux')
            BUFFER="$full_command | fzf -m --cycle +s \
                --preview='echo {}' \
                --preview-window down:10% \
                --layout='reverse-list'  \
                --color bg:#222222,preview-bg:#333333"
        ;;
    esac
    zle accept-line
    # Uncomment if the long command left over on the previous prompt bothers you.
    # $(clear)
}

# Bind the accept-line widget function to the Enter key
zle -N fzf_command_widget
bindkey '^M' fzf_command_widget

function fzf_man() {
    # $1 = the command (man). 
    # $selected_command = the selected man page from the list of man pages.
    local selected_command
    selected_command=$(
        man -k . \
        | awk '{print $1}' \
        | sort \
        | uniq \
        | fzf -m --cycle \
            --preview='echo {}' \
            --preview-window down:10%
    )

    if [[ -n "$selected_command" ]]; then
        man "$selected_command" \
        | fzf -m --cycle --tac +s \
            --preview='echo {}' \
            --preview-window down:10% \
            --layout='reverse-list'  \
            --color bg:#222222,preview-bg:#333333
    fi
}

# Allows executing any command from history
function fzf_run_cmd_from_history() {
    local selected_command
    selected_command=$(
        history \
        | awk '{$1=""; print $0}' \
        | awk '!x[$0]++' \
        | fzf --cycle --tac +s --no-sort \
            --preview 'echo {}' \
            --preview-window down:10% \
            --color bg:#222222,preview-bg:#333333 \
    )

    if [[ -n "$selected_command" ]]; then
        eval "$selected_command"
    fi
}

#/////////////////////////////////////////////
alias fzf_hist='fzf_run_cmd_from_history' #///
#/////////////////////////////////////////////

function fuzzy_search_files_on_path() {
    local _path="$1"
    find tree "$_path" -type f \
    | fzf -i -m --cycle \
        --preview='echo {}' \
        --preview-window down:10% \
        --color bg:#222222,preview-bg:#333333   
}

#/////////////////////////////
alias _fop='files_on_path' #///
#/////////////////////////////

# Select a commit from git log using fzf.
function fzf_git_log() {
    local selected_commit
    selected_commit=$(git log --oneline | fzf) && git show "$selected_commit"
}

alias _gl='fzf_git_log'

# Search for patterns in files using ag (The Silver Searcher) and fzf.
function fzf_ag() {
    local selected_file
    selected_file=$(ag "$1" . | fzf) && $EDITOR "$selected_file"
}

alias _ag='fzf_ag'

# Select a Docker container from docker ps using fzf.
function fzf_docker_ps() {
    local selected_container
    selected_container=$(docker ps -a | fzf | awk '{print $1}') && docker logs "$selected_container"
}

alias _dps='fzf_docker_ps'

# Select an SSH host from known_hosts using fzf.
function fzf_ssh() {
    local selected_host
    selected_host=$(cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | fzf --preview 'echo {}') && ssh "$selected_host"
}

alias _ssh='fzf_ssh'

# Use grep interactively to search queries.
function fzf-grep() {
    local selected_file
    selected_file=$(grep -Ril "$1" . | fzf) && $EDITOR "$selected_file"
}

# Search for files interactively.
function fzf-find() {
    local selected_file
    selected_file=$(find . -type f | fzf) && $EDITOR "$selected_file"
}

autoload -Uz fzf_run_cmd_from_history fzf_command_widget fzf_man fuzzy_search_files_on_path

# Initialize fzf
if [[ -x "$(command -v fzf)" ]]; then
    #export FZF_DEFAULT_COMMAND='ag -g ""'
    #export FZF_DEFAULT_OPTS='-m --preview-window=up:40%:wrap'
fi
