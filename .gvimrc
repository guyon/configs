" Font: フォント設定 ====================================================== {{{1
if has('win32')
    " Windows用
    set guifont=MS_Gothic:h12:cSHIFTJIS
    " 行間隔の設定
    set linespace=1
    " 一部のUCS文字の幅を自動計測して決める
    if has('kaoriya')
        set ambiwidth=auto
    endif
    set noantialias
elseif has("gui_macvim")
    set gfn=Osaka-Mono:h14
    set gfw=Osaka-Mono:h14
    "set noantialias
elseif has("gui_mac")
    set gfn=Osaka-Mono:h14
    set gfw=Osaka-Mono:h14
    set noantialias
    "set macatsui
    "set transparency=10
    "set noantialias
elseif has('mac')
    set gfn=Osaka-Mono:h14
    set gfw=Osaka-Mono:h14
    set noantialias
    set gfn=Osaka-Mono:h14
    set gfw=Osaka-Mono:h14
    set guioptions+=aeT
elseif has('xfontset')
    " UNIX用 (xfontsetを使用)
    set guifontset=a14,r14,k14
endif

" Multibyte: マルチバイト入力設定 ========================================= {{{1
set iminsert=0 imsearch=0
if has('multi_byte_ime') || has('xim')
    " IME ON時のカーソルの色を設定(設定例:紫)
    highlight CursorIM guibg=Purple guifg=NONE
    " 挿入モード・検索モードでのデフォルトのIME状態設定
    set iminsert=0 imsearch=0
    if has('xim') && has('GUI_GTK')
        " XIMの入力開始キーを設定:
        " 下記の s-space はShift+Spaceの意味でkinput2+canna用設定
        "set imactivatekey=s-space
    endif
    " 挿入モードでのIME状態を記憶させない場合、次行のコメントを解除
    "inoremap <silent> <ESC> <ESC>:set iminsert=0<CR>
endif

" Window: ウインドウ設定 ================================================== {{{1
set columns=110           " ウインドウの幅
set lines=35              " ウインドウの高さ
if has('wrap!')
    set guioptions+=b
endif
if has('wrap')
    set guioptions-=b
endif

" Color: 色設定 =========================================================== {{{1

" 背景色の透過度
" set transparency=120
colorscheme desert
" We know xterm-debian is a color terminal
if &term =~ "xterm-debian" || &term =~ "xterm-xfree86" || &term =~ "xterm-256color"
    set t_Co=16
    set t_Sf=[3%dm
    set t_Sb=[4%dm
endif
if &term =~ "xterm-256color"
    "  colorscheme desert256
    colorscheme inkpot
endif
" 16色
set t_Co=16
set t_Sf=[3%dm
set t_Sb=[4%dm
" ポップアップ補完メニュー色設定
"（通常の項目、選択されている項目、スクロールバー、スクロールバーのつまみ部分）
highlight Pmenu ctermbg=3 guibg=#606060
highlight PmenuSel ctermbg=4 guibg=SlateBlue
highlight PmenuSbar ctermbg=2 guibg=#404040

" タブと全角スペース、行末のスペースに色を付ける
" TODO:listcharsの設定と調整する
highlight hiddenMark cterm=underline ctermfg=Gray guibg=grey30
match hiddenMark /\(\　\|\t\|\(\s\)\+$\)/

" 日本語入力時にカーソルの色を変更する設定
if has('multi_byte_ime')
    highlight CursorIM guibg=dodgerblue guifg=NONE
endif

" ckfix のエラー箇所を波線でハイライト
execute "highlight ucurl_my gui=undercurl guisp=Red"
let g:hier_highlight_group_qf  = "qf_error_ucurl"
execute "highlight qf_warning_ucurl gui=undercurl guisp=Blue"
let g:hier_highlight_group_qfw = "qf_warning_ucurl"
