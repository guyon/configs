"""""""""""""""""""""""""""""""
"-----------------------------"
" File: buffers_search.vim
" Author: Alexandru Ionut Munteanu (io_alex_2002 [ AT ] yahoo.fr)
" Description: The "Buffers Search" plugin searches the buffers
" for a pattern, prints the results into a new buffer and lets you
" jump in the buffers, at the position of a result, +++
" Version: 0.3
" Creation Date: 06.03.2007
" Last Modified: 12.03.2007
" {{{ History:
" History:
"					* "12.03.2007" - version 0.3 -
"					  -changed some internals to follow Jimmy advices (like
"					   using buffer numbers instead of buffer names to support
"					   unnamed buffers); thanks!
"					  -options J,A,Q,O,r,u,i,I,x,? implemented :
"					   "J"  : toggles jumping on the buffer on Enter
"					   "A"  : toggles auto-showing the context when j and k
"					   "Q"  : toggles auto-quitting the results when jumping
"					   "O"  : toggles between showing options or showing results 
"					   "r"  : refreshes the screen
"					   "u"  : update the search
"					   "i"  : toggles search match highlighting on the results buffer
"					   "I"  : toggles search match highlighting the other buffers
"					   "x"  : enables or disables quite-full-screen
"					   "?"  : toggles between showing help or showing results
"					   
"         * "08.03.2007" - version 0.2 -
"           -fixed an important bug; the search did not returned all
"            the matches
"
"         * "07.03.2007" - version 0.1 -
"           -initial version }}}
"
" Type zR if you use vim and don't understand what this file contains
"
" {{{ License : GNU GPL
" License:
"
" "Buffers Search" plugin searches the buffers for a pattern, and
" prints the results into a new buffer
"
" Copyright (C) 2007  Munteanu Alexandru Ionut
"
" This program is free software; you can redistribute it and/or
" modify it under the terms of the GNU General Public License
" as published by the Free Software Foundation; either version 2
" of the License, or (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program; if not, write to the Free Software
" Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
" 02110-1301, USA.
"
" }}}
"
" {{{ Documentation
" Documentation:
"
" {{{ Installation :
" Installation:
"
" Download the file "buffers_search.vim" and put it into the plugins
" directory; on a unix-like system, the user plugin directory could be
" "~/.vim/plugin"
"
" }}}
" {{{ Configuration
" Configuration:
"
" Variables that you can modify :
"         *the variables take the possible values 0 or 1
"   -g:Bs_stay_on_buffer_results_when_entering_result : if to jump on
"    the result or not when pressing enter (option "J") (default is 1)
"   -g:Bs_auto_jump : if to auto-show the result or not when moving
"    with j and k (option "A") (default is 1)
"   -g:Bs_toggle_quit_enter : if you want to quit the buffer with the
"    search results when jumping (option "Q") (default is 0)
"   -g:Bs_results_buffer_match : if you want to have syntax highlight
"    on the search string in the buffer with the results (option "i")
"    (default is 1)
"   -g:Bs_buffers_match : if you want to have syntax highlight on the
"    search string in other buffers (option "I") (default is 1)
"
" What you may want to modify :
"   -the function "s:Bs_define_user_commands" defines the :Bs command;
"    you may want to change Bs to something else
"   -the functions "s:Bs_keys_mapping", "s:Bs_auto_jump_mapping",
"    "s:Bs_non_auto_jump_mapping" are defining the mappings inside the 
"    buffer that contains the search results (the keys that you use to 
"    navigate easily) 
"   -the function "s:Bs_syntax_highlight" contains the syntax highlight
"    inside the buffer with the search results; you could modifye its
"    content as you prefer
"
" }}}
" {{{ Utilisation :
" Utilisation:
" 
"O_____________:
" User Commands:
"O_____________:
"
" The only command available is :
"   ":Bs <search_regex>"
"
"   Example:
"     :Bs function test
"
" After typing this command followed by Enter (<CR>), two things
" could happend :
"   -if there is no result, there is no much change; nothing appears
"   -if there is at least one result, a new buffer appears at the
"   bottom at the screen, containing the results of the buffers; the
"   focus is then transferred to the buffer with the search results,
"   on the first result of the first printed buffer
"
"O____________________________:
" The Buffer With The Results:
"O____________________________:
" The buffer with the results contains the results for each buffer.
"
" Syntax of the buffer with the results :
" ---------------------------------------
"   The results for one buffer are between the "-buffer_number:buffer_name" line, and
" the next similar line that starts the next buffer or the end of the
" buffer.
"   Each result is written on one line : on the first part of the line,
" until the first ':' we have the line number of each result, and
" after the ':' we have the line containing the matched string from
" the buffer.
"   The matched string is highlighted like a search result, in all the
" results buffer.
"   Some basic syntax highlight is available, like matching numbers,
" strings, some ponctuation signs and paranthesis.
"
" Usage of the buffer with the results :
" --------------------------------------
"   Like every regular buffer, most of the tasks that you can do
" usually are available inside.
"
"  Default Mappings And Options:
"  -----------------------------
"   -the :number option is off
"   -the buffer is marked as nomodifiable
"   -the buffer is marked as a scratch; everything inside the buffer
"    will be lost, if not saved by the user
"   -some special keymaps are available inside the buffer :
"
"   Special Keymaps In The Buffer With The Results:
"   -----------------------------------------------
"   *  "Space" : moves the cursor on the first result of the next buffer
"              (below the "-buffer_number:buffer_name" line)
"   *  "Enter" or "Control-j" :
"         -see the "J" key to enable or disable jump when pressing Enter,
"          and for some additional infos
"         -if the cursor is on a result line (which starts with a
"           line number) :
"           **if we have jump enabled :
"            -the window from where we called the ":Bs"
"            command will change to the buffer that corresponds to this
"            result (the buffer number is on first line searching backwards,
"            that starts with "-"), and put the cursor on this window,
"            to the position of the first character of the matched search
"           **if we have jump disabled :
"            -the window from where we called the ":Bs" command will
"            change to the buffer that corresponds to this result
"         -if the cursor is not on a result line, then it's quite the
"           same result as before, except that 
"           **if jump is enabled, the cursor position will be at the top 
"             of the file : line 1, column 1
"           **if jump is disabled, the buffer is displayed starting at
"             line 1, column 1 (without moving the cursor)
"   *  "J" : enables or disables jumping on the buffer when pressing
"            Enter or <C-j>; default is disabled
"            *This option can also be changed with the variable 
"            g:Bs_stay_on_buffer_results_when_entering_result
"            -if auto-show option is enabled, this
"             option has no effect, because when auto-show is enabled,
"             we always jump to the location when pressing Enter or <C-j>
"             See the "A" key for auto-show and more infos.
"   *  "A" : enables or disables auto-showing the context of the results;
"            default is enabled
"            *This option can also be changed with the variable g:Bs_auto_jump
"            -if this is enabled, when you press j or k, the last
"             window, from where you called ":Bs" will show you the
"             context of the result line under the cursor
"            -this option puts J to be enabled, to always jump when 
"            pressing Enter or <C-j>
"   *  "Q" : enables or disables auto-quitting the buffer results
"            when jumping with the cursor on a result; default is
"            disabled
"            *This option can also be changed with the variable
"            g:Bs_toggle_quit_enter
"   *  "O" : toggles between showing the value of the options or
"            showing the results (push O another time to make options
"            disappear)
"   *  "r" : refreshes the screen (in case of loosing syntax highlight
"            for example)
"   *  "u" : updates the search : replaces the current results with
"            the results of another search, with the same pattern
"   *  "i" : enables or disables the search match highlighting on the
"            buffer with the results; default is enabled
"            *This option can also be changed with the variable
"            g:Bs_results_buffer_match
"   *  "I" : enables or disables the search match highlighting on the
"            buffers that are not the buffer with the results;
"            default is enabled
"            *This option can also be changed with the variable
"            g:Bs_buffers_match
"   *  "x" : enables or disables "quite full screen"; default is
"            disabled
"            -resizes the buffer search results window to be quite
"             full screen, by leaving only some lines for other
"             buffers, in order to be able to view the context of the
"             results
"   *  "?" : toggles between showing help or showing results;default
"            is to show results (push ? another time to make help
"            disappear)
"            -when showing the help, a summary of the key maps is
"             printed in the buffer 
"   *  "q" : the q key deletes the buffer with the results
"
" }}}
" {{{ Contributions, Support, Bugs, ...
"
" Contributions Support Bugs:
"
" You can send any support question, bug reports, patches, ...
" to Alexandru Ionut Munteanu <io_alex_2002 [ AT ] yahoo.fr>
"  (just call me Alex; find me on freenode with nickname ion_bidon)
"
" }}}
" }}}

