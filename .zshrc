export PATH=/opt/local/bin:/opt/local/sbin:/usr/local/git/bin:$PATH
export MANPATH=/opt/local/man:$MANPATH

autoload -U compinit; compinit

zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                             /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin \
                             /usr/local/git/bin
#"エイリアス
alias -g V='| vim -R -'

# based by http://devel.aquahill.net/zsh/zshoptions

# 複数の zsh を同時に使う時など history ファイルに上書きせず追加する
setopt append_history

# 指定したコマンド名がなく、ディレクトリ名と一致した場合 cd する
setopt auto_cd

# 補完候補が複数ある時に、一覧表示する
setopt auto_list

# 補完キー（Tab, Ctrl+I) を連打するだけで順に補完候補を自動で補完する
setopt auto_menu

# カッコの対応などを自動的に補完する
setopt auto_param_keys

# ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt auto_param_slash

# 最後がディレクトリ名で終わっている場合末尾の / を自動的に取り除く
#setopt auto_remove_slash

# サスペンド中のプロセスと同じコマンド名を実行した場合はリジュームする
setopt auto_resume

# ビープ音を鳴らさないようにする
setopt NO_beep

# {a-c} を a b c に展開する機能を使えるようにする
setopt brace_ccl

# 内部コマンドの echo を BSD 互換にする
#setopt bsd_echo

# シンボリックリンクは実体を追うようになる
#setopt chase_links

# 既存のファイルを上書きしないようにする
#setopt clobber

# コマンドのスペルチェックをする
setopt correct

# コマンドライン全てのスペルチェックをする
#setopt correct_all

# =command を command のパス名に展開する
setopt equals

# ファイル名で #, ~, ^ の 3 文字を正規表現として扱う
setopt extended_glob

# zsh の開始・終了時刻をヒストリファイルに書き込む
#setopt extended_history

# Ctrl+S/Ctrl+Q によるフロー制御を使わないようにする
setopt NO_flow_control

# 各コマンドが実行されるときにパスをハッシュに入れる
#setopt hash_cmds

# 直前と同じコマンドラインはヒストリに追加しない
setopt hist_ignore_dups

# コマンドラインの先頭がスペースで始まる場合ヒストリに追加しない
setopt hist_ignore_space

# ヒストリを呼び出してから実行する間に一旦編集できる状態になる
setopt hist_verify

# シェルが終了しても裏ジョブに HUP シグナルを送らないようにする
setopt NO_hup

# Ctrl+D では終了しないようになる（exit, logout などを使う）
setopt ignore_eof

# コマンドラインでも # 以降をコメントと見なす
setopt interactive_comments

# auto_list の補完候補一覧で、ls -F のようにファイルの種別をマーク表示
setopt list_types

# 内部コマンド jobs の出力をデフォルトで jobs -l にする
setopt long_list_jobs

# コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt magic_equal_subst

# メールスプール $MAIL が読まれていたらワーニングを表示する
#setopt mail_warning

# ファイル名の展開でディレクトリにマッチした場合末尾に / を付加する
setopt mark_dirs

# 補完候補が複数ある時、一覧表示 (auto_list) せず、すぐに最初の候補を補完する
#setopt menu_complete

# 複数のリダイレクトやパイプなど、必要に応じて tee や cat の機能が使われる
setopt multios

# ファイル名の展開で、辞書順ではなく数値的にソートされるようになる
setopt numeric_glob_sort

# コマンド名に / が含まれているとき PATH 中のサブディレクトリを探す
#setopt path_dirs

# 8 ビット目を通すようになり、日本語のファイル名などを見れるようになる
setopt print_eightbit

# 8ビット目を通し、日本語のファイル名を表示 
#setopt print_eight_bit

# 戻り値が 0 以外の場合終了コードを表示する
#setopt print_exit_value

# ディレクトリスタックに同じディレクトリを追加しないようになる
#setopt pushd_ignore_dups

# pushd を引数なしで実行した場合 pushd $HOME と見なされる
#setopt pushd_to_home

# rm * などの際、本当に全てのファイルを消して良いかの確認しないようになる
#setopt rm_star_silent

# rm_star_silent の逆で、10 秒間反応しなくなり、頭を冷ます時間が与えられる
#setopt rm_star_wait

# for, repeat, select, if, function などで簡略文法が使えるようになる
setopt short_loops

# デフォルトの複数行コマンドライン編集ではなく、１行編集モードになる
#setopt single_line_zle

# コマンドラインがどのように展開され実行されたかを表示するようになる
#setopt xtrace

# 色を使う
setopt prompt_subst

# シェルのプロセスごとに履歴を共有
setopt share_history

# history (fc -l) コマンドをヒストリリストから取り除く。
setopt hist_no_store

# 文字列末尾に改行コードが無い場合でも表示する
unsetopt promptcr

#コピペの時rpromptを非表示する
setopt transient_rprompt

