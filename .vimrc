" Path: パス設定 ====================================================== {{{1
" Windowsでも.vimをRumtimeディレクトリにする
set runtimepath+=$HOME/.vim
" hatena.vimを使う
"set runtimepath+=$HOME/.vim/hatena
"ヘルプファイルをパスを指定する
helptags $HOME/.vim/doc/

" Encodings: 文字コード設定 =========================================== {{{1
" from ずんWiki http://www.kawaz.jp/pukiwiki/?vim#content_1_7
if &encoding !=# 'utf-8'
	set encoding=japan
endif

"set fileencoding=japan
if has('iconv')
	let s:enc_euc = 'euc-jp'
	let s:enc_jis = 'iso-2022-jp'
	" iconvがJISX0213に対応しているかをチェック
	if iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
		let s:enc_euc = 'euc-jisx0213'
		let s:enc_jis = 'iso-2022-jp-3'
	endif
	" fileencodingsを構築
	if &encoding ==# 'utf-8'
		let s:fileencodings_default = &fileencodings
		let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
		let &fileencodings = &fileencodings .','. s:fileencodings_default
		unlet s:fileencodings_default
	else
		let &fileencodings = &fileencodings .','. s:enc_jis
		set fileencodings+=utf-8,ucs-2le,ucs-2
		if &encoding =~# '^euc-\%(jp\|jisx0213\)$'
			set fileencodings+=cp932
			set fileencodings-=euc-jp
			set fileencodings-=euc-jisx0213
			let &encoding = s:enc_euc
		else
			let &fileencodings = &fileencodings .','. s:enc_euc
		endif
	endif
	" 定数を処分
	unlet s:enc_euc
	unlet s:enc_jis
endif

" Mouse: マウス設定 =================================================== {{{1
" どのモードでもマウスを使えるようにする
set mouse=a
" マウスの移動でフォーカスを自動的に切替えない (mousefocus:切替る)
set nomousefocus
" 入力時にマウスポインタを隠す (nomousehide:隠さない)
set mousehide
" ビジュアル選択(D&D他)を自動的にクリップボードへ (:help guioptions_a)
"set guioptions+=a

" Command: コマンド設定  ============================================== {{{1
"
"best_of_tipsを開く
command! Btips1 :silent e $HOME/.vim/doc/best_tips1.txt
command! Btips2 :silent e $HOME/.vim/doc/best_tips2.txt

" listcharsを切り替える
command! ListCharsDispFull set listchars=tab:^-,eol:$,trail:_,nbsp:% list
command! ListCharsDispTab set listchars=tab:^- list
command! ListCharsDispEol set listchars=eol:$ list

" カレントディレクトリに移動
command! -bar CD execute 'lcd' expand('%:p:h')
" .gitのあるディレクトリに移動
command! -bar CDGit call CdDotGitDir()

" Autocmd: autocmd設定 ================================================ {{{1
if has("autocmd")
    filetype plugin on
    "ファイルタイプにあわせたインデントを利用する
    filetype indent on
    " これらのftではインデントを無効に
    autocmd FileType html :setlocal indentexpr=
    autocmd FileType xhtml :setlocal indentexpr=

    " autocomplpop.vim --------------------------------------------------------
    "コマンドラインウインドウの中はAutoComplPopを停止する
    autocmd CmdwinEnter * AutoComplPopDisable
    autocmd CmdwinLeave * AutoComplPopEnable

    " rubycomplete.vim --------------------------------------------------------
    autocmd FileType ruby,eruby setlocal omnifunc=rubycomplete#Complete
    autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
    autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
    autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1

    " PHPの辞書補完とomni補完 -----------------------------------------------------------
    autocmd FileType php setlocal omnifunc=phpcomplete#CompletePHP
    autocmd FileType php :setlocal dictionary+=~/.vim/dict/php5_functions.dict

    " svnの時は文字コードをutf8設定 -----------------------------------
    autocmd FileType svn :setlocal fileencoding=utf-8

    " changelog ---------------------------------------------------------------
    autocmd BufNewFile,BufRead *.changelog setf changelog

    " rails -------------------------------------------------------------------
    autocmd BufNewFile,BufRead app/**/*.rhtml set fenc=utf-8
    autocmd BufNewFile,BufRead app/**/*.rb set fenc=utf-8
    autocmd FileType ruby :source $HOME/.vim/ftplugin/ruby-matchit.vim

    " freemaker(Javaテンプレートエンジン) -------------------------------------
    autocmd BufNewFile,BufRead *.ftl setf ftl

    " git.vim コミット後ログを表示する ----------------------------------------
    "autocmd BufWritePost COMMIT_EDITMSG exe ":bd" | exe ":Cd" | exe ":GitLog"

    " 前回終了したカーソル行に移動 --------------------------------------------
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif
endif