"""""""""""""""""""""""""""""""
" User settings
"""""""""""""""""""""""""""""""
"{{{ User variables
"if we stay on the buffer with the results when pressing enter
"-default is yes; disable this with J key in the buffer or by changing here at 0
if !exists("g:Bs_stay_on_buffer_results_when_entering_result")
  let g:Bs_stay_on_buffer_results_when_entering_result = 1
endif
"if auto-jump when moving in the buffer search or not
"it shows every time the context of the result;
"you can use enter to go to the result window
if !exists("g:Bs_auto_jump")
  let g:Bs_auto_jump = 1
endif
"set this to 1 if you want to quit the search results buffer when pressing
"enter, or push Q in the buffers search to enable/disable it
if !exists("g:Bs_toggle_quit_enter")
  let g:Bs_toggle_quit_enter = 0
endif
"set this to 0 if you don't want syntax highlight on the buffer with
"the results, or push i
if !exists("g:Bs_results_buffer_match")
  let g:Bs_results_buffer_match = 1
endif
"set this to 0 if you don't want syntax highlight on the other buffers
"(not the one with the results), or push I
if !exists("g:Bs_buffers_match")
  let g:Bs_buffers_match = 1
endif
"}}}
"{{{ User commands
" define user commands
function! s:Bs_define_user_commands()
  if !exists(':Bs')
    command! -nargs=1 Bs call s:Bs_search(<q-args>)
  endif
endfunction

