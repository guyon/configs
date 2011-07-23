"=============================================================================
" FILE: async_cache.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 10 Jun 2011.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following condition
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

function! s:main(argv)"{{{
  " args: outputname filename pattern_file_name mark minlen maxfilename
  let [l:outputname, l:filename, l:pattern_file_name, l:mark, l:minlen, l:maxfilename, l:fileencoding]
        \ = a:argv

  let l:pattern = get(readfile(l:pattern_file_name), 0, '\h\w*')
  let l:keyword_list = s:load_from_file(l:filename, l:pattern, l:mark, l:minlen, l:maxfilename, l:fileencoding)

  " Create dictionary key.
  for keyword in l:keyword_list
    if !has_key(keyword, 'kind')
      let keyword.kind = ''
    endif
    if !has_key(keyword, 'class')
      let keyword.class = ''
    endif
    if !has_key(keyword, 'abbr')
      let keyword.abbr = keyword.word
    endif
  endfor

  " Output cache.
  let l:word_list = []
  for keyword in l:keyword_list
    call add(l:word_list, printf('%s|||%s|||%s|||%s|||%s',
          \keyword.word, keyword.abbr, keyword.menu, keyword.kind, keyword.class))
  endfor

  if !empty(l:word_list)
    call writefile(l:word_list, l:outputname)
  endif
endfunction"}}}

function! s:load_from_file(filename, pattern, mark, minlen, maxfilename, fileencoding)"{{{
  if filereadable(a:filename)
    let l:lines = map(readfile(a:filename), 'iconv(v:val, a:fileencoding, &encoding)')
  else
    " File not found.
    return []
  endif

  let l:max_lines = len(l:lines)
  let l:menu = '[' . a:mark . '] ' . s:strwidthpart(
        \ fnamemodify(a:filename, ':t'), a:maxfilename)

  let l:keyword_list = []
  let l:dup_check = {}
  let l:keyword_pattern2 = '^\%('.a:pattern.'\m\)'

  for l:line in l:lines"{{{
    let l:match = match(l:line, a:pattern)
    while l:match >= 0"{{{
      let l:match_str = matchstr(l:line, l:keyword_pattern2, l:match)

      if !has_key(l:dup_check, l:match_str) && len(l:match_str) >= a:minlen
        " Append list.
        call add(l:keyword_list, { 'word' : l:match_str, 'menu' : l:menu })

        let l:dup_check[l:match_str] = 1
      endif

      let l:match = match(l:line, a:pattern, l:match + len(l:match_str))
    endwhile"}}}
  endfor"}}}

  return l:keyword_list
endfunction"}}}

function! s:load_from_tags(filename, tags_list, mark, filetype, minlen, maxfilename)"{{{
  let l:menu_pattern = printf('[%s] %%.%ds %%.%ds', a:mark, a:maxfilename, a:maxfilename)
  let l:keyword_lists = []
  let l:dup_check = {}
  let l:line_num = 1

  for l:line in a:tags_list"{{{
    let l:tag = split(substitute(l:line, "\<CR>", '', 'g'), '\t', 1)
    " Add keywords.
    if l:line !~ '^!' && len(l:tag) >= 3 && len(l:tag[0]) >= a:minlen
          \&& !has_key(l:dup_check, l:tag[0])
      let l:option = {
            \ 'cmd' : substitute(substitute(l:tag[2], '^\%([/?]\^\)\?\s*\|\%(\$\?[/?]\)\?;"$', '', 'g'), '\\\\', '\\', 'g'), 
            \ 'kind' : ''
            \}
      if l:option.cmd =~ '\d\+'
        let l:option.cmd = l:tag[0]
      endif

      for l:opt in l:tag[3:]
        let l:key = matchstr(l:opt, '^\h\w*\ze:')
        if l:key == ''
          let l:option['kind'] = l:opt
        else
          let l:option[l:key] = matchstr(l:opt, '^\h\w*:\zs.*')
        endif
      endfor

      if has_key(l:option, 'file') || (has_key(l:option, 'access') && l:option.access != 'public')
        let l:line_num += 1
        continue
      endif

      let l:abbr = has_key(l:option, 'signature')? l:tag[0] . l:option.signature : (l:option['kind'] == 'd' || l:option['cmd'] == '')?  l:tag[0] : l:option['cmd']
      let l:keyword = {
            \ 'word' : l:tag[0], 'abbr' : l:abbr, 'kind' : l:option['kind'], 'dup' : 1,
            \}
      if has_key(l:option, 'struct')
        let keyword.menu = printf(l:menu_pattern, fnamemodify(l:tag[1], ':t'), l:option.struct)
        let keyword.class = l:option.struct
      elseif has_key(l:option, 'class')
        let keyword.menu = printf(l:menu_pattern, fnamemodify(l:tag[1], ':t'), l:option.class)
        let keyword.class = l:option.class
      elseif has_key(l:option, 'enum')
        let keyword.menu = printf(l:menu_pattern, fnamemodify(l:tag[1], ':t'), l:option.enum)
        let keyword.class = l:option.enum
      elseif has_key(l:option, 'union')
        let keyword.menu = printf(l:menu_pattern, fnamemodify(l:tag[1], ':t'), l:option.union)
        let keyword.class = l:option.union
      else
        let keyword.menu = printf(l:menu_pattern, fnamemodify(l:tag[1], ':t'), '')
        let keyword.class = ''
      endif

      call add(l:keyword_lists, l:keyword)
      let l:dup_check[l:tag[0]] = 1
    endif

    let l:line_num += 1
  endfor"}}}

  if a:filetype != '' && has_key(g:neocomplcache_tags_filter_patterns, a:filetype)
    call filter(l:keyword_lists, g:neocomplcache_tags_filter_patterns[a:filetype])
  endif

  return l:keyword_lists