" Options: オプション設定 ============================================= {{{1
syntax on
set ambiwidth=double                     " UTF-8で文字幅表示を２文字分使う
set completeopt=menuone,preview
set complete+=k                          " 辞書ファイルからの単語補間
set nrformats=""                         " 8進数はインクリメントしない
set expandtab                            " タブを展開
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smartindent                          " インデントはスマートインデント
set ignorecase                           " 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set smartcase                            " 検索文字列に大文字が含まれている場合は区別して検索する
set wrapscan                             " 検索時に最後まで行ったら最初に戻る
set noincsearch                          " 検索文字列入力時に順次対象文字列にヒットさせない
set nolist                               " タブの左側にカーソル表示
set showcmd                              " 入力中のコマンドをステータスに表示する
set showmatch                            " 括弧入力時の対応する括弧を表示
set nohlsearch                           " 検索結果文字列のハイライトを有効にしない
set nu                                   " 行番号を表示する
set nobackup                             " バックアップファイルは作らない
set wildmenu                             " コマンドライン補完するときに強化されたものを使う
set wildmode=list:longest                " コマンドライン補間をシェルっぽく
set hidden                               " バッファが編集中でもその他のファイルを開けるように
set autoread                             " 外部のエディタで編集中のファイルが変更されたら自動で読み直す
set wrap                                 " 自動折り返し
set laststatus=2                         " 常にステータス行を表示 (詳細は:he laststatus)
set cmdheight=2                          " コマンドラインの高さ (Windows用gvim使用時はgvimrcを編集すること)
set title                                " タイトルを表示
set lazyredraw                           " マクロなど実行中は描画を中断
set foldmethod=marker                    " 折畳み
"set cursorline                          " カーソル行を強調表示
"hi CursorLine gui=underline             " 下線
set viminfo='50,<1000,s100,\"50          " viminfoの上限数など
set backspace=indent,eol,start           " バックスペースを強化する設定
set textwidth=0                          " Don't wrap words by default
set history=100                          " コマンド履歴数
set ruler                                " show the cursor position all the time
set guioptions-=T                        "ツールバーを表示しない
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
if has('migemo')
    set migemo            " Migemo用検索
endif

"ステータスラインに文字コードと改行文字を表示する（ウインドウ幅によって表示項目を調整）
if winwidth(0) >= 120
    set statusline=%<[%n]%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}%y\ %(%{GitBranch()}\ %)\ %F%=[%{GetB()}]\ %l,%c%V%8P
else
    set statusline=%<[%n]%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}%y\ %(%{GitBranch()}\ %)\ %F%=[%{GetB()}]\ %l,%c%V%8P
endif

" prg設定
set grepprg="grep"


" }}}1
" Mapping: マッピング設定 ============================================= {{{1

" Macの場合にLeader設定
if has('mac') && has('gui_running')
   let mapleader = "\\"
endif

"noremap <C-Space> <Esc>
"cnoremap <C-Space> <Esc>
"inoremap <C-Space> <Esc>

" command mode 時 Emacs風のキーバインドに
cnoremap <C-B> <Left>
cnoremap <C-F> <Right>
cnoremap <C-A> <Home>
cnoremap <C-E> <END>
cnoremap <C-K> <Up>
cnoremap <C-J> <Down>
cnoremap <C-H> <BS>
" カーソル位置にかかわらず全部消す
cnoremap <C-u> <C-e><C-u>

inoremap <C-B> <Left>
inoremap <C-F> <Right>
inoremap <C-K> <UP>
inoremap <C-J> <DOWN>
inoremap <C-H> <BS>

" そのコマンドを実行
nnoremap ,e :execute '!' &ft ' %'<CR>

"インデントを考慮して貼り付け
"nnoremap p p=']

"表示行単位で行移動する
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

"単語の移動
noremap E e
noremap W w
noremap B b

" 標準の単語選択
vnoremap <space>iw iw
vnoremap <space>ie ie

