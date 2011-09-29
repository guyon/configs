" Utilities for list.

let s:save_cpo = &cpo
set cpo&vim

" Removes duplicates from a list.
function! s:uniq(list, ...)
  let list = a:0 ? map(a:list, printf('[v:val, %s]', a:1)) : a:list
  let i = 0
  let seen = {}
  while i < len(list)
    let key = string(a:0 ? list[i][1] : list[i])
    if has_key(seen, key)
      call remove(list, i)
    else
      let seen[key] = 1
      let i += 1
    endif
  endwhile
  return a:0 ? map(list, 'v:val[0]') : list
endfunction

" Concatenates a list of lists.
" XXX: Should we verify the input?
function! s:concat(list)
  let list = []
  for Value in a:list
    let list += Value
  endfor
  return list
endfunction

" Flattens a list.
function! s:flatten(list)
  let list = []
  for Value in a:list
    if type(Value) == type([])
      let list += s:flatten(Value)
    else
      call add(list, Value)
    endif
    unlet! Value
  endfor
  return list
endfunction

" Sorts a list with expression to compare each two values.
" a:a and a:b can be used in {expr}.
function! s:sort(list, expr)
  if type(a:expr) == type(function('function'))
    return sort(a:list, a:expr)
  endif
  let s:expr = a:expr
  return sort(a:list, 's:_compare')
endfunction

function! s:_compare(a, b)
  return eval(s:expr)
endfunction

" TODO: Use sort()'s {dict} argument which was introduced by 7.3.224
" Sorts a list using a set of keys generated by mapping the values in the list
" through the given expr.
" v:val is used in {expr}
function! s:sort_by(list, expr)
  let pairs = map(a:list, printf('[v:val, %s]', a:expr))
  return map(s:sort(pairs,
  \      'a:a[1] ==# a:b[1] ? 0 : a:a[1] ># a:b[1] ? 1 : -1'), 'v:val[0]')
endfunction

" Returns List of character sequence between [a:from, a:to]
" e.g.: s:char_range('a', 'c') returns ['a', 'b', 'c']
function! s:char_range(from, to)
  return map(
  \   range(char2nr(a:from), char2nr(a:to)),
  \   'nr2char(v:val)'
  \)
endfunction

" Returns true if a:list has a:Value.
" Returns false otherwise.
function! s:has(list, Value)
  return index(a:list, a:Value) isnot -1
endfunction

" Returns true if a:list[a:index] exists.
" Returns false otherwise.
" NOTE: Returns false when a:index is negative number.
function! s:has_index(list, index)
    " Return true when negative index?
    " let index = a:index >= 0 ? a:index : len(a:list) + a:index
    return 0 <= a:index && a:index < len(a:list)
endfunction


let &cpo = s:save_cpo
