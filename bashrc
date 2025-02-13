# git
alias gcmsg='git commit -m'
alias gst='git status'
alias gco='git checkout'
alias gp='git push'
alias glog='git log'

# vms
alias ssh="ssh hybridos@172.16.1.90"
alias sshvm2="powershell.exe; ssh hybridos@172.16.1.91"

# HybridOS
alias hos="cd ~/git/hybridos/web_apps/packages/hybridos"
alias kill3000="kill $(lsof -t -i :3000)"
alias kill3001="kill $(lsof -t -i :3001)"

alias webserver="hos; cd server"
alias runwebserver="webserver; kill3001; pnpm run start:dev"

alias webui="hos; cd ui"
alias runwebui="webui; kill3000; pnpm run start --host"

# show timestamp in terminal
export PROMPT_COMMAND="echo -n \[\$(date +%r)\]\ "

# show branch name in Ubuntu terminal
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\[\033[00m\] $ "