"}}}
"{{{ Keys mapping in the buffer with the results
"defines the auto jump option mapping
function! s:Bs_auto_jump_mapping()
  "redefine <CR> and <C-j> to make a real jump,
  "if we have auto jump
  nnoremap <buffer> <silent> <C-j> :BsRealJump<CR>
  nnoremap <buffer> <silent> <CR> :BsRealJump<CR>
  "if we auto-jump define keys up and down to jump
  nnoremap <buffer> <silent> j j:BsJump<CR>
  nnoremap <buffer> <silent> k k:BsJump<CR>
endfunction

"defines the non auto-jump mappings
function s:Bs_non_auto_jump_mapping()
  nnoremap <buffer> <silent> <C-j> :BsJump<CR>
  nnoremap <buffer> <silent> <CR> :BsJump<CR>
endfunction

"defines the main key maps
function! s:Bs_keys_mapping()
	
  "<CR> and <C-j> have the same result
	"jumps to the buffer at the location of the phrase under cursor
  if g:Bs_auto_jump == 1
    call s:Bs_auto_jump_mapping()
  else
    call s:Bs_non_auto_jump_mapping()
  endif

  "space goes to the next buffer result
  nnoremap <buffer> <silent> <Space> :let Bsline=search("^-.*$","n") <CR> :call cursor(Bsline+1,7) <CR> :normal zz<CR>
  "q quits the buffer
  nnoremap <buffer> <silent> q :BsInitVariables<CR>:silent! bdel!<CR>:match<CR>
	"x toggles full screen or not
	nnoremap <buffer> <silent> x :BsToggleFullScreen<CR>
	"J activates the jump or deactivates it
	nnoremap <buffer> <silent> J :BsToggleJump<CR>
	"A auto-show (or jump, depending of J) to the files with the results
	nnoremap <buffer> <silent> A :BsToggleAutoJump<CR>
  "Q toggles buffers search window quit when pressing enter or <C-j>
  nnoremap <buffer> <silent> Q :BsToggleQuitWhenEnter<CR>
  "O shows the options (repush O to show results)
  nnoremap <buffer> <silent> O :BsToggleOptions<CR>
  "r redraws the screen with the results
  nnoremap <buffer> <silent> r :BsDrawResults<CR>
  "s searches again
  nnoremap <buffer> <silent> u :BsUpdateSearch<CR>
  "i toggles the highlight match on the results
  nnoremap <buffer> <silent> i :BsToggleResultsBufferMatch<CR>
  "I toggles the highlight match on the buffers (differets from the
  "results buffer)
  nnoremap <buffer> <silent> I :BsToggleBuffersMatch<CR>
  "H displays help (repush H to show results)
  nnoremap <buffer> <silent> ? :BsToggleHelp<CR>
	
	"dd deletes lines, by saving them and showing at the bottom
	""nnoremap <buffer> <silent> dd :BsDelResults<CR>

endfunction

"}}}
"{{{ Syntax highlight for the buffer with the results
function! s:Bs_syntax_highlight()
  
  "if we have the option to highlight matches in the results buffer
  if g:Bs_results_buffer_match == 1
    "syntax the search
    exe 'silent! mat Search /'.g:Bs_search.'/'
  endif
  
  "simple number highlight
  sy match buffers_nums "\d\+"
  hi def link buffers_nums Number

  "simple keywords
  ""sy keyword Clike if then else case break void char int long
  ""hi def link Clike Keyword

  "simple string highlight
  sy match ponctuation "\.\|?\|!\|\,\|;\|<\|>\|\~\|&\|="
  hi def link ponctuation Type
  
  "simple paranthesis highlight
  sy match paranthesis "(\|)\|\[\|\]\|{\|}"
  hi def link paranthesis NonText

  "simple string highlight
  sy region buffers_doubleq start='"' end='"\|$'
  sy region buffers_singleq start="'" end="'\|$"
  sy region buffers_backticks start="`" end="`\|$"
  hi def link buffers_doubleq String
  hi def link buffers_singleq String
  hi def link buffers_backticks String

  "left numbers
  sy match line_numbers "^\d\+"
  hi def link line_numbers LineNr

  "buffer titles
  sy match buffers_title "^\-.*$"
  hi def link buffers_title Title
 
endfunction

"}}}
"-----------------------------"
"""""""""""""""""""""""""""""""

"{{{ Definition of user commands
"avoid loading it twice
if exists("Bs_buffers_search")
  finish
else
  call s:Bs_define_user_commands()
endif
let Bs_buffers_search = 1
"}}}

"""""""""""""""""""""""""""""""
" Internal variables
"""""""""""""""""""""""""""""""
"{{{ Defines some internal variables
function! s:Bs_init_variables()
  "name of the results buffer
  let g:Bs_results_buffer_name = "Buffers_search_result"
  "the search that we entered
  let g:Bs_search = ""
  "the results of the search
  "results structure :
  "  { 'buffer1_number' : { 'line_number' : 'line_content' , 'line_number2' : 'line_content2' },
  "    'buffer2_number' : { 'line_number' : 'line_content' , 'line_number2' : 'line_content2' } }
  let g:Bs_results = {}
  "the deleted results
  let g:Bs_deleted_results = {}
  "the initial window where we were
  let g:Bs_initial_window_number = 1
  "the initial is not full screen
  let g:Bs_is_full_screen = 0
  "if we are showing help or not
  let g:Bs_on_help = 0
  "if we are showing the options or not
  let g:Bs_on_options = 0
  "if we refresh or update, we keep the old position
  let g:Bs_position = []
  "if we showed the results at least once
  let g:Bs_showed_results = 0
