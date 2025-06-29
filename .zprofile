#!/bin/zsh
# 在这里配置环境变量，直接打开Emacs.app可以感知到

# Setting PATH for Python 3.12
# The original version is saved in .zprofile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:${PATH}"
export PATH

# Setting PATH for Python 2.7
# The original version is saved in .zprofile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
export PATH

# proxy
function open_proxy() {
    export https_proxy=http://127.0.0.1:7890
    export http_proxy=http://127.0.0.1:7890
    export all_proxy=socks5://127.0.0.1:7890
}

function close_proxy() {
  unset http_proxy
  unset https_proxy
  unset all_proxy
}

function test_proxy() {
    echo $http_proxy
    echo $https_proxy
    echo $all_proxy
}
# open proxy when startup terminal
open_proxy

# install mypaint
PATH=$PATH:/Library/Frameworks/Python.framework/Versions/2.7/lib/mypaint/numpy
export PATH

# install openjdk@21
export JAVA_HOME=$HOME/OpenJDK/jdk-21.0.1.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH

# alias
alias emacs="emacs -nw"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
