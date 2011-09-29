"=============================================================================
" FILE: include_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 19 Sep 2011.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:include_info = {}

let s:source = {
      \ 'name' : 'include_complete',
      \ 'kind' : 'plugin',
      \}

function! s:source.initialize()"{{{
  " Initialize
  let s:include_info = {}
  let s:include_cache = {}
  let s:async_include_cache = {}
  let s:cached_pattern = {}
  let s:completion_length = neocomplcache#get_auto_completion_length('include_complete')

  " Set rank.
  call neocomplcache#set_dictionary_helper(g:neocomplcache_plugin_rank, 'include_complete', 8)

  if neocomplcache#has_vimproc()
    augroup neocomplcache
      " Caching events
      autocmd BufWritePost * call s:check_buffer('', 0)
    augroup END
  endif

  " Initialize include pattern."{{{
  call neocomplcache#set_dictionary_helper(g:neocomplcache_include_patterns, 'java,haskell', '^import')
  "}}}
  " Initialize expr pattern."{{{
  call neocomplcache#set_dictionary_helper(g:neocomplcache_include_exprs, 'haskell',
        \'substitute(v:fname,''\\.'',''/'',''g'')')
  "}}}
  " Initialize path pattern."{{{
  "}}}
  " Initialize suffixes pattern."{{{
  call neocomplcache#set_dictionary_helper(g:neocomplcache_include_suffixes, 'haskell', '.hs')
  "}}}
  if !exists('g:neocomplcache_include_max_processes')
    let g:neocomplcache_include_max_processes = 20
  endif

  " Create cache directory.
  if !isdirectory(g:neocomplcache_temporary_dir . '/include_cache')
    call mkdir(g:neocomplcache_temporary_dir . '/include_cache', 'p')
  endif

  " Add command.
  command! -nargs=? -complete=buffer NeoComplCacheCachingInclude call s:caching_include(<q-args>)

  if neocomplcache#exists_echodoc()
    call echodoc#register('include_complete', s:doc_dict)
  endif
endfunction"}}}

function! s:source.finalize()"{{{
  delcommand NeoComplCacheCachingInclude
  
  if neocomplcache#exists_echodoc()
    call echodoc#unregister('include_complete')
  endif
endfunction"}}}

function! s:source.get_keyword_list(cur_keyword_str)"{{{
  if neocomplcache#within_comment()
    return []
  endif

  if !has_key(s:include_info, bufnr('%'))
    " Auto caching.
    call s:check_buffer('', 0)
  endif

  let keyword_list = []

  " Check caching.
  for include in s:include_info[bufnr('%')].include_files
    call neocomplcache#cache#check_cache(
          \ 'include_cache', include, s:async_include_cache,
          \ s:include_cache, s:completion_length)
    if has_key(s:include_cache, include)
      let keyword_list += neocomplcache#dictionary_filter(
            \ s:include_cache[include], a:cur_keyword_str, s:completion_length)
    endif
  endfor

  return neocomplcache#keyword_filter(neocomplcache#dup_filter(keyword_list), a:cur_keyword_str)
endfunction"}}}

function! neocomplcache#sources#include_complete#define()"{{{
  return s:source
endfunction"}}}

function! neocomplcache#sources#include_complete#get_include_files(bufnumber)"{{{
  if has_key(s:include_info, a:bufnumber)
    return s:include_info[a:bufnumber].include_files
  else
    return []
  endif
endfunction"}}}

" For echodoc."{{{
let s:doc_dict = {
      \ 'name' : 'include_complete',
      \ 'rank' : 5,
      \ 'filetypes' : {},
      \ }
function! s:doc_dict.search(cur_text)"{{{
  if &filetype ==# 'vim' || !has_key(s:include_info, bufnr('%'))
    return []
  endif

  " Collect words.
  let words = []
  let i = 0
  while i >= 0
    let word = matchstr(a:cur_text, '\k\+', i)
    if len(word) >= s:completion_length
      call add(words, word)
    endif

    let i = matchend(a:cur_text, '\k\+', i)
  endwhile

  for word in reverse(words)
    let key = tolower(word[: s:completion_length-1])

    for include in filter(copy(s:include_info[bufnr('%')].include_files),
          \ 'has_key(s:include_cache, v:val) && has_key(s:include_cache[v:val], key)')
      for matched in filter(values(s:include_cache[include][key]),
            \ 'v:val.word ==# word && has_key(v:val, "kind") && v:val.kind != ""')
        let ret = []

        let match = match(matched.abbr, neocomplcache#escape_match(word))
        if match > 0
          call add(ret, { 'text' : matched.abbr[ : match-1] })
        endif

        call add(ret, { 'text' : word, 'highlight' : 'Identifier' })
        call add(ret, { 'text' : matched.abbr[match+len(word) :] })

        if match > 0 || len(ret[-1].text) > 0
          return ret
        endif
      endfor
    endfor
  endfor

  return []
endfunction"}}}
"}}}

function! s:check_buffer(bufnumber, is_force)"{{{
  let bufnumber = (a:bufnumber == '') ? bufnr('%') : a:bufnumber
  let filename = fnamemodify(bufname(bufnumber), ':p')

  if !has_key(s:include_info, bufnumber)
    " Initialize.
    let s:include_info[bufnumber] = {
          \ 'include_files' : [], 'lines' : [],
          \ 'async_files' : {},
          \ }
  endif

  if !executable(g:neocomplcache_ctags_program)
        \ || (!a:is_force && !neocomplcache#has_vimproc())
    return
  endif

  let include_info = s:include_info[bufnumber]

  if include_info.lines !=# getbufline(bufnumber, 1, 100)
    let include_info.lines = getbufline(bufnumber, 1, 100)

    " Check include files contained bufname.
    let include_files =
          \ neocomplcache#util#uniq(s:get_buffer_include_files(bufnumber))

    if getbufvar(bufnumber, '&buftype') !~ 'nofile'
          \ && filereadable(filename)
      call add(include_files, filename)
    endif
    let include_info.include_files = include_files
  endif

  if g:neocomplcache_include_max_processes <= 0
    return
  endif

  let filetype = getbufvar(bufnumber, '&filetype')
  if filetype == ''
    let filetype = 'nothing'
  endif

  for filename in include_info.include_files
    if (a:is_force || !has_key(include_info.async_files, filename))
          \ && !has_key(s:include_cache, filename)
      if !a:is_force && has_key(s:async_include_cache, filename)
            \ && len(s:async_include_cache[filename])
            \            >= g:neocomplcache_include_max_processes
        break
      endif

      " Caching.
      let s:async_include_cache[filename]
            \ = [ s:initialize_include(filename, filetype) ]
      let include_info.async_files[filename] = 1
    endif
  endfor
endfunction"}}}
function! s:get_buffer_include_files(bufnumber)"{{{
  let filetype = getbufvar(a:bufnumber, '&filetype')
  if filetype == ''
    return []
  endif

  if filetype == 'python'
        \ && !has_key(g:neocomplcache_include_paths, 'python')
        \ && executable('python')
    " Initialize python path pattern.
    call neocomplcache#set_dictionary_helper(g:neocomplcache_include_paths, 'python',
          \ neocomplcache#system('python -', 'import sys;sys.stdout.write(",".join(sys.path))'))
  elseif filetype == 'cpp' && isdirectory('/usr/include/c++')
    " Add cpp path.
    call neocomplcache#set_dictionary_helper(g:neocomplcache_include_paths, 'cpp',
          \ getbufvar(a:bufnumber, '&path') . ',/usr/include/c++/*')
  endif

  let pattern = has_key(g:neocomplcache_include_patterns, filetype) ?
        \ g:neocomplcache_include_patterns[filetype] : getbufvar(a:bufnumber, '&include')
  if pattern == ''
    return []
  endif
  let path = has_key(g:neocomplcache_include_paths, filetype) ?
        \ g:neocomplcache_include_paths[filetype] : getbufvar(a:bufnumber, '&path')
  let expr = has_key(g:neocomplcache_include_exprs, filetype) ?
        \ g:neocomplcache_include_exprs[filetype] : getbufvar(a:bufnumber, '&includeexpr')
  if has_key(g:neocomplcache_include_suffixes, filetype)
    let suffixes = &l:suffixesadd
  endif

  " Change current directory.
  let cwd_save = getcwd()
  if isdirectory(fnamemodify(bufname(a:bufnumber), ':p:h'))
    lcd `=fnamemodify(bufname(a:bufnumber), ':p:h')`
  endif

  let include_files = s:get_include_files(0, getbufline(a:bufnumber, 1, 100), filetype, pattern, path, expr)

  lcd `=cwd_save`

  " Restore option.
  if has_key(g:neocomplcache_include_suffixes, filetype)
    let &l:suffixesadd = suffixes
  endif

  return include_files
endfunction"}}}
function! s:get_include_files(nestlevel, lines, filetype, pattern, path, expr)"{{{
  let include_files = []
  for line in a:lines"{{{
    if line =~ a:pattern
      let match_end = matchend(line, a:pattern)
      if a:expr != ''
        let eval = substitute(a:expr, 'v:fname', string(matchstr(line[match_end :], '\f\+')), 'g')
        let filename = fnamemodify(findfile(eval(eval), a:path), ':p')
      else
        let filename = fnamemodify(findfile(matchstr(line[match_end :], '\f\+'), a:path), ':p')
      endif
      if filereadable(filename) && getfsize(filename) < g:neocomplcache_caching_limit_file_size
        call add(include_files, filename)

        if (a:filetype == 'c' || a:filetype == 'cpp') && a:nestlevel < 1
          let include_files += s:get_include_files(a:nestlevel + 1, readfile(filename)[:100],
                \ a:filetype, a:pattern, a:path, a:expr)
        endif
      endif
    endif
  endfor"}}}

  return include_files
endfunction"}}}

function! s:initialize_include(filename, filetype)"{{{
  " Initialize include list from tags.
  return {
        \ 'filename' : a:filename,
        \ 'cachename' : neocomplcache#cache#async_load_from_tags(
        \              'include_cache', a:filename, a:filetype, 'I', 1)
        \ }
endfunction"}}}
function! s:caching_include(bufname)"{{{
  let bufnumber = (a:bufname == '') ? bufnr('%') : bufnr(a:bufname)
  if has_key(s:async_include_cache, bufnumber)
        \ && filereadable(s:async_include_cache[bufnumber].cache_name)
    " Delete old cache.
    call delete(s:async_include_cache[bufnumber].cache_name)
  endif

  " Initialize.
  if has_key(s:include_info, bufnumber)
    call remove(s:include_info, bufnumber)
  endif

  call s:check_buffer(bufnumber, 1)
endfunction"}}}

" Global options definition."{{{
if !exists('g:neocomplcache_include_patterns')
  let g:neocomplcache_include_patterns = {}
endif
if !exists('g:neocomplcache_include_exprs')
  let g:neocomplcache_include_exprs = {}
endif
if !exists('g:neocomplcache_include_paths')
  let g:neocomplcache_include_paths = {}
endif
if !exists('g:neocomplcache_include_suffixes')
  let g:neocomplcache_include_suffixes = {}
endif
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
