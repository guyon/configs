" Vim plugin to monitor/edit a running log file, similar to using $ tail -f
" Last change: 20070917
" Version: 1.0.2
" Author: Basil Shkara <basil at oiledmachine dot com>
" License: This file is placed in the public domain
" 
" Installation:
" -------------
" 1. Drop the plugin file (tailf.vim) into your plugins directory.
" 2. Restart Vim to load Tailf.
" 3. Open your log file with :Tailf <<pathname>>.
" 4. Hit <Space> to insert a line break with text.
" 
" Version History:
" ----------------
"  v1.0.2	Fixed buffer reload problem
"  v1.0.1	Fixed redraw issues
"  v1.0		Initial release

" check for Vim 7
if version < 700
	echo "\nTailf requires Vim 7.0 at least"
	echo "You currently have version: ".version
	echo "Tailf will not be active this session\n"
    finish
endif

"if plugin already loaded
if exists("loaded_tailf")
	finish
endif
let loaded_tailflf = 1

" create ex command for toggling drill window
command! -complete=file -nargs=1 -bar Tailf call s:OpenFile(<f-args>)

function s:OpenFile(pathname)
	execute "tabnew ". a:pathname
	let s:path = a:pathname
	" mapping for appending timestamp
	noremap <buffer><silent> <Space> :call <SID>AppendTimeStamp()<CR>
	" count number of lines in file
	let s:curr_lines = line("$")
	" update every 4000ms: see 'updatetime'
	autocmd CursorHold <buffer>	call <SID>FileChanged()
	autocmd CursorHoldI <buffer> call <SID>FileChanged()
	autocmd FileChangedShell <buffer> call <SID>FileChanged()
endfunction

function s:FileChanged()
	" if in Tailf buffer reload, otherwise don't
    let a:winnum = bufwinnr(s:path)
    if a:winnum != -1
		silent edit
    endif

	let a:appended_lines = line("$") - s:curr_lines
	let s:curr_lines = line("$")
	" check if file changed
	if (a:appended_lines != 0)
		" position cursor at end of file
		$
		:echohl StatusLine | redraw | echo a:appended_lines . " lines appended" | echohl None
	endif
endfunction

function s:AppendTimeStamp()
	$
	let a:lb_text = input("Enter line break text: ")
	call append(line("$"), "")
	call append(line("$"), "<".strftime("%c") . "> " . a:lb_text)
	call append(line("$"), "")
	write
	let s:curr_lines = line("$")
endfunction