endfunction
call s:Bs_init_variables()

"}}}

"""""""""""""""""""""""""""""""
" Internal functions
"""""""""""""""""""""""""""""""
"Main functions
"{{{ s:Bs_delete_results()
"functions mapped by dd, for deleting results(lines) from the buffer
"TODO: multiple erase : 5dd for example
function! s:Bs_delete_results()
  let l:count = 1

  "we save the initial cursor position
  let l:initial_position = getpos(".")
 
  "we copy the deleted results here
  let l:old_deleted_res = g:Bs_deleted_results

  "we put the cursor on the start line
  "we get the buf number for the start line
  let l:line_buf_number = s:Bs_get_cur_buf_number()
  "we get the line number for the start line
  let l:line_line_number = s:Bs_get_cur_line_number()

  let l:result_line_content = g:Bs_results["-".l:line_buf_number]
  "we get the old deleted results
  if has_key(l:old_deleted_res,"-".l:line_buf_number)
    let l:old_del = l:old_deleted_res[l:line_line_number]
  else
    let l:old_del = {}
  endif
  let l:old_del[l:line_line_number] = l:result_line_content

  "we erase the data from the results
  call remove(g:Bs_results["-".l:line_buf_number],l:line_line_number)

  "we put the data in the deleted results
  let g:Bs_deleted_results[l:line_buf_number] = l:old_del

  "refresh view
  call s:Bs_show_results()

  "we restore the initial cursor position
  call setpos('.', l:initial_position)
 
endfunction

"}}}
"{{{ s:Bs_show_help()
function! s:Bs_show_help()
  "hm means help message
  let l:hm = "-Default key mappings :\n\n"
  let l:hm = l:hm."\"Space\"\t : moves the cursor on the first result of the next buffer\n"
  let l:hm = l:hm."\"Enter or Control-j\"\t : shows or jumps to the result under the cursor\n"
  let l:hm = l:hm."\"J\"\t : enables or disables jumping on the buffer when pressing Enter or Control-j\n"
  let l:hm = l:hm."\"A\"\t : enables or disables auto-showing the context of the results when pressing j or k\n"
  let l:hm = l:hm."\"Q\"\t : enables or disables auto-quitting the buffer results when jumping\n"
  let l:hm = l:hm."\"O\"\t : toggles between showing options or showing results\n"
  let l:hm = l:hm."\"r\"\t : refreshes the screen (in case you loose syntax hilighting)\n"
  let l:hm = l:hm."\"u\"\t : replaces this search with a newer one (with the same keyword)\n"
  let l:hm = l:hm."\"i\"\t : enables or disables the search match highlighting on the buffer with the results\n"
  let l:hm = l:hm."\"I\"\t : enables or disables the search match highlighting on the other buffers (not the buffer with the results)\n"
  let l:hm = l:hm."\"x\"\t : enables or disables quite-full-screen\n"
  let l:hm = l:hm."\"q\"\t : deletes the buffer with the results\n"
  let l:hm = l:hm."\"?\"\t : toggles between showing help or showing results\n\n"
  let l:hm = l:hm."For more info, read the full docs at the start of the file buffers_search.vim, or contact me.\n"
  let l:hm = l:hm."This program is free software, licensed under the GNU General Public License\n"
  let l:hm = l:hm."Copyright (c) 2007 : Alexandru Ionut Munteanu - io_alex_2002 AT yahoo.fr"

  call s:Bs_print_in_buffer(l:hm)
  call cursor(1,1)
endfunction

"}}}
"{{{ s:Bs_show_options()
"shows the options
function! s:Bs_show_options()
  "opts means options
  let l:opts = "-Options :\n\n"
  "J option
  let l:opts = l:opts."\"J\" - jumping on the buffer when pressing Enter : "
  if g:Bs_stay_on_buffer_results_when_entering_result == 0
    let l:opts = l:opts."\"enabled\"\n"
  else
    let l:opts = l:opts."\"disabled\"\n"
  endif
  "A option
  let l:opts = l:opts."\"A\" - auto-show result context : "
  if g:Bs_auto_jump == 1
    let l:opts = l:opts."\"enabled\"\n"
  else
    let l:opts = l:opts."\"disabled\"\n"
  endif
  "Q option
  let l:opts = l:opts."\"Q\" - auto-quit the buffer when jumping : "
  if g:Bs_toggle_quit_enter == 1
    let l:opts = l:opts."\"enabled\"\n"
  else
    let l:opts = l:opts."\"disabled\"\n"
  endif
  "i option
  let l:opts = l:opts."\"i\" - show match highlighting on the results buffer : "
  if g:Bs_results_buffer_match == 1
    let l:opts = l:opts."\"enabled\"\n"
  else
    let l:opts = l:opts."\"disabled\"\n"
  endif
  "I option
  let l:opts = l:opts."\"I\" - show match highlighting on the other buffers : "
  if g:Bs_buffers_match == 1
    let l:opts = l:opts."\"enabled\"\n"
  else
    let l:opts = l:opts."\"disabled\"\n"
  endif
  let l:opts = l:opts."\n"

  call s:Bs_print_in_buffer(l:opts)
  call cursor(1,1)
