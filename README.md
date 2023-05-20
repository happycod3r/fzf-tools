# fzf-tools.zsh

## [Table Of Contents](#table-of-contents)

- [About](#about)
- [Usage](#usage)
    * oh-my-zsh
    * stand-alone
- [Documentation](#documentation)
	* [fzf-run-command-from-history](#fzf-run-command-from-history)
	* [fzf-command-widget](fzf-command-widget)
	* [fzf-man](fzf-man)
- [Contributing](#contributing)
- [Security](#security)
- [Contacts](#contacts)


## [About](#about)

The fzf-tools plugin provides functions, key-bindings, and aliases that aim to integrate **fuzzy finder** capabilities into the command line as a default output for certain commands such as `man`, `ls`, `find`, `printenv`, `alias` and others.
My aim was to make it so that **fzf** would work without having to manually pipe commands through it, write aliases or explicitly call functions. 
In other words I wanted to avoid doing this:

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

There's nothing wrong with doing any of these, but I personally feel that fzf makes life so much easier and is actually such a game changer. If you never used it before it would make a great default feature for certain commands such as these. It took a lot of trial and error but I finally got everything working smoothly and functioning well. If you have suggestions, ideas etc. consult the [Contacts](#contacts) section.


## [Usage](#usage)

### oh-my-zsh:

To use fzf-tools with oh-my-zsh simply move the fzf-tools folder to the `~/.oh-my-zsh/custom/plugins` directory and then add ***fzf-tools*** to the ***plugins*** array in your ***~/.zshrc*** file.

```bash
plugins=(fzf-tools ...)
```

### stand-alone:

to use fzf-tools without a plugin manager simply source the ***fzf-tools.zsh*** file in your ***~/.zshrc*** file.

```bash
source a/dir/of/your/choosing/fzf-tools.zsh
```

## [Documentation](#documentation)

### [fzf_run_command_from_history](#fzf-run-command-from-history)
>**Allows searching for and executing a command from your command history using fuzzy finder.**

```bash
function fzf_run_cmd_from_history() {
  local  selected_command
  selected_command=$(history  \
  	|  awk '{$1=""; print $0}' \
	|  awk '!x[$0]++' \
	|  fzf +s --preview 'echo {}' --preview-window down:10%)
  
  if [[ -n  "$selected_command" ]]; then
	eval  "$selected_command"
  fi
}
```
 - The `history` command gets the command history of the current session.
 - The first `awk` command removes the line numbers from the history output in order to eval the command down the line.
 - The second `awk` command removes duplicate lines from the output.
 - The output is then piped to `fzf` using the `+s` flag to enable the *multi-select* feature.
 - The 	`--preview` option is used to show a preview of the selected command using the `echo` command. You can replace `'echo {}` with any other command you want to preview instead.
 - The `--preview-window` option sets the size and position of the preview window. It's at 10% to leave just enough room to display the currently selected command.
 -  The selected command is then stored in the `selected_command` variable.
 - Finally it checks if a command is selected (*i.e., the selected_command variable is not empty*), and if so it is evaluated using eval.
---
Note: *Choosing a previous *cd* command from your history may fail to execute as the `fzf_run_command_from_hisory` function doesn't take into account your current position in the directory stack, so if you aren't in the same position that you were originally in when executing the `cd some-dir` command from your history it will fail giving you the error
"cd: no such file or directory: some-dir".*

------

### [fzf_command_widget](fzf-command-widget)

>**Defines the 'accept-line' widget function.**

**Please note that the `fzf_command_widget` function modifies the behavior of the Enter key for specific commands, so it may not work as expected in all scenarios! Also, if you decide to add to this or change anything, be cautious when modifying the behavior of core commands like ls and man!**

```bash
function  fzf_command_widget() {
	local  full_command=$BUFFER
	case  "$full_command"  in
		ls*)
			BUFFER="$full_command | fzf --preview='echo {}' --preview-window right:50%"
		;;
		man*)
			BUFFER="fzf_man $full_command"
		;;
		printenv* | env*)
			BUFFER="$full_command | fzf --preview='echo {}' --preview-window down:10%"
		;;
		grep*)
			BUFFER="$full_command | fzf --preview='echo {}' --preview-window down:10%"
		;;
		find*)
			BUFFER="$full_command | fzf --preview='echo {}' --preview-window down:10%"
		;;
	esac
	zle  accept-line
}
```

The `fzf_command_widget` function is designed to handle the behavior when the enter key is pressed. It takes the entire command line entered by the user and stores it in a variable called `$full_command`. The case statement then checks for different commands and prefixes the existing command with the required options, arguments, and flags, before piping it through `fzf`.
For example, when the user enters `ls -la /path/to/directory` and presses `Enter(^M)`, the `ls` command with options and arguments will be executed as `ls --color=auto -la /path/to/directory | fzf`.
Similarly, other commands like `man`, `printenv` (including `env` as an alternative), `grep`, and `find` will be processed with their respective options, arguments, and flags.
Please keep in mind that this approach will pass the entire command line through fzf, including options, arguments, and flags. However, it does not perform in-depth parsing or validation of the command structure, so the behavior and correctness of the resulting command are dependent on the proper usage of options and arguments. If you're not sure about a commands options and flags you can always consult the man pages. 

 - After the command line is stored in `$full_command` the `case` statement checks if the command you entered is either `ls`, `man`, `printenv`, `env`, `grep` or `find`.
 - For `ls*`, the `BUFFER` is modified to `$full_command | fzf --preview='echo {}' --preview-window right:50%` which pipes the output of `ls` through `fzf`.
 - For `man`, the `BUFFER` is modified to `fzf_man $full_command` which is called to pipe the output through `fzf` giving you a list of the manuals to choose from.
 - For `printenv* | env*`, the `BUFFER` is set to `$full_command | fzf --preview='echo {}' --preview-window down:10%`, which pipes the output of `printenv | env` through `fzf`.
 - For `grep*`, the `BUFFER` is set to `$full_command | fzf --preview='echo {}' --preview-window down:10%`, which sets up `grep` to search and pipe the output through `fzf`.
 - For `find*`, the `BUFFER` is set to `$full_command | fzf --preview='echo {}' --preview-window down:10%`, which executes`grep*` and pipes the output through `fzf`.
 - The `zle accept-line` command accepts the modified command line and executes it.
 
Next we have to bind the `accept-line` widget function to the `Enter` key:

```bash
zle -N fzf_command_widget
bindkey '^M' fzf_command_widget
```

 -  The `zle -N fzf_command_widget` line creates a new Zsh widget from the `fzf_command_widget` function.
 -  The `bindkey '^M' fzf_command_widget` line binds the new widget to the Enter key (`^M`).

My original approach for detecting specific commands like `ls` and `man` involved using the `precmd` hook which is a function defined by `zsh` that gets invoked before each prompt, so essentially every time the user presses the `Enter key (^M)`, but this wasn't straight forward enough. I found myself tinkering with code more than progressing, so I decided to just create a *widget* and bind it to the `Enter key (^M)`  

------

### [fzf_man](#fzf-man)

>**The `fzf_man` function is called by the `fzf_command_widget` function when it detects that the user has entered the `man` command.**

```bash
function  fzf_man() {
  local  selected_command
  selected_command=$(man  -k . \
	|  awk '{print $1}' \
	|  sort  \
	|  uniq  \
	|  fzf +s --preview='echo {}' --preview-window down:10%)
		
  if [[ -n  "$selected_command" ]]; then
	man  "$selected_command"  \
		|  fzf  --preview='echo {}'  --preview-window  down:10%
  fi
}
```

 - If the command retrieved in `fzf_command_widget `is `man`, the `fzf_man` function is called.
 - The `fzf_man` function runs the `man -k` . command to retrieve available manual pages, then extracts the first column (command names) using `awk`, removes duplicates using `sort` and `uniq`, and finally pipes the output through `fzf`.
 - If a command is selected from fzf, it is passed to the man command and piped through `fzf` again to display the corresponding manual page through fuzzy finder for easy searching through the text.

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
