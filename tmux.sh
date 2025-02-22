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
set -g status-bg black
set -g status-fg white

set -g status-interval 1
set -g status-position top

set -g status-left '#[fg=colour40]🌿 #(cd #{pane_current_path}; git rev-parse --abbrev-ref HEAD)'
set -g status-left-length 50

set -g status-justify centre 

set -g status-right "#[fg=colour200]#(cat /sys/class/power_supply/BAT1/capacity)\%🔋 %a %b %d 🏀 %I:%M %p "


# set -g status-left "#{pane_current_path}"
# set -g status-left "#(ifconfig eth1 | grep 'inet' | awk 'NR==1 {print $2}')#[bg=yellow fg=yellow]#[bg=yellow fg=black,bold]#S #[bg=yellow fg=#000000]"