endfunction

"}}}
"{{{ s:Bs_jump()
"	jumps to the buffer under the cursor, at the exact position
"calculates the coords and calls Bs_jump_buffer
" if real_jump == 1, then we jump to the results; otherwise, we only
" show the context
function! s:Bs_jump(real_jump)
  "if we're not on options or help
  if g:Bs_on_options == 0 && g:Bs_on_help == 0
    let l:bs_line = s:Bs_get_cur_line_number()
    let l:bs_buf_number = s:Bs_get_cur_buf_number()
	  let [l:bs_line_number, l:bs_column]=searchpos(g:Bs_search,"n")
    call s:Bs_jump_buffer(l:bs_buf_number,l:bs_line,l:bs_column,a:real_jump)
  endif
endfunction

"}}}
"{{{ s:Bs_search(search) : calls Bs_search_buffers
function s:Bs_search(search)
  call s:Bs_search_buffers(a:search,0)
endfunction

"}}}
"{{{ s:Bs_update_search(search) : calls Bs_search_buffers
function! s:Bs_update_search(search)
  "we save cursor position
  let g:Bs_position = getpos('.')
  call s:Bs_search_buffers(a:search,1)
endfunction

"}}}
"{{{ s:Bs_refresh_search() : calls Bs_show_results
function! s:Bs_refresh_results()
  "we save cursor position
  let g:Bs_position = getpos('.')
  call s:Bs_show_results()
endfunction

"}}}
"{{{ s:Bs_search_buffers(search)
"search through the buffers and calls show_results
"after that, with the results found in the buffers
"
"results structure :
"  { 'buffer1_number' : { 'line_number' : 'line_content' , 'line_number2' : 'line_content2' },
"    'buffer2_number' : { 'line_number' : 'line_content' , 'line_number2' : 'line_content2' } }
" the second argument, research; if 1, don't change the origin of the
" window; if 0, change the origin
function! s:Bs_search_buffers(search,research)

	"we set the search string
	let g:Bs_search = a:search
	"initialise the empty results
	let g:Bs_results = {}
	"initialise the deleted results
	let g:Bs_deleted_results = {}
  
  "if we don't do a re-search
  if a:research == 0
	  "we save the initial window number
	  let g:Bs_initial_window_number = bufwinnr('%')
  endif

  "we save the initial cursor position
  let l:initial_position = getpos(".")
  
  "we iterate over the buffers
  "get the number of the last buffer
  let l:last_buffer_number = bufnr('$')
  let l:buffer_number = 1
  "we only search in the buffers once
  let l:searched_buffers = []
  "the name of the buffer at the start
  let l:start_buffer_number = bufnr('%')

  "the number of the Buffer search results
  let l:results_buffer_number = bufnr(g:Bs_results_buffer_name)
  
  while (l:buffer_number <= l:last_buffer_number)

    "if the buffer is listed
    if buflisted(l:buffer_number)

      "go to the buffer
      exe 'b '.l:buffer_number

      "skip the buffer search result buffer
      if l:buffer_number == l:results_buffer_number
        call add(l:searched_buffers,l:buffer_number)
        let l:buffer_number = l:buffer_number + 1
        if buflisted(l:buffer_number) 
          exe 'b '.l:buffer_number
        endif
      endif
  
      "move at the top
      normal gg
  
      "if we didn't already read this buffer
      if !s:Bs_is_in_list_int(l:searched_buffers,l:buffer_number)
  
        "we put the buffer in the list
        call add(l:searched_buffers,l:buffer_number)
  
        "we search over the current buffer
        let l:buffer_result = {}
        "we stock the searched lines
        let l:stocked_lines = []
        let l:total_lines = line("$$")
        while search(g:Bs_search,'',l:total_lines) > 0
          "we get the current line number
          let l:line_number = line('.')

          "if the line it's not stored
          if !s:Bs_is_in_list_int(l:stocked_lines,l:line_number)
            "we store it
            call add(l:stocked_lines,l:line_number)
            "we get the line content
            let l:line_content = getline(l:line_number)
            let l:buffer_result[l:line_number] = l:line_content
          endif
        endwhile "end search on the current buffer
        
        "if we have results,
        if (len(l:buffer_result) > 0)
          "we store the result for this buffer
          let g:Bs_results['-'.l:buffer_number] = l:buffer_result
        endif 
    
      endif "end is_in_list

    endif "end isbuflisted

    "increment our counter
    let l:buffer_number = l:buffer_number + 1

  endwhile "end iteration over the buffers

  "go to the buffer from start
  exe 'b '.l:start_buffer_number
  "we restore the initial cursor position
  call setpos('.', l:initial_position)
  
  "if we have results,
  if (len(g:Bs_results) > 0)
    "we show the results
    call s:Bs_show_results()
  else
    "if we have the Buffer search window, delete this buffer 
    let l:results_buffer_number = s:Bs_get_go_buffer(g:Bs_results_buffer_name)
    "change to the search results buffer
    exe 'b '.l:results_buffer_number
    "we verify if the current buffer is the right one
    if bufname('%') =~ g:Bs_results_buffer_name
      "we delete it
      bdel!
    endif
    "center the cursor in the old buffer
    normal z.
  endif

