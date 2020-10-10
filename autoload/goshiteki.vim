scriptencoding utf-8
if exists('g:loaded_goshiteki')
  finish
endif

let g:loaded_goshiteki = 1
let s:script_dir = expand('<sfile>:p:h') . '/../commands/'

function! g:goshiteki#start_review() abort
  let l:current_branch = system("git symbolic-ref --short HEAD")
  let l:origin_url = trim(system("git remote get-url origin"))
  let l:owner_and_name = ""

  if matchstr(l:origin_url, "^git@")
    let l:owner_and_name = split(matchstr(trim(system("git remote get-url origin")), ":.*/.*\.git$")[1:-5], '/')
  else
    let l:owner_and_name = split(matchstr(trim(system("git remote get-url origin")), "/.*/.*$")[1:], '/')
  endif

  let l:owner = l:owner_and_name[-2]
  let l:name = l:owner_and_name[-1]

  return system([s:script_dir . 'pr-id.sh', trim(l:owner), trim(l:name), trim(l:current_branch)])
endfunction

function! g:goshiteki#add_review_comment() abort

endfunction

function! g:goshiteki#submit_reviews() abort

endfunction
