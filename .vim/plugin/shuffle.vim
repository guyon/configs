"          FILE: shuffle.vim
"      Language: vim script
"    Maintainer: Yichao Zhou (broken.zhou AT gmail dot com)
"       Created: 2012 Jun 04 20:10:21
" Last Modified: 2012 Apr 18 14:06:11
"   Description: 
"       This is a simple script to do the random shuffle of the lines in
"       buffer.  Please notice that this script need python2 support!
"       In order to use the map conveniently, you may want to define some key
"       map yourself.
"
"        Usage:
"          Press "V" to select some line.  Use command :Shuffle to do the left
"          work.

if exists("g:loaded_shuffle")
    finish
endif
let g:loaded_shuffle = 1

com! -nargs=0 -range Shuffle <line1>,<line2>call Shuffle()
fun! Shuffle() range
    if !has('python')
        echohl ErrorMsg | echo 'python is not supported!' | echohl None
        return
    endif
python <<_EOF_
try:
    import vim
    import random
    first = int(vim.eval('a:firstline'))
    last = int(vim.eval('a:lastline'))
    random.shuffle(vim.current.buffer.range(first, last))
except Exception, e:
    print e
_EOF_
endfun
