let g:FtEvalCommand = {
      \   'scheme' : 'system("gosh"  , "(display (begin\n" . a:expr . "\n))")', 
      \   'gauche' : 'system("gosh"  , "(display (begin\n" . a:expr . "\n))")', 
      \   'gosh'   : 'system("gosh"  , "(display (begin\n" . a:expr . "\n))")', 
      \   'perl'   : 'system("perl"  , "print eval{use Data::Dumper;$Data::Dumper::Terse = 1;$Data::Dumper::Indent = 0;Dumper " . a:expr . " }")',
      \   'python' : 'system("python", "print(" . a:expr . ")")', 
      \   'ruby'   : 'system("ruby " , "p proc {\n" . a:expr . "\n}.call")', 
      \   'vim'    : 'eval(a:expr)', 
      \ }

function g:FtEval(expr, filetype)
  unlet! g:FtEvalResult
  let g:FtEvalResult = eval(a:filetype !~ '\S' ? g:FtEvalCommand[&filetype]
        \                                      : g:FtEvalCommand[a:filetype])
  return g:FtEvalResult
endfunction

function <SID>GetVisualText()
  let p0 = getpos('''<')
  let p1 = getpos('''>')

  if p0[1] == p1[1]
    return getline(p0[1])[ p0[2] - 1 : p1[2] - 1 ]
  endif
  return join([ getline(p0[1])[ p0[2] - 1 : ] ] +  getline(p0[1] + 1, p1[1] - 1) +
        \     [ getline(p1[1])[ : p1[2] - 1 ] ] , "\n")
endfunction

command -narg=? -range FtEvalLine   echo g:FtEval(getline('.'),                <q-args>)
command -narg=? -range FtEvalBuffer echo g:FtEval(join(getline(0, '$'), "\n"), <q-args>)
command -narg=? -range FtEvalVisual echo g:FtEval(<SID>GetVisualText(),        <q-args>)

nnoremap <Space>e :FtEvalLine<CR>
nnoremap <Space>E :FtEvalBuffer<CR>
vnoremap <Space>e :FtEvalVisual<CR>
vnoremap <Space>E :FtEvalVisual vim<CR>
