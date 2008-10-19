" lhs comments
vmap ,# :s/^/#/<CR>:nohlsearch<CR>
vmap ,/ :s/^/\/\//<CR>:nohlsearch<CR>
vmap ,> :s/^/> /<CR>:nohlsearch<CR>
vmap ," :s/^/\"/<CR>:nohlsearch<CR>
vmap ,% :s/^/%/<CR>:nohlsearch<CR>
vmap ,! :s/^/!/<CR>:nohlsearch<CR>
vmap ,; :s/^/;/<CR>:nohlsearch<CR>
vmap ,- :s/^/--/<CR>:nohlsearch<CR>
vmap ,c :s/^\/\/\\|^--\\|^> \\|^[#"%!;]//<CR>:nohlsearch<CR>

" wrapping comments
vmap ,* :s/^\(.*\)$/\/\* \1 \*\//<CR>:nohlsearch<CR>
vmap ,( :s/^\(.*\)$/\(\* \1 \*\)/<CR>:nohlsearch<CR>
vmap ,< :s/^\(.*\)$/<!-- \1 -->/<CR>:nohlsearch<CR>
vmap ,d :s/^\([/(]\*\\|<!--\) \(.*\) \(\*[/)]\\|-->\)$/\2/<CR>:nohlsearch<CR> 
" Asano�ǉ� coldfusion��s�R�����g�A�E�g
vmap ,cf :s/^\(.*\)$/<!--- \1 --->/<CR>:nohlsearch<CR>
" Asano�ǉ� JSP��s�R�����g�A�E�g�ƃR�����g����
vmap ,jl :s/^\(.*\)$/<%-- \1 --%>/<CR>:nohlsearch<CR>
vmap ,jd :s/^\([/(]\*\\|<%--\) \(.*\) \(\*[/)]\\|--%>\)$/\2/<CR>:nohlsearch<CR> 

" block comments
vmap ,b v`<I<CR><esc>k0i/*<ESC>`>j0i*/<CR><esc><ESC>
vmap ,h v`<I<CR><esc>k0i<!--<ESC>`>j0i--><CR><esc><ESC>

" Asano�ǉ� coldfusion�����s�s�R�����g�A�E�g
vmap ,z v`<I<CR><esc>k0i<!---<ESC>`>j0i---><CR><esc><ESC>
vmap ,jc v`<I<CR><esc>k0i<%--<ESC>`>j0i--%><CR><esc><ESC>