endfunction"}}}

function! s:truncate(str, width)"{{{
  " Original function is from mattn.
  " http://github.com/mattn/googlereader-vim/tree/master

  if a:str =~# '^[\x00-\x7f]*$'
    return len(a:str) < a:width ?
          \ printf('%-'.a:width.'s', a:str) : strpart(a:str, 0, a:width)
  endif

  let ret = a:str
  let width = s:wcswidth(a:str)
  if width > a:width
    let ret = s:strwidthpart(ret, a:width)
    let width = s:wcswidth(ret)
  endif

  if width < a:width
    let ret .= repeat(' ', a:width - width)
  endif

  return ret
endfunction"}}}

function! s:strchars(str)"{{{
  return len(substitute(a:str, '.', 'x', 'g'))
endfunction"}}}

function! s:strwidthpart(str, width)"{{{
  let ret = a:str
  let width = s:wcswidth(a:str)
  while width > a:width
    let char = matchstr(ret, '.$')
    let ret = ret[: -1 - len(char)]
    let width -= s:wcwidth(char)
  endwhile

  return ret
endfunction"}}}
function! s:strwidthpart_reverse(str, width)"{{{
  let ret = a:str
  let width = s:wcswidth(a:str)
  while width > a:width
    let char = matchstr(ret, '^.')
    let ret = ret[len(char) :]
    let width -= s:wcwidth(char)
  endwhile

  return ret
endfunction"}}}

if v:version >= 703
  " Use builtin function.
  function! s:wcswidth(str)"{{{
    return strdisplaywidth(a:str)
  endfunction"}}}
  function! s:wcwidth(str)"{{{
    return strwidth(a:str)
  endfunction"}}}
else
  function! s:wcswidth(str)"{{{
    if a:str =~# '^[\x00-\x7f]*$'
      return strlen(a:str)
    end

    let mx_first = '^\(.\)'
    let str = a:str
    let width = 0
    while 1
      let ucs = char2nr(substitute(str, mx_first, '\1', ''))
      if ucs == 0
        break
      endif
      let width += s:wcwidth(ucs)
      let str = substitute(str, mx_first, '', '')
    endwhile
    return width
  endfunction"}}}

  " UTF-8 only.
  function! s:wcwidth(ucs)"{{{
    let ucs = a:ucs
    if (ucs >= 0x1100
          \  && (ucs <= 0x115f
          \  || ucs == 0x2329
          \  || ucs == 0x232a
          \  || (ucs >= 0x2e80 && ucs <= 0xa4cf
          \      && ucs != 0x303f)
          \  || (ucs >= 0xac00 && ucs <= 0xd7a3)
          \  || (ucs >= 0xf900 && ucs <= 0xfaff)
          \  || (ucs >= 0xfe30 && ucs <= 0xfe6f)
          \  || (ucs >= 0xff00 && ucs <= 0xff60)
          \  || (ucs >= 0xffe0 && ucs <= 0xffe6)
          \  || (ucs >= 0x20000 && ucs <= 0x2fffd)
          \  || (ucs >= 0x30000 && ucs <= 0x3fffd)
          \  ))
      return 2
    endif
    return 1
  endfunction"}}}
endif

function! neocomplcache#async_cache#main(argv)"{{{
  call s:main(a:argv)
endfunction"}}}

if argc() == 7
  try
    call s:main(argv())
  catch
    call writefile([v:exception], expand('~/async_error_log'))
  endtry

  qall!
endif

" vim: foldmethod=marker
