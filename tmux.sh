# rename prefix key
set -g prefix C-s

# ask for a name when making a new window
bind-key c command-prompt -p "what are we calling it?:" "new-window; rename-window '%%'"

# reload config file (change file location to your the tmux.conf you want to use)
unbind r
bind r source-file ~/.tmux.conf \ display "Reloaded!"

# split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# switch panes using Alt-arrow without prefix
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# enable mouse control to select different panes
set -g mouse on

# don't do anything when a 'bell' rings
set -g visual-activity off
set -g visual-bell off
set -g visual-silence off
setw -g monitor-activity off
set -g bell-action none

# copy mode
setw -g mode-style 'fg=white bg=purple'

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'dracula/tmux'

## dracula
# set colors for each plugin "[background] [foreground]"
set -g @dracula-plugins "ssh-session git battery time"
set -g @dracula-border-contrast true
set -g @dracula-show-empty-plugins false

set -g @dracula-show-powerline true

set -g @dracula-show-left-icon "🌊"

set -g @dracula-git-disable-status true
set -g @dracula-git-no-repo-message ""
set -g @dracula-git-show-remote-status true
set -g @dracula-git-colors "green white"

set -g @dracula-show-ssh-session-port true
set -g @dracula-show-ssh-only-when-connected true
set -g @dracula-ssh-session-colors "green white"

set -g @dracula-show-location false

set -g @dracula-battery-colors "blue white"

set -g @dracula-time-format "%a %b %d 🏀 %I:%M %p"
set -g @dracula-time-colors "yellow dark_gray"

set -g @dracula-colors "
# tomorrow night eighties
foreground='#bf267a'
background='#ffffff'
highlight='#d6d6d6'
status_line='#efefef'
comment='#8e908c'
red='#c82829'
orange='#f5871f'
yellow='#eab700'
green='#718c00'
aqua='#3e999f'
blue='#4271ae'
purple='#8959a8'
pane='#efefef'
"

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
 run '~/.tmux/plugins/tpm/tpm'




