"=============================================================================
" gauref.vim - Look up a reference manual of Gauche
"=============================================================================
"
" Author:  Takeshi Nishida <ns9tks(at)gmail.com>
" Version: 0.1, for Vim 7.1
" Licence: gauref.vim: MIT Licence
"          gauche-refe.txt and gauche-refj.txt: See gauche-COPYING
" URL:     ?
"
"=============================================================================
" DOCUMENT: (Japanese: http://vim.g.hatena.ne.jp/keyword/gauref.vim)
"
" Description: ---------------------------------------------------------- {{{1
"   Gauref provides interfaces to look up a keyword in a reference manual of
"   Gauche which is an R5RS Scheme implementation.
"
"   You can look up a keyword:
"     - command-line with completion.
"     - under the cursor in Normal mode.
"     - selected in Visual mode.
"
"   In the buffer of reference manual, folds for every section/entry are
"   created and closed by default. You can open a closed fold by looking up
"   it.
"
"   gauche-refe.txt and gauche-refj.txt are Gauche reference manuals of
"   English and Japanese version which are converted texi files inluded Gauche
"   package.
"
" Installation: --------------------------------------------------------- {{{1
"   - Drop this file in your plugin directory.
"   - Drop gauche-refe.txt in ~/.vim/. You can change location by
"     g:gauref_file option. (To see japanese manual, use gauche-refj.txt)
"
" Usage: ---------------------------------------------------------------- {{{1
"   You can look up keywords by command/mapping.

"   Command:
"     :Gauref {keyword}
"       looks up {keyword}. You can use command-line completion.

"   Mapping:
"     "K"
"       looks up the keyword under the cursor in Normal mode, or selected
"       keyword in Visual mode.
"
"   If there is more than one entry with the same name, you can jump to next
"   entry by using "K" on the keyword.
"
"
" Options: -------------------------------------------------------------- {{{1
"   g:gauref_file:
"     The file name of Gauche reference manual.
"
"   g:gauref_key_lookup:
"     The key which is mapped to look up the keyword under the cursor or
"     selected.
"
" Making Gauche Reference Manual Files For Gauref: ---------------------- {{{1
"   Get Gauche package, make, and execute following commands:
"     makeinfo --plaintext gauche-refe.texi | vim - "+%s/\ze\n\*\{2,}$/ {\{{1" "+%s/\ze\n=\{2,}$/ {\{{2" "+%s/\ze\n-\{2,}$/ {\{{3" "+call append('$', ['}}}1', 'vim:set ft=gauref fdm=marker isk=33,35-39,42-58,60-90,94,95,97-122,126,_:'])" "+wq gauche-refe.txt"
"     makeinfo --plaintext gauche-refj.texi | vim - "+%s/\ze\n\*\{2,}$/ {\{{1" "+%s/\ze\n=\{2,}$/ {\{{2" "+%s/\ze\n-\{2,}$/ {\{{3" "+call append('$', ['}}}1', 'vim:set ft=gauref fdm=marker isk=33,35-39,42-58,60-90,94,95,97-122,126,_:'])" "+wq gauche-refj.txt"
" ChangeLog: ------------------------------------------------------------ {{{1
"   0.1:
"       - First release.
"
" }}}1
"=============================================================================

" INCLUDE GUARD: ======================================================== {{{1
if exists('loaded_gauref') || v:version < 701
  finish
endif
let loaded_gauref = 1


" FUNCTION: ============================================================= {{{1
"-----------------------------------------------------------------------------
function! s:OpenBuffer()
  if !filereadable(expand(g:gauref_file))
    throw "Can't read: " . g:gauref_file
  elseif bufwinnr(g:gauref_file) != -1
    execute bufwinnr(g:gauref_file) . 'wincmd w'
  elseif bufnr(g:gauref_file) != -1
    execute 'sbuffer ' . bufnr(g:gauref_file)
  else
    execute 'split ' . g:gauref_file
    setlocal bufhidden=hide noswapfile nomodifiable readonly

    " highlighting and making keyword list
    let re_keyword_line = '^ -- \([^:]\+\): \zs\(\S\+\)'
    let s:gauref_keywords = ''
    for i in filter(map(getline(1,'$'),
          \             'matchlist(v:val, ''^ -- \([^:]\+\): \zs\(\S\+\)'')'),
          \         'len(v:val) > 0')
      execute 'syntax keyword Statement ' . i[2]
      let s:gauref_keywords .= i[2] . "\n"
    endfor

    syntax match Title /^.*[{]{{\d$/
    syntax match Title /^ -- .[^:]\+:/
  endif
endfunction

"-----------------------------------------------------------------------------
function! s:Lookup(keyword)
  call s:OpenBuffer()

  if a:keyword !~ '\S'
    return
  endif

  " jump and open folding
  if search('\V\^ --\[^:]\*: \zs' . a:keyword . '\(\s\|\$\)', 'sw')
    call feedkeys('zv', 'n')
  else
    echohl ErrorMsg | echo 'Keyword is not found: ' . a:keyword | echohl None
  endif
endfunction

"-----------------------------------------------------------------------------
function! s:GaurefComplete(A,L,P)
  " to make keyword list
  if !exists('s:gauref_keywords')
    call s:OpenBuffer()
    close
  endif

  return s:gauref_keywords
endfunction

"-----------------------------------------------------------------------------
function! s:GetVisualText()
  let p0 = getpos('''<')
  let p1 = getpos('''>')

  if p0[1] == p1[1]
    return getline(p0[1])[ p0[2] - 1 : p1[2] - 1 ]
  else
    return join([ getline(p0[1])[ p0[2] - 1 : ] ] +  getline(p0[1] + 1, p1[1] - 1) +
          \     [ getline(p1[1])[ : p1[2] - 1 ] ] , "\n")
  endif
endfunction

" }}}1

" INITIALIZATION: GLOBAL OPTIONS: ======================================= {{{1
"-----------------------------------------------------------------------------
if !exists('g:gauref_file')
  let g:gauref_file = '~/.vim/gauche-refe.txt'
endif
"-----------------------------------------------------------------------------
if !exists('g:gauref_key_lookup')
  let g:gauref_key_lookup = 'K'
endif

" INITIALIZATION: COMMANDS, AUTOCOMMANDS, MAPPINGS, ETC.: =============== {{{1
"-----------------------------------------------------------------------------
command -narg=? -complete=custom,s:GaurefComplete Gauref call s:Lookup(<q-args>)
command -narg=0 -range GaurefWord   call s:Lookup(expand('<cword>'))
command -narg=0 -range GaurefVisual call s:Lookup(s:GetVisualText())

"-----------------------------------------------------------------------------
autocmd FileType scheme,gauref execute printf('nnoremap <buffer> <silent> %s :GaurefWord<CR>'  , g:gauref_key_lookup)
autocmd FileType scheme,gauref execute printf('vnoremap <buffer> <silent> %s :GaurefVisual<CR>', g:gauref_key_lookup)

" }}}1
"=============================================================================
" PACKAGING: ============================================================ {{{1
" 7z a -tzip ~/gauref.zip ~/.vim/plugin/gauref.vim ~/.vim/gauche-COPYING ~/.vim/gauche-refe.txt ~/.vim/gauche-refj.txt
" }}}1
" vim: set fdm=marker:
