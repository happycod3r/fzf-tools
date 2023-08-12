#########################################################################
#///////////////////////////////////////////////////////////////////////#
#//////                                                          ///////#
#////// Name: FZF-Tools                                          ///////#
#////// File: fzf-tools.plugin.zsh                               ///////#
#////// Author: happycod3r                                       ///////#
#////// Use: Integrates FZF into the command line.               ///////#
#////// Check out the README.md for all of the documentation.    ///////#
#//////                                                          ///////#       
#///////////////////////////////////////////////////////////////////////#       
#########################################################################


function fzf-command-widget() {
    local full_command=$BUFFER

    case "$full_command" in
        ls*)
            BUFFER="$full_command | fzf --multi --cycle --no-sort --preview='echo {}' --preview-window down:10% --layout='reverse-list' --color bg:#222222,preview-bg:#333333"
        ;;
        man*)
            BUFFER="fzf-man $full_command"
        ;;
        printenv* | env*)
            BUFFER="$full_command | fzf --multi --cycle --no-sort --preview='echo {}' --preview-window down:10% --layout='reverse-list' --color bg:#222222,preview-bg:#333333"
        ;;
        set)
            BUFFER="$full_command | fzf --multi --cycle --no-sort --preview='echo {}' --preview-window down:10% --layout='reverse-list' --color bg:#222222,preview-bg:#333333"
        ;;
        grep*)
            BUFFER="$full_command | fzf -i --multi --cycle --no-sort --preview='echo {}' --preview-window down:10% --layout='reverse-list' --color bg:#222222,preview-bg:#333333"
        ;;
        find*)
            BUFFER="$full_command | fzf -i --multi --cycle --no-sort --preview='echo {}' --preview-window down:10% --layout='reverse-list' --color bg:#222222,preview-bg:#333333"
        ;;
        'ps aux')
            BUFFER="$full_command | fzf --multi --cycle --no-sort --preview='echo {}' --preview-window down:10% --layout='reverse-list' --color bg:#222222,preview-bg:#333333"
        ;;
    esac
    zle accept-line
    # Uncomment if the long command left over on the previous prompt bothers you.
    # $(clear)
}

zle -N fzf-command-widget
bindkey '^M' fzf-command-widget

function fzf-man() {
    local selected_command
    selected_command=$(man -k . | awk '{print $1}' | sort | uniq | fzf --multi --cycle --preview='echo {}' --preview-window down:10%)

    if [[ -n "$selected_command" ]]; then
        man "$selected_command" | fzf --multi --cycle --tac --no-sort --preview='echo {}' --preview-window down:10% --layout='reverse-list' --color bg:#222222,preview-bg:#333333
    fi
}

# I want to add --multi and try to select multiple commands 
# and concatenate them together. 
function fzf-run-cmd-from-history() {
    local selected_command
    selected_command=$(history | awk '{$1=""; print $0}' | awk '!x[$0]++' | fzf --cycle --tac --no-sort --preview 'echo {}' --preview-window down:10% --color bg:#222222,preview-bg:#333333)

    if [[ -n "$selected_command" ]]; then
        eval "$selected_command"
    fi
}

alias fzhist='fzf-run-cmd-from-history'

function fzf-exec-scripts() {
	local directory="$1"
	shift
	local file_exts=("$@")

	if [[ -z "$directory" || "${#file_exts[@]}" -eq 0 ]]; then
        echo "Usage: fzf-exec-scripts <directory> <file_extension1> [<file_extension2> ...]"
        return 1
	fi

	local selected_scripts=()
	local selected_script
	selected_script=$(find "$directory" -type f \( -name "*.${file_exts[1]}" $(printf -- "-o -name '*.%s' " "${file_exts[@]:1}") \) | fzf --multi --cycle --tac --no-sort --preview='echo {}' --preview-window  down:10% --layout='reverse-list' --color  bg:#222222,preview-bg:#333333) && selected_scripts=("${(f)selected_script}")

	if [[ "${#selected_scripts[@]}" -eq 0 ]]; then
        echo "No scripts selected."
        return
	fi

	for script in "${selected_scripts[@]}"; do
        chmod +x "$script"
        case "$script" in
            *.sh)
                bash "$script"
            ;;
            *.zsh)
                zsh "$script"
            ;;
            *.bash)
                bash "$script"
            ;;
		    *.js)
                node "$script"
            ;;
		    *.py)
                python "$script"
            ;;
	        *.rb)
                ruby "$script"
            ;;
            *.rs)
                filename=$(basename "${directory}/${script}")
                rustc "$script"
                ./$filename
            ;;
		    *)	
                filename=$(basename "${directory}/${script}")
                extension="${filename##*.}"
                if [[ "$extension" == "zsh" ]]; then
                    cat >&2 <<'EOF'
                    ZSH isn't installed on your system yet.
                    Check out https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH for more information on how to install it.