" 選択時にペーストしたときに最後のレジスタを上書きする
vnoremap <silent> p p:call SelectPasteTextOverWriteRegister()<cr>

" マウス操作でスクロールした時に誤操作で意図しないペーストをしない
noremap <MiddleMouse> <Nop>
inoremap <MiddleMouse> <Nop>

"クリップボードを使ったコピペ
vnoremap <M-c> "+y
inoremap <M-v> <MiddleMouse>
nnoremap <M-v> i<MiddleMouse><esc>

" 全て選択
nnoremap <space>V ggVG
" 改行を含まない1行選択
nnoremap <space>v 0v$h

"rubyのメソッドやクラスをまとめて選択する(b:block用、m:def用、c:class用、M:module用)
nnoremap vab 0/end<CR>%Vn
nnoremap vib 0/end<CR>%kVnj
nnoremap vam $?\%(.*#.*def\)\@!def<CR>%Vn
nnoremap vim $?\%(.*#.*def\)\@!def<CR>%kVnj
nnoremap vac $?\%(.*#.*class\)\@!class<CR>%Vn
nnoremap vic $?\%(.*#.*class\)\@!class<CR>%kVnj
nnoremap vaM $?\%(.*#.*module\)\@!module<CR>%Vn
nnoremap viM $?\%(.*#.*module\)\@!module<CR>%kVnj

".vimrcの再読み込み
nnoremap ,vr :source $HOME/.vimrc<CR>:source $HOME/.gvimrc<CR>

" YankRingっぽいレジスタ履歴Yank&Paste
vnoremap <silent> y <ESC>:call NumberedRegisterRotation()<CR>gvy
vnoremap <silent> x <ESC>:call NumberedRegisterRotation()<CR>gvx
vnoremap <silent> d <ESC>:call NumberedRegisterRotation()<CR>gvd
nnoremap <silent> yy :call NumberedRegisterRotation()<CR>yy
nnoremap <silent> dd :call NumberedRegisterRotation()<CR>dd
inoremap <C-Space><C-n> <C-R>=RegistersComplete()<CR>
nnoremap <C-Space><C-n> i<C-R>=RegistersComplete()<CR>

" 設定をトグルする {{{2
nnoremap <silent> <space>tw :set wrap!<CR>
" }}}2

" 設定を有効にする {{{2
nnoremap <silent> <space>ea :AutoComplPopEnable<CR>
" }}}2

" 設定を無効にする {{{2
nnoremap <silent> <space>da :AutoComplPopDisable<CR>
" }}}2

" 検索時に画面中央にくるようにする
" nzzを割り当てるとfold時の検索でnを押して次に進んだ場合に自動展開されない
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap * *zzzv
nnoremap # #zzzv
nnoremap g* g*zzzv
nnoremap g# g#zzzv

" 選択中の文字を検索する
"vnoremap <silent> n :call SelSearch()<CR>
vnoremap <silent> n :call SearchTheSelectedTextLiteraly()<CR>

" 選択中の文字をURLエスケープする（1:エンコード 2:デコード）
vnoremap <silent> <space>ue :call UrlEscapeTheSelectedTextLiteraly(1)<CR>
vnoremap <silent> <space>ud :call UrlEscapeTheSelectedTextLiteraly(2)<CR>

" migemo検索用(incsearchの設定を行う)
nnoremap g/ :set incsearch<CR>g/
nnoremap g? :set incsearch<CR>g?
" perl系正規表現検索用(/でLL系正規表現が使えるようにする。※eregex.vimを使う）
nnoremap / :set noincsearch<CR>:M/
" vim正規表現検索用(元のデフォルトの/検索は）
nnoremap ,/ :set noincsearch<CR>/
nnoremap ?  :set noincsearch<CR>?

" textobj-datetimeの設定
silent! call textobj#datetime#default_mappings(1)

"ScreenのキーバインドでC-Tを割り当てているため、タグジャンプの戻るはc-[に割り当てる。
nnoremap <M-]> :pop<CR>
" tags key map (C-z を C-tに,C-tはGNU/screenとかぶる)
noremap <C-z> <C-t>

" 選択中のCSVカラム名の列をハイライト表示する
vnoremap <silent> ,hc :call SelectCsvH()<CR>

if has("win32")
    " 画面の最大化と元のサイズをキーに割り当て
    noremap <silent> <F2> :simalt ~x<CR>
    noremap <silent> <F3> :simalt ~r<CR>
    "文字の大きさ変更キーマップ
    noremap _w :simalt ~r<CR>:set guifont=MS_Gothic:h12:cSHIFTJIS<CR>:set columns=110<CR>:set lines=30<CR>
    noremap _1 :simalt ~r<CR>:set columns=110 lines=30<CR>
    noremap _2 :simalt ~x<CR>:let &guifont=substitute(&guifont, ":h\\d\\+:", ":h16:", "")<CR>
    noremap _3 :simalt ~x<CR>:let &guifont=substitute(&guifont, ":h\\d\\+:", ":h18:", "")<CR>
    noremap _4 :simalt ~x<CR>:let &guifont=substitute(&guifont, ":h\\d\\+:", ":h20:", "")<CR>
    noremap _5 :simalt ~x<CR>:let &guifont=substitute(&guifont, ":h\\d\\+:", ":h24:", "")<CR>
    noremap _6 :simalt ~x<CR>:let &guifont=substitute(&guifont, ":h\\d\\+:", ":h32:", "")<CR>
    noremap _7 :simalt ~x<CR>:let &guifont=substitute(&guifont, ":h\\d\\+:", ":h48:", "")<CR>
endif

" 異なるプロセスvim間でコピー（yanktmp.vim用）
noremap <silent> sy :call YanktmpYank()<CR>
noremap <silent> sp :call YanktmpPaste_p()<CR>
noremap <silent> sP :call YanktmpPaste_P()<CR>

" 水平スクロール
nnoremap <C-l> zl
nnoremap <C-h> zh

"FuzzyFinder時にCtrl-Dで一行消しできるように
inoremap <silent> <c-d> \<c-r>=repeat('', setline('.', ''))<cr>

" phpdocumenter.php
nnoremap <space>ppd :call PhpDocSingle()<CR>
vnoremap <space>ppd :call PhpDocRange()<CR>

" Plugin: プラグイン設定 ============================================== {{{1

" Vimball 
if has('win32')
    let g:vimball_home = "C:/configs/.vim/"
else
    let g:vimball_home = "~/configs/.vim/"
endif

" QuickFix
noremap mm <Plug>QuickFixNote
noremap <silent> <F9> :copen<CR>
noremap ms <Plug>QuickFixSave

" Gauche
autocmd FileType scheme :let is_gauche=1
autocmd FileType scheme :setlocal dictionary+=~/.vim/dict/gosh_completions.dict

" git.vim ----------------------------------------------------- {{{2
nnoremap <Space>gs  :CD \| GitStatus<CR>
nnoremap <Space>ga  :CD \| GitAdd
nnoremap <Space>gac :CD \| GitAdd <C-r>=expand("%:t")<CR><CR>
nnoremap <Space>gd  :CD \| GitDiff 
nnoremap <Space>gc  :CDGit \| GitCommit<CR>
nnoremap <Space>gcs :CDGit \| GitCommit 
nnoremap <Space>gca :CDGit \| GitCommit -a<CR>
nnoremap <Space>gcc :CDGit \| GitCommit <C-r>=expand("%:t")<CR><CR>
nnoremap <Space>gl  :CD \| GitLog<CR>
nnoremap <Space>gs  :CD \| GitStatus<CR>
" ":CD<CR> :GitStatus<CR>"では<Space> (:help <Space>)が実行されてしまう。
"nnoremap <space>gs  :CD<CR> :GitStatus<CR>

" }}}2
" project.vim ------------------------------------------------------------- {{{2
let g:proj_window_width = 32
 
" CamelCase Motion -------------------------------------------------------- {{{2

" Replace the default 'w', 'b' and 'e' mappings instead of defining
nmap <silent> w <Plug>CamelCaseMotion_w
nmap <silent> b <Plug>CamelCaseMotion_b
nmap <silent> e <Plug>CamelCaseMotion_e

" Replace default 'iw' text-object and define 'ie' and 'ib' motions: 
omap <silent> iw <Plug>CamelCaseMotion_iw
vmap <silent> iw <Plug>CamelCaseMotion_iw
omap <silent> ib <Plug>CamelCaseMotion_ib
vmap <silent> ib <Plug>CamelCaseMotion_ib
omap <silent> ie <Plug>CamelCaseMotion_ie
vmap <silent> ie <Plug>CamelCaseMotion_ie
" sqlUtil ----------------------------------------------------------------- {{{2
let g:sqlutil_align_where = 1
let g:sqlutil_align_comma = 1

" SourceExplorer ---------------------------------------------------------- {{{2
"自動でプレビューを表示する。TODOうざくなってきたら手動にする。またはソースを追う時だけ自動に変更する
let g:SrcExpl_RefreshTime   = 1
"プレビューウインドウの高さ
let g:SrcExpl_WinHeight     = 9
"tagsは自動で作成する
let g:SrcExpl_UpdateTags    = 1
let g:SrcExpl_RefreshMapKey = "<Space>"
let g:SrcExpl_GoBackMapKey  = "<C-b>"
nnoremap <F8> :SrcExplToggle<CR>
let g:SrcExpl_pluginList = [
         \ "__Tag_List__",
         \ "_NERD_tree_",
         \ "Source_Explorer"
     \ ]

"FuzzyFinder用 ----------------------------------------------------------- {{{2
nnoremap <silent> <space>fb :FuzzyFinderBuffer<CR>
nnoremap <silent> <space>fc :FuzzyFinderMruCmd<CR>
nnoremap <silent> <space>fd :FuzzyFinderDir<CR>
nnoremap <silent> <space>ff :FuzzyFinderFile<CR>
nnoremap <silent> <space>fm :FuzzyFinderMruFile<CR>
nnoremap <silent> <space>fv :FuzzyFinderBookmark<CR>
nnoremap <silent> <space>ft :FuzzyFinderTag<CR>

let g:FuzzyFinderOptions = { 'Base':{}, 'Buffer':{}, 'File':{}, 'Dir':{}, 'MruFile':{}, 'MruCmd':{}, 'Bookmark':{}, 'Tag':{}, 'TaggedFile':{}}
let g:FuzzyFinderOptions.Base.key_open_split  = '<C-s>'
let g:FuzzyFinderOptions.Base.key_open_vsplit = '<C-v>'
let g:FuzzyFinderOptions.Base.key_open_tab    = '<C-]>'
let g:FuzzyFinderOptions.Base.key_next_mode   = '<C-j>'
let g:FuzzyFinderOptions.Base.key_prev_mode   = '<C-k>'
let g:FuzzyFinderOptions.Base.key_ignore_case = '<C-t>'
let g:FuzzyFinder_IgnoreCase = 1
" 描画の抑制で速度UP 表示されていなくてもFuzzyFinderの対象にはなる
let g:FuzzyFinderOptions.Base.enumerating_limit = 25
if has('migemo')
    let g:FuzzyFinderOptions.Base.migemo_support = 1
endif
let g:FuzzyFinderOptions.File.excluded_path = '\v\~$|\.git\\|\.git\/|\.svn|\.o$|\.class$|\.exe$|\.bak$|\.back$|\.swo$|\.swp$|((^|[/\\])\.[/\\]$)'
if has('win32')
    let g:FuzzyFinderOptions.File.abbrev_map = {
          \   ":c/" : [
          \     "/configs/",
          \   ],
          \   ":p/" : [
          \     "~/.private/",
          \   ],
          \ }
else
    let g:FuzzyFinderOptions.File.abbrev_map = {
          \   ":c/" : [
          \     "~/configs/",
          \   ],
          \   ":p/" : [
          \     "~/.private/",
          \   ],
          \ }
endif

"ku.vim用 ------------------------------------------- {{{2
nnoremap <Space>kb  :<C-u>Ku buffer<Return>
nnoremap <Space>kf  :<C-u>Ku file<Return>
nnoremap <Space>kh  :<C-u>Ku history<Return>
call ku#custom_prefix('common', '~', $HOME)

if has('win32')
    call ku#custom_prefix('common', ':c', 'C:\configs')
    call ku#custom_prefix('common', ':p', $HOME . '/.private')
else
    call ku#custom_prefix('common', ':c', $HOME . '/configs')
    call ku#custom_prefix('common', ':p', $HOME . '/.private')
endif

"speeddating.vim用のマッピング ------------------------------------------- {{{2
" システム日付を挿入する
inoremap <leader>dF  <C-r>=strftime('%Y-%m-%dT%H:%M:%S+09:00')<Return>
inoremap <leader>df  <C-r>=strftime('%Y-%m-%dT%H:%M:%S')<Return>
inoremap <leader>dd  <C-r>=strftime('%Y-%m-%d')<Return>
inoremap <leader>dT  <C-r>=strftime('%H:%M:%S')<Return>
inoremap <leader>dt  <C-r>=strftime('%H:%M')<Return>

" calender.vim ------------------------------------------------------------ {{{2
"let g:calendar_erafmt = '平成,-1988'
"let g:calendar_mruler ='1月,2月,3月,4月,5月,6月,7月,8月,9月,10月,11月,12月'
"let g:calendar_wruler = '日 月 火 水 木 金 土 日'

" NERD_comments.vim ------------------------------------------------------- {{{2
" コメントの間にスペースを空ける
let NERDSpaceDelims = 1
" 対応していないファイルに対して警告をしない
let NERDShutUp = 1

" netrw ------------------------------------------------------------------- {{{2
let g:netrw_ftp_cmd="netkit-ftp"  " netrw-ftp
let g:netrw_http_cmd="wget -q -O" " netrw-http

" surround.vim ------------------------------------------------------------ {{{2
"surroundに定義を追加する【ASCIIコードを調べるには:echo char2nr("-")】
"タグ系
let g:surround_{char2nr('!')} = "<!-- \r -->"
let g:surround_{char2nr('%')} = "<% \r %>"
let g:surround_{char2nr('-')} = "<!-- \r -->"
"変数展開系
let g:surround_{char2nr('#')} = "#{\r}"
let g:surround_{char2nr('$')} = "${\r}"
let g:surround_{char2nr('@')} = "@{\r}"

" tabbar.vim -------------------------------------------------------------- {{{2
let g:Tb_MaxSize=3
" }}}2
" scratch.vim  ------------------------------------------------------------ {{{2
let g:scratch_buffer_name = "Scratch"
" }}}2
" Color: 色設定 ======================================================= {{{1
" 特定の文字を視覚化。この例では全角スペース
" TODO:listcharsの設定と調整する
"highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=white
"match ZenkakuSpace /　/
if !has('gui_running')
    set background=dark
    highlight Folded ctermfg=yellow ctermbg=black 
    highlight FoldColumn ctermfg=yellow ctermbg=black 
    highlight Pmenu ctermfg=white ctermbg=darkgray  guibg=#606060
    highlight PmenuSel ctermbg=darkred guibg=SlateBlue
    highlight PmenuSbar ctermbg=darkblue guibg=#404040
endif

" Tags: tags設定 ====================================================== {{{1
if has("autochdir")
	set autochdir
	set tags=tags;
else
	"set tags=$HOME/.vim/tags,./tags,./../tags,./*/tags,./../../tags,./../../../tags,./../../../../tags,./../../../../../tags
	set tags+=./tags
endif
command! -nargs=? Ctags call <SID>Ctags(<q-args>)

" Function: 関数定義 ================================================== {{{1
" ----------------------------------------------------------------------------
" 関数
" ----------------------------------------------------------------------------
"--------------------------------------------------------
" ステータスライン表示に使用する関数群
" -------------------------------------------------------
function! GetB()
    let c = matchstr(getline('.'), '.', col('.') - 1)
    let c = iconv(c, &enc, &fenc)
    return String2Hex(c)
endfunction
function! Nr2Hex(nr)
    let n = a:nr
    let r = ""
    while n
        let r = '0123456789ABCDEF'[n % 16] . r
        let n = n / 16
    endwhile
    return r
endfunc
function! String2Hex(str)
    let out = ''
    let ix = 0
    while ix < strlen(a:str)
        let out = out . Nr2Hex(char2nr(a:str[ix]))
        let ix = ix + 1
    endwhile
    return out
endfunc

"-------------------------------------------------------------------
"Screenのステータスラインに編集中のファイルを表示し、
" 終了時にはShellと表示する。※^[ はctrl + v を押しながら [
"-------------------------------------------------------------------
function! SetScreenTabName(name)
    let arg = 'k' . a:name . ' > vim \\'
    silent! exe '!echo -n "' . arg . "\""
endfunction

"-------------------------------------------------------------------
"　自動補完をタブで選択できるように(cho45さんから)
" http://subtech.g.hatena.ne.jp/cho45/20071009#c1191925480
"-------------------------------------------------------------------
"function! InsertTabWrapper() 
"	let col = col('.') - 1 
"	if !col || getline('.')[col - 1] !~ '\k' 
"		return "\<TAB>"
"	else
"		if pumvisible()
"			return "\<C-N>"
"		else
"			return "\<C-N>\<C-P>"
"		end
"	endif
"endfunction
"" インサート時のTabキーマッピングをInsertTabWrapperで書き換える
"inoremap <silent> <tab> <c-r>=InsertTabWrapper()<cr>

"------------------------------------------------
" CSVのハイライト表示
" @see http://www.vim.org/tips/tip.php?tip_id=667
"------------------------------------------------
" csv の特定のカラムをハイライト (put in .vimrc)
" :Csv 5   # 5番めのカラムをハイライト
function! CSVH(x)
    execute 'match Keyword /^\([^,]*,\)\{'.a:x.'}\zs[^,]*/'
    execute 'normal ^'.a:x.'f,'
endfunction
command! -nargs=1 Csv :call CSVH(<args>)

"-----------------------------
" カラム名からIndex値を取得する
"-----------------------------
function! CsvCol2Index(colName)
ruby << EOF
    colName = VIM::evaluate("a:colName")
    columns = eval("[#{VIM::Buffer.current.line}]")
    colIndex = columns.index(colName) || -1
    VIM::command("return '#{colIndex.to_s#}'")
EOF
endfunction


"------------------------------------------------
"選択中のCSVカラムをハイライトする
"------------------------------------------------
function! SelectCsvH()
    "最後のヤンクを保管しておく
    let tmp = @"
    "現在選択中のテキストを取得する
    normal! gv"ty
    "取得した結果を変数に格納する
    let seltext=@t
    let columnNumber = CsvCol2Index(seltext)
    if columnNumber >= 0
        let result = CSVH(columnNumber)
    else
        echo "対象のカラムは存在しません"
    endif
    "最後のヤンクを書き戻す
    let @" = tmp
    let @/ = seltext
endfunction

"-----------------------------
" html escape function
"-----------------------------
function! HtmlEscape()
    silent s/&/\&amp;/eg
    silent s/</\&lt;/eg
    silent s/>/\&gt;/eg
endfunction
function! HtmlUnEscape()
    silent s/&lt;/</eg
    silent s/&gt;/>/eg
    silent s/&amp;/\&/eg
endfunction

"------------------------------------------------
"選択中の文字列を検索する
"------------------------------------------------
"function! SelSearch()
"    "最後のヤンクを保管しておく
"    let tmp = @"
"    "現在選択中のテキストを取得する
"    normal! gv"ty 
"    "取得した結果を変数に格納する
"    let seltext=@t
"    silent! exe ":/" . seltext
"    "最後のヤンクを書き戻す
"    let @" = tmp
"    let @/ = seltext
"    "二回の移動を組み合わせることで、次の検索したい文字列へジャンプする
"    normal! N
"    normal! n
"endfunction
function! SearchTheSelectedTextLiteraly()
  let reg_0 = [@0, getregtype('0')]
  let reg_u = [@", getregtype('"')]

  normal! gvy
  let @/ = @0
  call histadd('/', '\V' . escape(@0, '\'))
  normal! n

  call setreg('0', reg_0[0], reg_0[1])
  call setreg('"', reg_u[0], reg_u[1])
endfunction

"------------------------------------------------
" tagファイル作成関数 
"------------------------------------------------
"taglist.vim用設定
"tagsを使用できるようにする
" tag ファイルの指定
"tagファイル作成関数 
" 使い方：srcディレクトリをCtagsの引数に渡すと、~/.vim/tags ファイルを作成します。
"         引数がない場合、vimが認識してるカレントディレクトリでctagsを実行します。
"         http://d.hatena.ne.jp/smeghead/searchdiary?word=*%5Bvim%5D
function! s:Ctags(searchPath)
    let searchPath = a:searchPath
    if searchPath ==# ""
        let searchPath = getcwd()
    endif
    exe ':!ctags -R -f ' . $HOME . '/tags' searchPath
endfunction

"---------------------------------
" 最後に選択したテキストを取得する
"-----------------------------
function! x:selected_text()
  let [visual_p, pos, r_, r0] = [mode() =~# "[vV\<C-v>]", getpos('.'), @@, @0]

  if visual_p
    execute "normal! \<Esc>"
  endif
  normal! gvy
  let _ = @@

  let [@@, @0] = [r_, r0]
  if visual_p
    normal! gv
  else
    call setpos('.', pos)
  endif
  return _
endfunction

" :argdoと同等
function! Allargs(command)
    let i = 0
    while i < argc()
        if filereadable(argv(i))
            execute "e " . argv(i)
            execute a:command
        endif
        let i = i + 1
    endwhile
endfunction
command! -nargs=+ -complete=command Allargs call Allargs(<q-args>)

" IMEの状態を取得する Return 1:ON 0:OFF
function! ImeStatus()
    if has('win32') && has('ruby')
ruby << EOF
    require 'Win32API'

    # 最前面のウィンドウハンドルを取得（操作中のvimウインドウ）
    wndObj = Win32API.new('user32.dll', 'GetForegroundWindow', 'v', 'n')
    hWnd = wndObj.call
    # IMEのコンテキストを取得
    imcObj = Win32API.new('imm32','ImmGetContext','l','l')
    himc = imcObj.call(hWnd)
    # IMEの状態を取得
    imeOpenObj = Win32API.new('imm32','ImmGetOpenStatus',%w(l),'l')
    p imeOpenObj.call(himc).to_s
    VIM::command("return '" + imeOpenObj.call(himc).to_s + "'")
EOF
    else
        return '0'
    endif
endfunction

"------------------------------------------------
" 選択したテキストのURLEscapeを行う関数
"------------------------------------------------
function! UrlEscapeTheSelectedTextLiteraly(escape_flag)
    if !has('ruby')
        echoerr "実行にはRubyインターフェースが必要です"
        return
    end
    let reg_0 = [@0, getregtype('0')]
    let reg_u = [@", getregtype('"')]
    normal! gvy
    let @0 = UrlEscape(a:escape_flag)
    normal! gvp
    call setreg('0', reg_0[0], reg_0[1])
    call setreg('"', reg_u[0], reg_u[1])
endfunction
function! UrlEscape(escape_flag)
ruby << EOF
    require 'cgi'
    convert_text = ""
    escape_flag = {:escape => "1", :unescape => "2"}
    selected_text = VIM::evaluate('@0')
    escape_flag_param = VIM::evaluate('a:escape_flag')
    if escape_flag_param == escape_flag[:escape]
        convert_text = CGI.escape(selected_text)
    elsif escape_flag_param == escape_flag[:unescape]
        convert_text = CGI.unescape(selected_text)
    end
    VIM::command("return '#{convert_text}'")
EOF
endfunction

function SelectPasteTextOverWriteRegister()
    let @" = @0
endfunction

" YankRingっぽいローテーションペーストを行う
" TODO:複数行の対応とレジスタ汚染などの問題
function! NumberedRegisterRotation()
    let @9 = @8
    let @8 = @7
    let @7 = @6
    let @6 = @5
    let @5 = @4
    let @4 = @3
    let @3 = @2
    let @2 = @1
    let @1 = @"
endfunction
function! RegistersComplete()
    call complete(col('.'), [@",@1,@2,@3,@4,@5,@6,@7,@8,@9])
    return ''
endfunction

" .gitのあるディレクトリに移動する
function! CdDotGitDir()
    let l:current_path = getcwd()
    lcd %:p:h
    if finddir('.git','.;') !~ ".git$"
        echo 'Not found dotgit directory.'
        exec "lcd " . l:current_path
        return ''
    endif
    let l:dotgit_path = SearchDotGitPath('')
    exec "lcd " . l:dotgit_path
endfunction
function! SearchDotGitPath(search_path)
    if finddir('.git', a:search_path) =~ ".git$"
        return a:search_path
    else
        let l:search_path = a:search_path . '../'
        let l:search_result_path = SearchDotGitPath(l:search_path)
        return l:search_result_path
    endif
endfunction

" Envroiments: 環境固有設定 =========================================== {{{1

"Screenの場合にvimを使用した時にスクリーンタブ名を書き換える
if &term =~ "screen"
	autocmd VimLeave * call SetScreenTabName('shell')
	autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | call SetScreenTabName("%") | endif
endif

" 公開できない設定やローカルマシンごとの固有設定を読み込む
if filereadable("$HOME/.private/.vimrc_private")
    source $HOME/.private/.vimrc_private
endif

" Tmp: 一時な設定 ===================================================== {{{1

" Etc: その他 ========================================================= {{{1

" ^@を削除するテスト
inoremap <C-space><C-d> <ESC>:%s/<C-@>$//ge<CR>:%s/<C-@>/\r/ge<CR>A
