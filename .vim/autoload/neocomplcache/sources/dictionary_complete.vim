"=============================================================================
" FILE: dictionary_complete.vim
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

function! neocomplcache#sources#dictionary_complete#define()"{{{
  return s:source
endfunction"}}}

let s:source = {
      \ 'name' : 'dictionary_complete',
      \ 'kind' : 'plugin',
      \}

function! s:source.initialize()"{{{
  " Initialize.
  let s:dictionary_list = {}
  let s:completion_length = neocomplcache#get_auto_completion_length('dictionary_complete')
  let s:async_dictionary_list = {}

  " Initialize dictionary."{{{
  if !exists('g:neocomplcache_dictionary_filetype_lists')
    let g:neocomplcache_dictionary_filetype_lists = {}
  endif
  if !has_key(g:neocomplcache_dictionary_filetype_lists, 'default')
    let g:neocomplcache_dictionary_filetype_lists['default'] = ''
  endif
  "}}}

  " Initialize dictionary completion pattern."{{{
  if !exists('g:neocomplcache_dictionary_patterns')
    let g:neocomplcache_dictionary_patterns = {}
  endif
  "}}}

  " Set caching event.
  autocmd neocomplcache FileType * call s:caching()

  " Add command.
  command! -nargs=? -complete=customlist,neocomplcache#filetype_complete NeoComplCacheCachingDictionary call s:recaching(<q-args>)

  " Create cache directory.
  if !isdirectory(g:neocomplcache_temporary_dir . '/dictionary_cache')
    call mkdir(g:neocomplcache_temporary_dir . '/dictionary_cache')
  endif

  " Initialize check.
  call s:caching()
endfunction"}}}

function! s:source.finalize()"{{{
  delcommand NeoComplCacheCachingDictionary
endfunction"}}}

function! s:source.get_keyword_list(cur_keyword_str)"{{{
  let list = []

  let filetype = neocomplcache#is_text_mode() ? 'text' : neocomplcache#get_context_filetype()
  if neocomplcache#is_text_mode() && !has_key(s:dictionary_list, 'text')
    " Caching.
    call s:caching()
  endif

  for ft in neocomplcache#get_source_filetypes(filetype)
    call neocomplcache#cache#check_cache('dictionary_cache', ft, s:async_dictionary_list,
      \ s:dictionary_list, s:completion_length)

    for source in neocomplcache#get_sources_list(s:dictionary_list, ft)
      let list += neocomplcache#dictionary_filter(source, a:cur_keyword_str, s:completion_length)
    endfor
  endfor

  return list
endfunction"}}}

function! s:caching()"{{{
  if !bufloaded(bufnr('%'))
    return
  endif

  let key = neocomplcache#is_text_mode() ? 'text' : neocomplcache#get_context_filetype()
  for filetype in neocomplcache#get_source_filetypes(key)
    if !has_key(s:dictionary_list, filetype)
          \ && !has_key(s:async_dictionary_list, filetype)
      call s:recaching(filetype)
    endif
  endfor
endfunction"}}}

function! s:caching_dictionary(filetype)
  if a:filetype == ''
    let filetype = neocomplcache#get_context_filetype(1)
  else
    let filetype = a:filetype
  endif
  if has_key(s:async_dictionary_list, filetype)
        \ && filereadable(s:async_dictionary_list[filetype].cache_name)
    " Delete old cache.
    call delete(s:async_dictionary_list[filetype].cache_name)
  endif

  call s:recaching(filetype)
endfunction
function! s:recaching(filetype)"{{{
  " Caching.
  if has_key(g:neocomplcache_dictionary_filetype_lists, a:filetype)
    let dictionaries = g:neocomplcache_dictionary_filetype_lists[a:filetype]
  elseif a:filetype != &filetype || &l:dictionary == ''
    return
  else
    let dictionaries = &l:dictionary
  endif

  let s:async_dictionary_list[a:filetype] = []

  let pattern = has_key(g:neocomplcache_dictionary_patterns, a:filetype) ?
        \ g:neocomplcache_dictionary_patterns[a:filetype] :
        \ neocomplcache#get_keyword_pattern(a:filetype)
  for dictionary in split(dictionaries, ',')
    if filereadable(dictionary)
      call add(s:async_dictionary_list[a:filetype], {
            \ 'filename' : dictionary,
            \ 'cachename' : neocomplcache#cache#async_load_from_file(
            \       'dictionary_cache', dictionary, pattern, 'D')
            \ })
    endif
  endfor
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
