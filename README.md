# fzf-tools.zsh
>**FZF-Tools is a Zsh plugin aimed to enhance your command-line workflow by providing interactive selection capabilities through fzf, allowing you to quickly find files, search & run commands from history, run scripts of many supported types, browse git commits, and more.**

## [Table Of Contents](#toc)
- [Table Of Contents](#toc)
- [About](#about)
- [Install](#install)
  - [Manual Install](#manual_install)
  - [Command Line Install](#command_line_install)
    - [Using Git Clone](#git_clone)
	- [Using Curl](#curl)
- [Usage](#usage)
  - [oh-my-zsh:](#ohmyzsh)
  - [stand-alone:](#stand_alone)
- [Documentation](#documentation)
  - [fzf-command-widget](#fzf-command-widget)
  - [fzf-man](#fzf-man)
  - [fzf-run-command-from-history](#fzf-run-command-from-history)
  - [fzf-exec-scripts](#fzf-exec-scripts)
  - [fzf-search-files-on-path](#fzf-search-files-on-path)
  - [fzf-git-log](#fzf-git-log)
  - [fzf-ag](#fzf-ag)
  - [fzf-docker-ps](#fzf-docker-ps)
  - [fzf-ssh](#fzf-ssh)
  - [fzf-grep](#fzf-grep)
  - [fzf-find](#fzf-find)
- [Contributing](#contributing)
- [Security](#security)
- [Contacts](#contacts)


## [About](#about)

The fzf-tools plugin provides functions, key-bindings, and aliases that aim to integrate **fuzzy finder** capabilities into the command line as a default output for certain commands such as `man`, `ls`, `find`, `printenv`, `alias` and others.
My aim was to make it so that **fzf** would work without having to manually pipe commands through it, write aliases or explicitly call functions. 
In other words I wanted to avoid doing the following each time:

```bash
man -k . | awk '{print $1}' | sort | uniq | fzf | xargs -r man
ls |  --color=auto | fzf
find | fzf
printenv | fzf
alias | fzf
# or...
alias l="ls --color=auto | fzf"
alias m="man -k . | awk '{print $1}' | sort | uniq | fzf | xargs -r man"
```

There's nothing wrong with doing any of these, but I personally feel that fzf makes a great default feature for certain commands such as `ls` or `man`. It took a lot of trial and error but I finally got everything working smoothly and functioning well. If you have suggestions, ideas etc. consult the [Contacts](#contacts) section.

## [Install](#install)

To download and install fzf-tools choose an install method and follow the corresponding steps. Once
fininshed jump to the [Usage](#usage) section.

### [Manual Install](#manual_install)

1. Download and place the ***zsh-toggles*** folder in a location of your choosing.
2. Next source the script as shown in the [Usage](#usage) section.

### [Command Line Install](#command_line_install)

#### [Using Git Clone:](#git_clone)

1) Open your terminal and navigate to the directory where you want to clone the repository: 

```bash
cd where/I/want/to/install
```

2) Next run the following command to clone the repository to the chosen location:
```bash
git clone https://github.com/happycod3r/fzf-tools.git
```

#### [Using Curl:](#curl)

1) Pick a directory to download it to:

```bash
cd where/I/want/
```

2) Paste the following line into your terminal and press the `Enter (^M)` key:

```bash
curl https://github.com/happycod3r/fzf-tools.git
```

## [Usage](#usage)

### [oh-my-zsh:](#ohmyzsh)

To use fzf-tools with oh-my-zsh follow these 2 steps:

1) Install fzf: You need to install fzf on your system. You can find installation instructions for your operating system in the fzf GitHub repository: https://github.com/junegunn/fzf
2) Simply move the fzf-tools folder to the `~/.oh-my-zsh/custom/plugins` directory and then add ***fzf-tools*** to the ***plugins*** array in your ***~/.zshrc*** file.

```bash
plugins=(fzf-tools ...)
```

### [stand-alone:](#stand_alone)

To use fzf-tools without a plugin manager like oh-my-zsh follow these steps:

  1) Install fzf: You need to install fzf on your system. You can find installation instructions for your operating system in the fzf GitHub repository: https://github.com/junegunn/fzf
  2) Next put the fzf-tools folder in a place of your choosing then source the ***fzf-tools.zsh*** file in your ***~/.zshrc*** file.

```bash
source a/dir/of/your/choosing/fzf-tools.zsh
```

## [Documentation](#documentation)


### [fzf-command-widget](#fzf-command-widget)

>**Defines the 'accept-line' widget function.**

**Please note that the `fzf-command-widget` function modifies the behavior of the Enter key for specific commands, so it may not work as expected in all scenarios! Also, if you decide to add to this or change anything, be cautious when modifying the behavior of core commands like ls and man!**

```bash
function  fzf-command-widget() {
	local  full_command=$BUFFER
	case  "$full_command"  in
		ls*)
			BUFFER="$full_command | fzf --multi --cycle --no-sort \
				--preview='echo {}' \
				--preview-window down:10% \
				--layout='reverse-list' \
				--color bg:#222222,preview-bg:#333333"
		;;
		man*)
			BUFFER="fzf-man $full_command"
		;;
		printenv* | env*)
			BUFFER="$full_command | fzf --multi --cycle --no-sort \
				--preview='echo {}' \
				--preview-window down:10% \
				--layout='reverse-list' \
				--color bg:#222222,preview-bg:#333333"
		;;
		set)
			BUFFER="$full_command | fzf --multi --cycle --no-sort \
				--preview='echo {}' \
				--preview-window down:10% \
				--layout='reverse-list' \
				--color bg:#222222,preview-bg:#333333"
		;;
		grep*)
			BUFFER="$full_command | fzf -i --multi --cycle --no-sort \
				--preview='echo {}' \
				--preview-window down:10% \
				--layout='reverse-list' \
				--color bg:#222222,preview-bg:#333333"
		;;
		find*)	
			BUFFER="$full_command | fzf -i --multi --cycle --no-sort \
				--preview='echo {}' \
				--preview-window down:10% \
				--layout='reverse-list' \
				--color bg:#222222,preview-bg:#333333"
		;;
		'ps aux')
			BUFFER="$full_command | fzf --multi --cycle --no-sort \
				--preview='echo {}' \
				--preview-window down:10% \
				--layout='reverse-list' \
				--color bg:#222222,preview-bg:#333333"
		;;
	esac
	zle  accept-line
	# Uncomment if the long command left over on the previous prompt bothers you.
	# $(clear)
}
```

The `fzf-command-widget` function is designed to handle the behavior when the enter key is pressed. It takes the entire command line entered by the user and stores it in a variable called `$full_command`. The case statement then checks for different commands and prefixes the existing command with the required options, arguments, and flags, before piping it through `fzf`.
For example, when the user enters `ls -la /path/to/directory` and presses `Enter(^M)`, the `ls` command with options and arguments will be executed as `ls --color=auto -la /path/to/directory | fzf...`
Similarly, other commands like `ls`, `man`, `printenv` (including `env` as an alternative), `set`, `grep`, `find` and `ps aux` will be processed with their respective options, arguments, and flags.
Please keep in mind that this approach will pass the entire command line through fzf, including options, arguments, and flags. However, it does not perform in-depth parsing or validation of the command structure, so the behavior and correctness of the resulting command are dependent on the proper usage of options and arguments. Due to this, entering invalid commands may have unexpected results. If you're not sure about a command's options and flags you can always consult the man pages. 

 - After the command line is stored in `$full_command` the `case` statement checks if the command you entered is either `ls`, `man`, `printenv`, `env`, `grep`, `find`, `set` or `ps aux`.
 - For `ls*`, the `BUFFER` is modified to the following command, which pipes the output of `ls` through `fzf`.
```bash 
	BUFFER="$full_command | fzf --multi --cycle --no-sort \
			--preview='echo {}' \
			--preview-window right:50% \
			--layout='reverse-list' \
			--color bg:#222222,preview-bg:#333333"
```
 - For `man`, the `BUFFER` is modified to `fzf_man $full_command` which is called to pipe the output through `fzf` giving you a list of the manuals to choose from.
```bash
	BUFFER="fzf-man $full_command"
```
 - For `printenv* | env*`, the `BUFFER` is set to the following command, which pipes the output of `printenv | env` through `fzf`.
```bash
	BUFFER="$full_command | fzf --multi --cycle --no-sort \
			--preview='echo {}' \
			--preview-window down:10% \
			--layout='reverse-list' \
			--color bg:#222222,preview-bg:#333333"
```
 - For `grep*`, the `BUFFER` is set to the following command, which sets up `grep` to search and pipe the output through `fzf`.
```bash
	BUFFER="$full_command | fzf -i --multi --cycle --no-sort \
			--preview='echo {}' \
			--preview-window down:10% \
			--layout='reverse-list' \
			--color bg:#222222,preview-bg:#333333"
```
 - For `find*`, the `BUFFER` is set to the following command, which executes`find*` and pipes the output through `fzf`.
```bash
	BUFFER="$full_command | fzf -i --multi --cycle --no-sort \
			--preview='echo {}' \
			--preview-window down:10% \
			--layout='reverse-list' \
			--color bg:#222222,preview-bg:#333333"
```
 - For `ps aux` the `BUFFER` is set to the following command, which executes `ps aux*` and pipes the output through `fzf`.
```bash
	BUFFER="$full_command | fzf --multi --cycle --no-sort \
			--preview='echo {}' \
			--preview-window down:10% \
			--layout='reverse-list' \
			--color bg:#222222,preview-bg:#333333"
```
 - The `zle accept-line` command accepts the modified command line and executes it.
 ---
Next we have to bind the `accept-line` widget function to the `Enter` key:

```bash
zle -N fzf-command-widget
bindkey '^M' fzf-command-widget
```

 -  The `zle -N fzf-command-widget` line creates a new zsh widget from the `fzf_command_widget` function.
 -  The `bindkey '^M' fzf-command-widget` line binds the new widget to the Enter key (`^M`).

My original approach for detecting specific commands like `ls` and `man` involved using the `precmd` hook which is a function defined by `zsh` that gets invoked before each prompt, so essentially every time the user presses the `Enter key (^M)`, but this wasn't straight forward enough. I found myself tinkering with code more than progressing, so I decided to just create a *widget* and bind it to the `Enter key (^M)`  

------

### [fzf-man](#fzf-man)

>**The `fzf-man` function is called by the `fzf-command-widget` function when it detects that the user has entered the `man`command and not meant to be called externally.**

```bash
function  fzf-man() {
	local  selected_command
	selected_command=$(
		man  -k . \
		|  awk '{print $1}' \
		|  sort  \
		|  uniq  \
		|  fzf  --multi  --cycle  \
			--preview='echo {}' \
			--preview-window down:10%
	)
	if [[ -n  "$selected_command" ]]; then
		man  "$selected_command"  \
			|  fzf  --multi  --cycle  --tac  --no-sort  \
				--preview='echo {}'  \
				--preview-window  down:10%  \
				--layout='reverse-list'  \
				--color  bg:#222222,preview-bg:#333333
	fi
}
```

 - If the command retrieved in `fzf-command-widget `is `man`, the `fzf-man` function is called.
 - The `fzf-man` function runs the `man -k` . command to retrieve available manual pages, then extracts the first column (command names) using `awk`, removes duplicates using `sort` and `uniq`, and finally pipes the output through `fzf`.
 - If a command is selected from fzf, it is passed to the man command and piped through `fzf` again to display the corresponding manual page through fuzzy finder for easy searching through the text.
 - The `--tac` flag on the second pipe through to `fzf` is required to display sentences in a legible manner. Without the `--tac` all of the man pages text is displayed backwards. The only downside to `--tac` is that the man pages will be displayed bottom up, so you will start at the bottom and scroll up to reach the beginning. Removing `--tac` fixes this, but then reverses the text as previously mentioned. This behavior is because of `fzf`. To me the benefits of `fzf` outweigh the slight nuisance of having to start at the bottom though.
 - Adding `--layout='reverse-list'`  helps with the scrolling. If a man page is selected the prompt will be displayed at the bottom and this also allows scrolling in a more familiar manner, from top to bottom as well.  
---

### [fzf-run-command-from-history](#fzf-run-command-from-history)
>**Allows searching for and executing a command from your command history interactively using fzf.**

```bash
function  fzf-run-cmd-from-history() {
	local  selected_command
	selected_command=$(
		history  \
		|  awk '{$1=""; print $0}' \
		|  awk '!x[$0]++' \
		|  fzf  --cycle  --tac +s --no-sort  \
			--preview 'echo {}' \
			--preview-window down:10% \
			--color bg:#222222,preview-bg:#333333 \
	)
	if [[ -n  "$selected_command" ]]; then
		eval  "$selected_command"
	fi
}

alias  fzhist='fzf-run-cmd-from-history'
```
 - The `history` command gets the command history of the current session.
 - The first `awk` command removes the line numbers from the history output in order to eval the command down the line.
 - The second `awk` command removes duplicate lines from the output.
 - The output is then piped to `fzf` using the `+s` flag to enable the *multi-select* feature.
 - The `--cycle` flag enables you to easily cycle back to beginning of your history from the end or vice versa. 
 - The `--no-sort` flag is also enabled to avoid sorting the results. This way you see your history in the correct order with the last command listed first.
 - The 	`--preview` option is used to show a preview of the selected command using the `echo` command. You can replace `'echo {}` with any other command you want to preview instead.
 - The `--preview-window` option sets the size and position of the preview window. It's at 10% to leave just enough room to display the currently selected command.
 -  The selected command is then stored in the `selected_command` variable.
 - Finally it checks if a command is selected (*i.e., the selected_command variable is not empty*), and if so it is evaluated using eval.
---
Note: *Choosing a previous `cd` command from your history may fail to execute as the `fzf-run-command-from-hisory` function doesn't take into account your current position in the directory stack, so if you aren't in the same position that you were originally in when executing the `cd some-dir` command from your history it will fail giving you the following error:
`cd: no such file or directory: some-dir`

------

### [fzf-exec-scripts](#fzf-exec-scripts)
>**This command will allow you to search for a script/s within the desired directory and its subdirectories, allowing you to interactively select and execute the desired script/s with their respective interpreters. When more than one script is selected they are all executed consecutively one after the other.**

```bash
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
	selected_script=$(find "$directory" -type f \( -name "*.${file_exts[1]}" $(printf -- "-o -name '*.%s' " "${file_exts[@]:1}") \) \
		| fzf --multi -m --cycle --tac +s  \
				--preview='echo {}'  \
				--preview-window  down:10%  \
				--layout='reverse-list'  \
				--color  bg:#222222,preview-bg:#333333) && selected_scripts=("${(f)selected_script}")

	if [[ "${#selected_scripts[@]}" -eq 0 ]]; then
	    echo "No scripts selected."
	    return
	fi

	for script in "${selected_scripts[@]}"; do
	    chmod +x "$script"
	    case "$script" in
		    *.sh)
				bash  "$script"
			;;
			*.zsh)
				zsh  "$script"
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
				rustc  "$script"
				./$filename
			;;
		    *)	
		        echo "Unsupported file extension: $script"
		        return 1
	        ;;
	    esac
	done
}

alias fzscripts='fzf-exec-scripts'
```
- The `fzf-exec-scripts` function accepts a directory as the first parameter and multiple file extensions as subsequent parameters. The `shift` command is used to remove the first parameter (`$1`) from the list, so that the remaining parameters represent the file extensions.
- The function checks if both the *directory* and file *extensions* are provided. If either of them is missing, it displays a usage message and returns with an '*unsupported file extension*' error.
- The `find` command is then used to search for files with the specified file extensions in the specified directory. The `-name` option in `find` is used with logical OR (`-o`) to match files with any of the specified extensions. 
- The resulting file paths are then piped through `fzf` for interactive selection.
- After selecting the scripts with `fzf` and storing them in the `$selected_scripts` array, we check if any scripts were selected `("${#selected_scripts[@]}" -eq 0)`. If no scripts were selected, we display a message and return.
- If one or more scripts were selected, we iterate over the `$selected_scripts` array and execute each script individually. The execute permission is set on each script before executing it.
- The `case` statement determines the file extension of each script and executes it with the corresponding interpreter.
- The default case of the the `case` statement lets the user know that the interpreter they need to run the selected script isn't installed and/or where to get it.

To use `fzf-exec-scripts` supply it with the desired directory of your script/s and file extensions as parameters. When providing a file extension/s be sure to leave out the prepended '`.`' on the extension/s as you only need the extension name by it self  (e.g. `.sh` -> `sh` | | `.js` -> `js`) .  For example:
```bash
fzf-exec-scripts /path/to/scripts/ sh js py rb 
```

---

### [fzf-search-files-on-path](#fzf-search-files-on-path)
> **Interactively search for files on a given path.**
```bash
function  fzf-search-files-on-path() {
	local  _path="$1"
	find  tree  "$_path"  -type  f  \
		|  fzf  -i --multim  --cycle  \
			--preview='echo {}'  \
			--preview-window  down:10%  \
			--color  bg:#222222,preview-bg:#333333
}

alias  fzfop='fzf-search-files-on-path'
```
- First the path is stored in the local `$_path` variable.
- The `find` command is then used to search the given path for all things of type `file` and pipes the results through `fzf`. 
---
### [fzf-git-log](#fzf-git-log)
> **Select a commit from git log using fzf.**
```bash
function  fzf-git-log() {
	local  selected_commit
	selected_commit=$(\
		git log --oneline  |  fzf  --multi  --no-sort  --cycle  \
			--preview='echo {}' \
			--preview-window down:10% \
			--layout='reverse-list' \
			--color bg:#222222,preview-bg:#333333 \
	) && git  show  "$selected_commit"
}

alias fzgl='fzf-git-log'
```
  - With this function, you can select a commit from the git log interactively. 
  - It executes `git log --oneline` to retrieve a concise log of commits, and pipes the output through `fzf`. 
  - Once you choose a commit, it displays the full details of that commit using `git show`.
---

### [fzf-ag](#fzf-ag)
> Search for patterns in files using ag (The Silver Searcher) and fzf.
```bash
function  fzf-ag() {
	local  selected_file
	selected_file=$(\
		ag "$1" . |  fzf  \
			--multi  --no-sort  --cycle  \
			--preview='echo {}' \
			--preview-window down:10% \
			--layout='reverse-list' \
			--color bg:#222222,preview-bg:#333333\
	) && $EDITOR  "$selected_file"
}

alias fzag='fzf-ag'
```
  - This function is similar to `fzf-grep` but uses `ag` (The Silver Searcher) instead of `grep`. 
  - It searches for patterns in files using `ag "$1"`, which searches for the specified pattern `($1)` in the current directory. 
  - The search results are then piped through `fzf`, and once you select a file, it opens in your default editor.
---

### [fzf-docker-ps](#fzf-docker-ps)
> **Select a Docker container from docker ps interactively using fzf**.
```bash
function  fzf-docker-ps() {
	local  selected_container
	selected_container=$(docker ps -a  |  fzf  \
		--multi  --no-sort  --cycle  \
		--preview='echo {}' \
		--layout='reverse-list' \
		--color bg:#222222,preview-bg:#333333 \ 
		|  awk '{print $1}') \
		&& docker  logs  "$selected_container"
}

alias fzdps='fzf-docker-ps'
```
  - With this function, you can select a Docker container from docker ps interactively.
  -  It executes `docker ps -a` to list all Docker containers and pipes the output through `fzf`. 
  - Once you select a container, it displays the logs of that container using `docker logs`.
---

### [fzf-ssh](#fzf-ssh)
> **Select an SSH host from known_hosts using fzf.**
```bash
function fzf-ssh() {
	local selected_host
	selected_host=$(\
		cat ~/.ssh/known_hosts \
		|  cut  -f  1  -d ' ' \
		|  sed  -e s/,.*//g |  uniq  |  fzf  --multi  --no-sort  --cycle  \
			--preview='echo {}' \
			--preview-window down:10% \
			--layout='reverse-list' \
			--color bg:#222222,preview-bg:#333333\
	) && ssh  "$selected_host"
}
alias fzssh='fzf-ssh'
```
- This function enables you to select an SSH host from your known_hosts file interactively. 
- It uses `cat`, `cut`, `sed` and `uniq` to read the known_hosts file, extract the hostnames, remove any additional information, and presents them in fzf for selection. 
- Once you choose a host, it initiates an SSH connection using `ssh`.
---
### [fzf-grep](#fzf-grep)
> **Interactively search for patterns in files using grep and fzf.**
```bash
function  fzf-grep() {
	local  selected_file
	selected_file=$(grep  -Ril "$1" . |  fzf  --multi  --no-sort  --cycle  \
		--preview='echo {}' \
		--preview-window down:10% \
		--layout='reverse-list' \
		--color bg:#222222,preview-bg:#333333\
	) && $EDITOR  "$selected_file"
}

alias fzgrep='fzf-grep'
```
  - This function combines `grep` and `fzf` to search for patterns in files interactively. 
  - It uses the `grep -Ril` command to search for the specified pattern `($1)` recursively in the current directory and its subdirectories. 
  - The search results are then piped through `fzf`. 
  - Once you select a file, it opens in your default editor.
---

### [fzf-find](#fzf-find)
>**Search for files using find and fzf.**
```bash
function  fzf-find() {
	local  selected_file
	selected_file=$(find . -type f |  fzf  --multi  --no-sort  --cycle  \
		--preview='echo {}' \
		--preview-window down:10% \
		--layout='reverse-list' \
		--color bg:#222222,preview-bg:#333333\
	) && $EDITOR  "$selected_file"
}

alias fzfind='fzf-find'
```
  - This function allows you to search for files using the `find` command. It pipes the output of `find . -type f` (which searches for files in the current directory and its subdirectories) through `fzf` for interactive selection. 
  - Once you select a file, it opens in your default editor `($EDITOR)`.
---


```bash
autoload -Uz fzf-command-widget fzf-man fzf-run-cmd-from-history fzf-exec-scripts fzf-search-files-on-path fzf-git-log fzf-ag fzf-docker-ps fzf-ssh fzf-grep fzf-find
```
The `autoload -Uz` command ensures that the functions of this plugin are lazily loaded when they are invoked.

```bash
if [[ -x  "$(command  -v fzf)" ]]; then
	export FZF_DEFAULT_COMMAND='ag -g ""'
	export FZF_DEFAULT_OPTS='-m --preview-window=up:40%:wrap'
fi
```

Initializes the `FZF_DEFAULT_COMMAND` and `FZF_DEFAULT_OPTS` environment variables which can be used to customize fzf's behavior. These are just some example options to start with for the 2 variables, but you can change them to whatever you would prefer.

## [Contributing](#contributing)
If you have any feature requests, suggestions or general questions you can reach me via any of the methods listed below in the "[Contacts](#contact)" section

## [Security](#security)
### Reporting a vulnerability or bug?

**Do not submit an issue or pull request**: A general rule of thumb is to never publicly report bugs or vulnerabilities because you might inadvertently reveal it to unethical people who may use it for bad. 
Instead, you can email me directly at: [**paulmccarthy676@gmail.com**](mailto:paulmccarthy676@gmail.com).
I will deal with the issue privately and submit a patch as soon as possible.
 
## [Contacts](#contacts)

Author: Paul M.
- Email: [paulmccarthy676@gmail.com](mailto:paulmccarthy676@gmail.com)
- Github: [https://github.com/happycod3r](https://github.com/happycod3r)
- Linkedin: [https://www.linkedin.com/in/paul-mccarthy-89165a269/](https://www.linkedin.com/in/paul-mccarthy-89165a269/)
- Facebook: [https://www.facebook.com/paulebeatz](https://www.facebook.com/paulebeatz)

[Back to top](#table-of-contents)