endfunction

"}}}
"{{{ s:Bs_jump_buffer(...)
"jumps to a line into a buffer
function! s:Bs_jump_buffer(...)
  let l:buffer_number = a:1
  let l:buffer_line = str2nr(a:2)
  let l:buffer_column = str2nr(a:3)
  "if we are really jumping or not
  let l:real_jump = str2nr(a:4)

	"we keep the results buffer number
	let l:results_buffer_window_number = bufwinnr('%')
	"we save the position in the results buffer
  let l:results_buffer_position = getpos(".")
  
  if l:buffer_line == 0
    let l:buffer_line = 1
  endif
  
  "don't count the ^\d+\s+: at the end of the line
  let l:buffer_column=l:buffer_column - 7
  if l:buffer_column == 0
    let l:buffer_column = 1
  endif
	
  "change the window - go to the initial window
  exe g:Bs_initial_window_number.' wincmd w'
  "change the buffer
  exe 'b '.l:buffer_number
  "go to the line
  call cursor(l:buffer_line,l:buffer_column)
	"put in the center of the screen
	normal zz
	let l:current_line = getline('.')

  "open eventual folding
  exe 'silent! foldopen'
  exe 'silent! foldopen'

  "match the search in the new buffer
  if g:Bs_buffers_match == 1
    exe 'silent! match Search /'.g:Bs_search.'/'
    redraw
  else
    exe 'match'
  endif

	"if we stay in the buffer with the searches
	if g:Bs_stay_on_buffer_results_when_entering_result == 1
    "if we don't necessary jump
    if l:real_jump == 0
		  exe l:results_buffer_window_number.' wincmd w'
		  "restore the position in the buffer search
  	  call setpos('.', l:results_buffer_position)
    else
      "if we close the buffers search
      if g:Bs_toggle_quit_enter == 1
        exe l:results_buffer_window_number.' wincmd w'
        normal q
      endif
    endif
  else
    "when jumping on another buffer,
    "if we close the buffers search
    if g:Bs_toggle_quit_enter == 1
		  exe l:results_buffer_window_number.' wincmd w'
      normal q
    endif
	endif

  "blink the result ?
  "sleep 300m
  "exe 'mat Search /sdsdsdjldlfzheazehaozdsdqshoidf/'

endfunction

"}}}
"{{{ s:Bs_numerical_line_sort(i1,i2)
"function for sorting the lines
function! s:Bs_numerical_line_sort(i1,i2)
  "ln means line number
  let l:ln1 = str2nr(split(a:i1,':')[0])
  let l:ln2 = str2nr(split(a:i2,':')[0])
  
  return l:ln1 == l:ln2 ? 0 : l:ln1 > l:ln2 ? 1 : -1
endfunction

"}}}
"{{{ s:Bs_numerical_buffer_sort(i1,i2)
"function for sorting the buffers
function! s:Bs_numerical_buffer_sort(i1,i2)
  "bn means buf number
  let l:bn1 = str2nr(strpart(a:i1,1))
  let l:bn2 = str2nr(strpart(a:i2,1))
  
  return l:bn1 == l:bn2 ? 0 : l:bn1 > l:bn2 ? 1 : -1
endfunction

"}}}
"{{{ s:Bs_process_results() : returns string_result
"processes the results and returns a String
"with the representation of the results
function! s:Bs_process_results(results)

  let l:string_result = ""

  "for each buffer, we show the results
  let l:number_of_buffers = len(a:results)
  for l:buffer_number in sort(keys(a:results),"s:Bs_numerical_buffer_sort")

    "we get the results of this buffer
    let l:buffer_results = a:results[l:buffer_number]
    "we get the buffer name
    let l:buffer_name = bufname(str2nr(strpart(buffer_number,1)))
    "we print the buffer number
    let l:string_result = l:string_result.l:buffer_number.":"
    "we print the buffer name
    let l:string_result = l:string_result.l:buffer_name."\n"

    "we iterate over the results of this buffer
    for l:result_line in sort(keys(l:buffer_results),"s:Bs_numerical_line_sort")
      let l:result_line_content = l:buffer_results[l:result_line]
      "we print line_number and line_content
      let l:line_number_content = printf('%-4s : %s',l:result_line,l:result_line_content)
      let l:string_result = l:string_result.l:line_number_content."\n"
    endfor
    "put a space
    let l:string_result = l:string_result."\n"

  endfor
  
  return l:string_result

endfunction

