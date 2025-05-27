# if status is-interactive
#    # Commands to run in interactive sessions can go herefunction fish_prompt
set -x PATH /opt/homebrew/bin/ $PATH
set -x LIBRARY_PATH /opt/homebrew/opt/postgresql@16/lib $LIBRARY_PATH
set -x PKG_CONFIG_PATH /opt/homebrew/opt/postgresql@16/lib/pkgconfig $PKG_CONFIG_PATH
# set -g fish_key_bindings fish_vi_key_bindings
alias background="~/background/target/release/background"
alias bitwarden="~/AppImages/Bitwarden-2023.7.0-x86_64.AppImage"
alias cat="bat"
alias ls="eza"

# set -x SHELL /bin/bash
bind \t accept-autosuggestion
# function fish_user_key_bindings
#     bind \cf forward-word
#     bind \ef forward-char
# end

set -Ux EDITOR nvim

function compile -d "Compiles a c++ file with c++17 and all warnings" -a path
    set index 1
    set last_index (string length $argv[1])
    for char in (string split '' $argv[1])
        if [ $char != '.' ]
            set index (math $index + 1)
        else
            set last_index $index
        end
    end
    set out (string sub -s 1 -l (math $last_index - 1) $argv[1])

    g++ -std=c++17 -O2 -o "$out" $1 -Wall $argv[1]
end

function run -d "Compiles and runs a c++ file" -a path
    set index 1
    set last_index (string length $argv[1])
    for char in (string split '' $argv[1])
        if [ $char != '.' ]
            set index (math $index + 1)
        else
            set last_index $index
        end
    end
    set out (string sub -s 1 -l (math $last_index - 1) $argv[1])

    compile $argv[1] && "./$out" & fg
end
# alias count_lines="find . -name '*.rs' | sed 's/.*/"&"/' | xargs wc -l"
alias count_lines="~/countlines.sh"

# ~/.local/bin/wal -i ~/temp/wallhaven-z8p1vg.jpg -q
# ~/.local/bin/wal -R
starship init fish | source


function fzf_find_files
    fzf --preview 'bat --color=always --style=header,grid --line-range :500 {}' --preview-window=up:60%:wrap --bind 'ctrl-d:execute(bat --color=always --style=header,grid --line-range :500 {})+abort'
end






function fzf_cd
    cd ~
    set selected (find $HOME -type d | fzf --preview 'ls {}' --preview-window=up:60%:wrap)
    if test -n "$selected"
        cd $selected
    end
end

function fzf_file
    cd ~
    set selected (find $HOME -type f | fzf --preview 'ls {}' --preview-window=up:60%:wrap)
    if test -n "$selected"
        nvim $selected
    end
end

function fzf_nvim
    cd ~
    set selected (find $HOME -type d | fzf --preview 'ls {}' --preview-window=up:60%:wrap)
    if test -n "$selected"
        cd $selected
        nvim .
    end
end

bind \cf fzf_cd
bind \cn fzf_nvim
bind \ce fzf_file

set -gx PATH $HOME/.local/bin/ $PATH
set -gx PATH /usr/local/anaconda3/bin $PATH
set -gx PATH $HOME/.cargo/bin $PATH
set -gx PATH /Users/ishan/.ghcup/hls/2.5.0.0/bin $PATH
set -gx PATH /Users/ishan/.ghcup/ghc/9.4.8/bin/ $PATH
set -gx PATH /Users/ishan/.ghcup $PATH

# commandline -f repaint
# bind --edit-mode-command fish_bind \cg fzf_cd

# opam configuration
source /Users/ishan/.opam/opam-init/init.fish >/dev/null 2>/dev/null; or true

zoxide init fish --cmd cd | source

if set -q ZELLIJ
else
  zellij -l ~/.config/zellij/no-tab-bar-layout.kdl
end

export PATH="$PATH:/Users/ishan/.risc0/bin"
