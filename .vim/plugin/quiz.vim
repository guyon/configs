" Usage:
"    see HTTP&JSON PARSE Code gist: 557424

if &cp || (exists('g:loaded_quiz_vim') && g:loaded_quiz_vim)
    finish
endif
let g:loaded_quiz_vim = 1

if !exists('g:quiz_count')
    let g:quiz_count = 1
endif

function! s:nr2byte(nr)
    if a:nr < 0x80
        return nr2char(a:nr)
    elseif a:nr < 0x800
        return nr2char(a:nr/64+192).nr2char(a:nr%64+128)
    else
        return nr2char(a:nr/4096%16+224).nr2char(a:nr/64%64+128).nr2char(a:nr%64+128)
    endif
endfunction

function! s:nr2enc_char(charcode)
    if &encoding == 'utf-8'
        return nr2char(a:charcode)
    endif
    let char = s:nr2byte(a:charcode)
    if strlen(char) > 1
        let char = strtrans(iconv(char, 'utf-8', &encoding))
    endif
    return char
endfunction

function! s:nr2hex(nr)
    let n = a:nr
    let r = ""
    while n
        let r = '0123456789ABCDEF'[n % 16] . r
        let n = n / 16
    endwhile
    return r
endfunction

function! s:encodeURIComponent(instr)
    let instr = iconv(a:instr, &enc, "utf-8")
    let len = strlen(instr)
    let i = 0
    let outstr = ''
    while i < len
        let ch = instr[i]
        if ch =~# '[0-9A-Za-z-._~!''()*]'
            let outstr .= ch
        elseif ch == ' '
            let outstr .= '+'
        else
            let outstr .= '%' . substitute('0' . s:nr2hex(char2nr(ch)), '^.*\(..\)$', '\1', '')
        endif
        let i = i + 1
    endwhile
    return outstr
endfunction

function! s:item2query(items, sep)
    let ret = ''
    if type(a:items) == 4
        for key in keys(a:items)
            if strlen(ret) | let ret .= a:sep | endif
            let ret .= key . "=" . s:encodeURIComponent(a:items[key])
        endfor
    elseif type(a:items) == 3
        for item in a:items
            if strlen(ret) | let ret .= a:sep | endif
            let ret .= item
        endfor
    else
        let ret = a:items
    endif
    return ret
endfunction

function! s:getQuiz(quiz_count)
    let url = 'http://quizken.jp/api/quiz-index/api_key/ma6/count/' . a:quiz_count
    let quote = &shellxquote == '"' ?  "'" : '"'
    let json = system("curl -L -s ".quote.url.quote)
    let json = iconv(json, "utf-8", &encoding)
    let json = substitute(json, '\\u\(\x\x\x\x\)', '\=s:nr2enc_char("0x".submatch(1))', 'g')
    let [null,true,false] = [0,1,0]
    return eval(json)
endfunction

function! s:startQuiz(res)
    for quiz in a:res
        echohl WarningMsg
        echo quiz['question']
        echo ' '
        echohl None

        let correct_answer = quiz['answers'][0]
        let i = 1
        let correct_number = ''
        for answer in sort(quiz['answers'])
            echo i . ":" . answer
            if correct_answer == answer
                let correct_number = i
            endif
            let i += 1
        endfor
        if input("answer:") == correct_number
            redraw
            echo '                      '
            echo "Correct!!"
        else
            redraw
            echo '                      '
            echohl WarningMsg
            echo "Wrong. Correct Answer is [" . correct_number . "] ... " . correct_answer
            echohl None
        endif
        if input("next(Enter) quit(q):") == "q"
            redraw
            break
        endif
        redraw
    endfor
endfunction

function! s:isNotCountRange(count)
    if a:count != '' && a:count !~ '\v^([1-4][0-9]|[1-9]$|50)$'
        return 1
    endif
endfunction


function! g:Quiz(args)
    if s:isNotCountRange(a:args)
        echohl Error
        echo "ERROR: Please specify the parameter in the range of 1-50."
        echohl None
        return
    endif

    let more = &more
    set nomore

    let quiz_count = a:args ? a:args : g:quiz_count
    let res = s:getQuiz(quiz_count)
    call s:startQuiz(res)

    let &more = more
endfunction


command! -nargs=? Quiz call g:Quiz(<q-args>)