"}}}
"{{{ s:Bs_show_results()
function! s:Bs_show_results()
  
  "we process the results
  let l:print_content = s:Bs_process_results(g:Bs_results)
  "the deleted content
  let l:deleted_content = s:Bs_process_results(g:Bs_deleted_results)
  ""let l:print_content = l:print_content ."*** DELETED ***\n".l:deleted_content

  call s:Bs_print_in_buffer(l:print_content)
  
  "if it's not the first time that we show results
  if g:Bs_showed_results == 1
    "we put back cursor position
    call setpos('.',g:Bs_position)
  else
    "go at the start
    call cursor(2,7)
  endif

  "define buffer mappings + highlight
  call s:Bs_keys_mapping()
  call s:Bs_syntax_highlight()
  
  "if we have auto jump, jump !
  if g:Bs_auto_jump == 1
    call s:Bs_jump(0)
  endif
 
  let g:Bs_showed_results = 1

endfunction

"}}}
"{{{ s:Bs_print_in_buffer(print_content)
"shows the results of the search
function! s:Bs_print_in_buffer(print_content)
  
  "if the search results buffer already exists
  let l:results_buffer_number = s:Bs_get_go_buffer(g:Bs_results_buffer_name)
  "we should be on the results buffer now
  
  "we verify that the current buffer is the correct one
  if bufname('%') =~ g:Bs_results_buffer_name
    
    "set the buffer modifiable
    setlocal modifiable
  
    "we erase the buffer
    silent! 1,$ d
    "we put the results
    silent! put! = a:print_content
    "erase the last line
    $ d d
      
    "no number at left
    setlocal nonumber
		"underline the line under the cursor
		setlocal cursorline
    "don't ask for saving buffer at exit, etc..
    setlocal buftype=nowrite
  
    "set the buffer as non modifiable
    setlocal nomodifiable
    
  endif "end verify if it's the currect buffer

  redraw

endfunction

"}}}

"Utils functions
"{{{ s:Bs_get_cur_buf_number() : returns the current result buffer number
function! s:Bs_get_cur_buf_number()
  let l:bs_num = getline(search("^-.*:","nb"))
  let l:bs_buf_number=strpart(strpart(l:bs_num,1),0,stridx(l:bs_num,":")-1)
  return l:bs_buf_number
endfunction

"}}}
"{{{ s:Bs_get_cur_line_number() : returns the current result line number
function! s:Bs_get_cur_line_number()

  let l:bs_line = 1
  if strpart(getline('.'),0,1) == '-'
    let l:bs_line = 1
  else
    if getline('.') == ""
      let l:bs_line = 1
    else
      let l:str_line = split(getline('.'),':')[0]
	    let l:bs_line=str2nr(l:str_line)
    endif
  endif

  return l:bs_line
endfunction

"}}}
"{{{ s:Bs_toggle_results_buffer_match()
"command to enable/disable results buffer highlight match
function! s:Bs_toggle_results_buffer_match()
  if g:Bs_results_buffer_match == 1
    let g:Bs_results_buffer_match = 0
    exe 'match'
  else
    let g:Bs_results_buffer_match = 1
    exe 'silent! mat Search /'.g:Bs_search.'/'
  endif
  "if we are on the option screen, refresh
  if g:Bs_on_options == 1
    call s:Bs_show_options()
  endif
endfunction

"}}}
"{{{ s:Bs_toggle_buffers_match()
"command to enable/disable regular buffers highlight match
function! s:Bs_toggle_buffers_match()
  if g:Bs_buffers_match == 1
    let g:Bs_buffers_match = 0
  else
    let g:Bs_buffers_match = 1
  endif
  call s:Bs_jump(0)
  "if we are on the option screen, refresh
  if g:Bs_on_options == 1
    call s:Bs_show_options()
  endif
endfunction

"}}}
"{{{ s:Bs_toggle_help()
function! s:Bs_toggle_help()
  if g:Bs_on_help == 1
    let g:Bs_on_help = 0
    call s:Bs_show_results()
  else
    "we save cursor position
    let g:Bs_position = getpos('.')
    let g:Bs_on_help = 1
    call s:Bs_show_help()
  endif
endfunction

"}}}
"{{{ s:Bs_toggle_options()
function! s:Bs_toggle_options()
  if g:Bs_on_options == 1
    let g:Bs_on_options = 0
    call s:Bs_show_results()
  else
    "we save cursor position
    let g:Bs_position = getpos('.')
    let g:Bs_on_options = 1
    call s:Bs_show_options()
  endif
endfunction

"}}}
"{{{ s:Bs_toggle_full_screen()
function! s:Bs_toggle_full_screen()
	"if we are in full screen
	if g:Bs_is_full_screen == 1
		let g:Bs_is_full_screen = 0
		resize 15
	else
		"if we are not in full screen
		resize
		resize -6
		let g:Bs_is_full_screen = 1
	endif
endfunction

"}}}
"{{{ s:Bs_toggle_jump()
function! s:Bs_toggle_jump()
	if g:Bs_stay_on_buffer_results_when_entering_result == 0
    let g:Bs_stay_on_buffer_results_when_entering_result = 1
	else
    if g:Bs_auto_jump == 0
		  let g:Bs_stay_on_buffer_results_when_entering_result = 0
    endif
	endif 
  "if we are on the option screen, refresh
  if g:Bs_on_options == 1
    call s:Bs_show_options()
  endif
endfunction

