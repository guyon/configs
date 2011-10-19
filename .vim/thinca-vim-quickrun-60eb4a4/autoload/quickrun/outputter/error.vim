" quickrun: outputter: error
" Author : thinca <thinca+vim@gmail.com>
" License: Creative Commons Attribution 2.1 Japan License
"          <http://creativecommons.org/licenses/by/2.1/jp/deed.en>

let s:save_cpo = &cpo
set cpo&vim

let s:outputter = quickrun#outputter#buffered#new()
let s:outputter.config = {
\   'success': 'null',
\   'error': 'null',
\ }
let s:outputter.config_order = ['success', 'error']

function! s:outputter.finish(session)
  let outputter = a:session.make_module('outputter',
  \   self.config[a:session.exit_code ? 'error' : 'success'])
  call outputter.output(self._result, a:session)
  call outputter.finish(a:session)
endfunction


function! quickrun#outputter#error#new()
  return deepcopy(s:outputter)
endfunction

let &cpo = s:save_cpo
