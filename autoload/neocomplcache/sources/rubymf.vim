let s:source = {
      \ 'name': 'rubymf',
      \ 'kind' : 'ftplugin',
      \ 'filetypes': {'ruby': 1},
      \ }

function! s:source.initialize()
  call neocomplcache#set_completion_length('rubymf', 1)
endfunction

function! s:source.finalize()
endfunction

function! s:source.get_keyword_pos(cur_text)
  if a:cur_text =~ '\.$' "&& getline('.') =~ '#=> .\+$'
    "echomsg string(['pos', getpos('.')[2] - 1])
    return 0
    return getpos('.')[2]
  end
  return -1
endfunction

function! s:source.get_complete_words(cur_keyword_pos, cur_keyword_str)
  let input_obj = a:cur_keyword_str[:-2] "matchstr(a:cur_keyword_str, '^.\{-}\. #=> ')[0:-7]
  let output_obj = getline('.')[5:] "matchstr(a:cur_keyword_str, '#=> .\+$')[4:]
  "echomsg string(['input/output objs', input_obj, output_obj])
  if input_obj ==# '' || output_obj ==# ''
    return []
  endif
  let mf0 = neocomplcache#system(
        \ 'ruby -rmethodfinder',
        \ printf("puts MethodFinder.find(%s, %s)", input_obj, output_obj))
  let mf1 = split(mf0, "\n")
  return map(mf1, "{'word': '" . a:cur_keyword_str . "' . v:val, 'menu': '[rubymf]'}")
endfunction

function! neocomplcache#sources#rubymf#define()
  " TODO: make sure if you have methodfinder
  return s:source
endfunction

function! s:last_matchend(str, pat)
  let l:idx = matchend(a:str, a:pat)
  let l:ret = 0
  while l:idx != -1
    let l:ret = l:idx
    let l:idx = matchend(a:str, a:pat, l:ret)
  endwhile
  return l:ret
endfunction
