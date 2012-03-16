scriptencoding utf-8

function! unite#sources#moo#define()
	return s:source
endfunction

let s:source = {
\	"name" : "moo",
\	"description" : "スーパー牛さんパワー",
\	"moo__counter" : 0
\}

function! s:source.async_gather_candidates(args, context)
	let a:context.source.unite__cached_candidates = []
	let space = repeat(" ", self.moo__counter)

	let result = [
\'             (__)                                ',
\'             (oo)                                ',
\'       /------\/                                 ',
\'      / |    ||                                  ',
\'     *  /\---/\                                  ',
\'        ~~   ~~                                  ',
\    ]
	
	let self.moo__counter += 1
	if self.moo__counter > winwidth("%")
		let self.moo__counter = 0
	endif
	return map(result, '{
\		"word" : (space.v:val)[20 : winwidth("%")+5]
\	}') + [{ "word" : '    ...."Have you mooed today?"...' }]
endfunction



