scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let g:neocomplete#sources#rubymf#enable = get(g:, "neocomplete#sources#rubymf#enable", 1)

let s:source = {
  \  "name"      : "rubymf",
  \  "filetypes" : { "ruby"  : 1 },
  \  "kind"      : "manual",
  \ }

function! s:source.get_complete_position(context)
  if g:neocomplete#sources#rubymf#enable == 0
    return -1
  endif
  let pattern = '^\s*[^.[:space:]][^.]*\.\zs\w*$'
  if a:context.input !~ pattern
    return -1
  endif
  return col('.') - len(matchstr(a:context.input, pattern)) - 1
endfunction

let s:cache = {}

function! s:source.gather_candidates(context)
  let pos = line(".") . "_" . a:context.complete_pos
  if has_key(s:cache, pos)
    return s:cache[pos]
  endif

  let line = getline('.')
  let input_obj = matchstr(line, '^\s*\zs[^.]\+\ze\..*#=>')
  let output_obj = matchstr(line, '#=>\s*\zs\S.*$')

  let mf = s:find_method_by_method_finder(input_obj, output_obj)

  let s:cache[pos] = map(mf, "{
    \ 'word' : v:val,
    \ 'menu' : '[rubymf]',
    \ 'kind' : 'm',
    \ }")

  return s:cache[pos]
endfunction

function! s:find_method_by_method_finder(input_obj, output_obj)
  let mf0 = neocomplete#system('ruby -rmethodfinder',
    \ printf("puts MethodFinder.find(%s, %s)", a:input_obj, a:output_obj))

  let mf1 = split(mf0, "\n")

  return map(mf1, 'matchstr(v:val, ''#\zs.*'')')
endfunction

augroup rubymf-neocomplete
  autocmd!
  autocmd InsertLeave * let s:cache = {}
augroup END

function! neocomplete#sources#rubymf#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
