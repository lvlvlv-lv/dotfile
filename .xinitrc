export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN:en_US

export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7890

if [ -f ~/.screenlayout/desktop-layout.sh ]; then
    . ~/.screenlayout/desktop-layout.sh
fi

. ~/.config/chadwm/scripts/run.sh
