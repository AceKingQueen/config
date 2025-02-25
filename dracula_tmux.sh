# rename prefix key
set -g prefix C-s

# reload config file (change file location to your the tmux.conf you want to use)
unbind r
bind r source-file ~/.tmux.conf \; display "Reloaded!"

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

set -g @dracula-plugins "ssh-session git battery playerctl time"
set -g @dracula-border-contrast true
set -g @dracula-show-empty-plugins false

set -g @dracula-show-powerline true

set -g @dracula-show-left-icon "≡ƒîè"

set -g @dracula-git-disable-status true
set -g @dracula-git-no-repo-message ""
set -g @dracula-git-show-remote-status true

# set -g @dracula-mpc-format "%title% - %artist%"
set -g @dracula-playerctl-format "Γû║  {{ artist }} - {{ title }}"

set -g @dracula-network-wifi-label "≡ƒ¢£"

set -g @dracula-show-ssh-session-port true
set -g @dracula-show-ssh-only-when-connected true

set -g @dracula-show-location false

set -g @dracula-time-format "%a %b %d ≡ƒÅÇ %I:%M %p"

# simple tomorrow night color palette
set -g @dracula-colors "
pink='#D33682'
orange='#de935f'
yellow='#B58900'
green='#859900'
cyan='#2AA198'
blue='268BD2'
light_purple='#b294ba'
white='#EEE8D5'
dark_gray='#363a41'
red='#D92B2B'
gray='#839496'
dark_purple='#373b41'
"

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
 run '~/.tmux/plugins/tpm/tpm'

                                                                                                                                                                                             101,21        94%
                                                                                                                                         31,38         Top