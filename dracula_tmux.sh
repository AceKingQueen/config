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
setw -g mode-keys vi

# status bar
# set -g status-bg black
# set -g status-fg white

# set -g status-interval 1
# set -g status-position top

# set -g status-left '#[fg=colour40]🌿 #(cd #{pane_current_path}; git rev-parse --abbrev-ref HEAD)'
# set -g status-left-length 50

# set -g status-justify centre 

# set -g status-right "#[fg=colour200]#(cat /sys/class/power_supply/BAT1/capacity)\%🔋 %a %b %d 🏀 %I:%M %p "


# set -g status-left "#{pane_current_path}"
# set -g status-left "#(ifconfig eth1 | grep 'inet' | awk 'NR==1 {print $2}')#[bg=yellow fg=yellow]#[bg=yellow fg=black,bold]#S #[bg=yellow fg=#000000]"

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Other examples:
# set -g @plugin 'github_username/plugin_name'
# set -g @plugin 'github_username/plugin_name#branch'
# set -g @plugin 'git@github.com:user/plugin'
# set -g @plugin 'git@bitbucket.com:user/plugin'

set -g @plugin 'dracula/tmux'

set -g @dracula-plugins "ssh-session git battery playerctl time"
set -g @dracula-border-contrast true
set -g @dracula-show-empty-plugins false

set -g @dracula-show-powerline true

set -g @dracula-show-left-icon "🌊"

set -g @dracula-git-disable-status true
set -g @dracula-git-no-repo-message ""
set -g @dracula-git-show-remote-status true

# set -g @dracula-mpc-format "%title% - %artist%"
set -g @dracula-playerctl-format "►  {{ artist }} - {{ title }}"

set -g @dracula-network-wifi-label "🛜"

set -g @dracula-show-ssh-session-port true
set -g @dracula-show-ssh-only-when-connected true

set -g @dracula-show-location false

set -g @dracula-time-format "%a %b %d 🏀 %I:%M %p"

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




