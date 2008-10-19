scriptencoding utf-8

SpeedDatingFormat %Y年%m月%d日 %H時%M分%S秒
SpeedDatingFormat %Y年%m月%d日 %H時%M分
SpeedDatingFormat %Y年%m月%d日
SpeedDatingFormat %Y/%m/%d%[ T_-]%H:%M:%S %z
SpeedDatingFormat %Y/%m/%d%[ T_-]%H:%M:%S%?[Z]    " SQL, etc.
SpeedDatingFormat %Y/%m/%d

let s:japanese_number = '０１２３４５６７８９'
function! s:japanized_number(string,offset,increment)
    let n = tr(a:string, s:japanese_number, '0123456789') + a:increment
    let g:hoge = a:string
    return [tr(n, '0123456789', s:japanese_number), -1]
endfunction
function! s:function(name)
    return function(substitute(a:name,'^s:',matchstr(expand('<sfile>'), '<SNR>\d\+_'),''))
endfunction
let g:speeddating_handlers += [{'regexp': '-\=\<[１２３４５６７８９０]\+\>', 'increment': s:function('s:japanized_number')}]