"}}}
"{{{ s:Bs_toggle_auto_jump()
function! s:Bs_toggle_auto_jump()
	if g:Bs_auto_jump == 0
		let g:Bs_auto_jump = 1
    "we disable jump when entering result
    if g:Bs_stay_on_buffer_results_when_entering_result == 0
		  let g:Bs_stay_on_buffer_results_when_entering_result = 1
    endif
    call s:Bs_auto_jump_mapping()
	else
		let g:Bs_auto_jump = 0
		unmap <buffer> <silent> k
		unmap <buffer> <silent> j
    call s:Bs_non_auto_jump_mapping()
	endif 
  "if we are on the option screen, refresh
  if g:Bs_on_options == 1
    call s:Bs_show_options()
  endif
endfunction

"}}}
"{{{ s:Bs_toggle_quit_when_enter()
function! s:Bs_toggle_quit_when_enter()
	if g:Bs_toggle_quit_enter == 0
		let g:Bs_toggle_quit_enter = 1
	else
    let g:Bs_toggle_quit_enter = 0
	endif 
  "if we are on the option screen, refresh
  if g:Bs_on_options == 1
    call s:Bs_show_options()
  endif
endfunction

"}}}
"{{{ s:Bs_get_go_buffer(buffer_name) : returns buffer_number
"checks if the results buffer already exists
"if it does not exists, it creates one
"returns the number of the buffer
"-we also go on that buffer
function! s:Bs_get_go_buffer(buffer_name)

  let l:buffer_number = bufnr(a:buffer_name)
  "if the buffer does not exists
  if l:buffer_number == -1
    "we create it
    let l:buffer_number = bufnr(a:buffer_name,1)
    "we split and go on it
    exe 'bo sp '.a:buffer_name
    exe 'resize 15'
  else
    "if the buffer is not visible, show it
    if bufwinnr(l:buffer_number) == -1
      exe 'bo sp '.a:buffer_name
      exe 'resize 15'
    endif
  endif
	
	"we get the window number
	let l:window_number = bufwinnr(l:buffer_number)
	"and we go on that window
	exe l:window_number.' wincmd w'

  return l:buffer_number

endfunction

"}}}
"{{{ s:Bs_is_in_list_int(list,name) : returns 1 if int is in list
"checks if int is in list
function! s:Bs_is_in_list_int(list,int)
  
  let l:list_length = len(a:list)

  if l:list_length > 0
    for pos in range(0,l:list_length-1)
      if a:list[pos] == a:int
        return 1
      endif
    endfor
  endif

  return 0

endfunction

"}}}

"Internally-used defined commands
"{{{ Internal-used commands

"define BsInitVariables command
if !(exists(":BsInitVariables"))
	command -nargs=0 BsInitVariables :silent call s:Bs_init_variables()
endif
"define BsJump command
if !(exists(":BsDelResults"))
	command -nargs=0 BsDelResults :silent call s:Bs_delete_results()
endif
"define BsJump command
if !(exists(":BsJump"))
	command -nargs=0 BsJump :silent call s:Bs_jump(0)
endif
"define BsRealJump command - this command ensures that we jump,
"instead of only showing the result, whatever the settings
if !(exists(":BsRealJump"))
	command -nargs=0 BsRealJump :silent call s:Bs_jump(1)
endif
"command to activate deactivate jump
if !(exists(":BsToggleJump"))
	command -nargs=0 BsToggleJump :silent call s:Bs_toggle_jump()
endif
"command to auto jump or not jump
if !(exists(":BsToggleAutoJump"))
	command -nargs=0 BsToggleAutoJump :silent call s:Bs_toggle_auto_jump()
endif
"command to auto jump or not jump
if !(exists(":BsToggleQuitWhenEnter"))
	command -nargs=0 BsToggleQuitWhenEnter :silent call s:Bs_toggle_quit_when_enter()
endif
"command to activate deactivate jump
if !(exists(":BsToggleFullScreen"))
	command -nargs=0 BsToggleFullScreen :silent call s:Bs_toggle_full_screen()
endif
"command to display help
if !(exists(":BsToggleHelp"))
	command -nargs=0 BsToggleHelp :silent call s:Bs_toggle_help()
endif
"command to show options
if !(exists(":BsToggleOptions"))
	command -nargs=0 BsToggleOptions :silent call s:Bs_toggle_options()
endif
"command to refresh the results screen
if !(exists(":BsDrawResults"))
	command -nargs=0 BsDrawResults :silent call s:Bs_refresh_results()
endif
"command to research
if !(exists(":BsUpdateSearch"))
	command -nargs=0 BsUpdateSearch :silent call s:Bs_update_search(g:Bs_search)
endif
"command to enable/disable buffer search highlight match
if !(exists(":BsToggleResultsBufferMatch"))
	command -nargs=0 BsToggleResultsBufferMatch :silent call s:Bs_toggle_results_buffer_match()
endif
"command to enable/disable regular buffers highlight match
if !(exists(":BsToggleBuffersMatch"))
	command -nargs=0 BsToggleBuffersMatch :silent call s:Bs_toggle_buffers_match()
endif

"}}}

" vim:ft=vim:fdm=marker:ff=unix:nowrap:tabstop=2:shiftwidth=2