# cd -[tab] でpushd
setopt autopushd

# ------------ 以下浅野追加
# ディレクトリを水色にする｡ 
export LS_COLORS='di=01;34'
# ファイルリスト補完でもlsと同様に色をつける｡ 
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} 

#local BLACK=$'%{?e[1;30m%}' 
#local RED=$'%{?e[1;31m%}' 
#local GREEN=$'%{?e[1;32m%}' 
#local YELLOW=$'%{?e[1;33m%}' 
#local BLUE=$'%{?e[1;34m%}' 
#local PURPLE=$'%{?e[1;35m%}' 
#local LIGHTBLUE=$'%{?e[1;36m%}' 
#local WHITE=$'%{?e[1;37m%}' 
#local DEFAULT_COLOR=$'%{?e[1;m%}' 
#local TODAY_COLOR=$'%{?e[1;3%D{%w}m%}' 

# プロンプトの表示の調整

#PROMPT='%n@%m%(!.#.$) '
#PROMPT=$'[%n@%m %2~%{\ek\e\\%}]$ '

# この３行が超お勧め。コンソール右側に表示され、入力カーソルにかぶると自動的に消える。
PROMPT='['%(!.$RED.$GREEN)'${USER}$PURPLE@$DEFAULT_COLOR${HOST}]%(!.#.$) ' 
PROMPT2='[ >' 
# 曜日つき
#RPROMPT='['$LIGHTBLUE'%~ %(!.$RED.$GREEN)%D{%Y/%m/%d}$DEFAULT_COLOR($TODAY_COLOR%D{%a}$DEFAULT_COLOR)%*'$DEFAULT_COLOR']' 
# 曜日なし
RPROMPT='['$LIGHTBLUE'%~ %(!.$RED.$GREEN)%D{%Y/%m/%d %H:%M:%S}'$DEFAULT_COLOR']' 
RPROMPT2='< %*]' 

if [ "$TERM" = "screen" ]; then
  PROMPT='['%(!.$RED.$GREEN)'${USER}$PURPLE@$DEFAULT_COLOR${HOST}]%(!.#.$) ' 
  PROMPT2='[ >' 
  # 曜日つき
  #RPROMPT='['$LIGHTBLUE'%~ %(!.$RED.$GREEN)%D{%Y/%m/%d}$DEFAULT_COLOR($TODAY_COLOR%D{%a}$DEFAULT_COLOR)%*'$DEFAULT_COLOR']' 
  # 曜日なし
  RPROMPT='['$LIGHTBLUE'%~ %(!.$RED.$GREEN)%D{%Y/%m/%d %H:%M:%S}'$DEFAULT_COLOR']' 
  #RPROMPT='['$LIGHTBLUE'%~ %(!.$RED.$GREEN)%D{%Y/%m/%d}$DEFAULT_COLOR($TODAY_COLOR%D{%a}$DEFAULT_COLOR)%*'$DEFAULT_COLOR']' 
  RPROMPT2='< %*]' 
  PROMPT=$'[%n@%m %2~%{\ek\e\\%}%{fugitive#statusline()}]$ '
fi

# HISTORYファイルの設定
HISTFILE=$HOME/.zsh_history 
HISTSIZE=9999999
SAVEHIST=9999999

setopt histallowclobber # ">" を ">!" としてヒストリ保存
setopt rm_star_silent # "rm * " を実行する前に確認 

# Ctrl+wで､直前の/までを削除する｡ 
#WORDCHARS='*?_-.[]~=&;!#$%^(){}<>' 

# 最近移動したディレクトリのリストを表示し、番号選択で移動する。
alias gd='dirs -v; echo -n "select number: "; read newdir; cd -"$newdir"' 

alias -g G='| grep ' 
alias -g M='| more ' 

alias ls='ls -FGv' 
alias ll='ls -l' 
alias la='ls -a' 
alias rm='rm -i' 
alias o='open' 

#参考
#http://mazgi.blog32.fc2.com/

[ -f /Applications/MacVim.app/Contents/MacOS/vim ] && alias vim='/Applications/MacVim.app/Contents/MacOS/vim'

# gem補完
alias gem-update-list="gem list -r 2> /dev/null | grep '^[a-zA-Z]' | awk '{print \$1}' > $HOME/.gemlist"
_gem () {
    LIMIT=`date -d "1 week ago" +%s`
    if ! [[ ( -f $HOME/.gemlist ) && ( `date -r "$HOME/.gemlist" +%s` -gt $LIMIT ) ]]; then
        gem-update-list
    fi
    reply=(`cat $HOME/.gemlist`)
}
compctl -k "(`gem help commands | grep '^    \w.*' | sed 's/^\s*//' | sed 's/\s\s*.*//'`)" -x 'c[-1,-t]' - 'C[-1,(install)]' -K _gem -- gem

#-----------------------------------------------------------------
## ローカル設定の読み込み
##-----------------------------------------------------------------
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