EOF
                elif [[ "$extension" == "js" ]]; then
                    cat >&2 <<'EOF'
                    Node isn't installed on your system yet.
                    You can install it directly using the following command:
                        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
                    Or check out https://nodejs.dev/en/ for more information.
EOF
                elif [[ "$extension" == "py" ]]; then
                    cat >&2 <<'EOF'
                    Python isn't installed on your system yet.
                    Check out https://www.python.org/downloads/ for more information on how to install it.
EOF
                elif [[ "$extension" == "rb" ]]; then
                    cat >&2 <<'EOF'
                    Ruby isn't installed on your system yet.
                    Check out https://www.ruby-lang.org/en/documentation/installation/ for more information on how to install it.
EOF
                elif [[ "$extension" == "rs" ]]; then
                    cat >&2 <<'EOF'
                    Rust isn't installed on your system yet.
                    You can:
                        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
                    or check out https://www.rust-lang.org/tools/install for more information.
EOF
                    return 1
                fi
            ;;
        esac
	done
}

alias fzscripts='fzf-exec-scripts'

function fzf-search-files-on-path() {
    local _path="$1"
    find tree "$_path" -type f | fzf -i --multi --cycle --preview='echo {}' --preview-window down:10% --color bg:#222222,preview-bg:#333333   
}

alias fzfop='fzf-search-files-on-path'

function fzf-git-log() {
    local selected_commit
    selected_commit=$(\
        git log --oneline | fzf --multi --no-sort --cycle \
            --preview='echo {}' \
            --preview-window down:10% \
            --layout='reverse-list' \
            --color bg:#222222,preview-bg:#333333 \
    ) && git show "$selected_commit"
}

alias fzgl='fzf-git-log'

function fzf-ag() {
    local selected_file
    selected_file=$(\
        ag "$1" . | fzf \
        --multi --no-sort --cycle \
        --preview='echo {}' \
        --preview-window down:10% \
        --layout='reverse-list' \
        --color bg:#222222,preview-bg:#333333 \
    ) && $EDITOR "$selected_file"
}

alias fzag='fzf-ag'

function fzf-docker-ps() {
    local selected_container
    selected_container=$(docker ps -a | fzf --multi --no-sort --cycle --preview='echo {}' --preview-window down:10% --layout='reverse-list' --color bg:#222222,preview-bg:#333333 | awk '{print $1}') && docker logs "$selected_container"
}

alias fzdps='fzf-docker-ps'

function fzf-ssh() {
    local selected_host
    selected_host=$(\
        cat ~/.ssh/known_hosts \
        | cut -f 1 -d ' ' \
        | sed -e s/,.*//g | uniq | fzf --multi --no-sort --cycle \
            --preview='echo {}' \
            --preview-window down:10% \
            --layout='reverse-list' \
            --color bg:#222222,preview-bg:#333333\
    ) && ssh "$selected_host"
}

alias fzssh='fzf-ssh'

function fzf-grep() {
    local selected_file
    selected_file=$(grep -Ril "$1" . | fzf --multi --no-sort --cycle \
        --preview='echo {}' \
        --preview-window down:10% \
        --layout='reverse-list' \
        --color bg:#222222,preview-bg:#333333\
    ) && $EDITOR "$selected_file"
}

alias fzgrep='fzf-grep'

function fzf-find() {
    local selected_file
    selected_file=$(find . -type f | fzf --multi --no-sort --cycle \
        --preview='echo {}' \
        --preview-window down:10% \
        --layout='reverse-list' \
        --color bg:#222222,preview-bg:#333333\
    ) && $EDITOR "$selected_file"
}

alias fzfind='fzf-find'

autoload -Uz fzf-command-widget fzf-man fzf-run-cmd-from-history fzf-exec-scripts fzf-search-files-on-path fzf-git-log fzf-ag fzf-docker-ps fzf-ssh fzf-grep fzf-find

# Initialize fzf
if [[ -x "$(command -v fzf)" ]]; then
    # Change the defaults to whatever you would like here.
    # You can also consult the fzf documentation for more options and 
    # information @ https://github.com/junegunn/fzf
    export FZF_DEFAULT_COMMAND='ag -g ""'
    export FZF_DEFAULT_OPTS='-m --preview-window=up:40%:wrap'
fi
