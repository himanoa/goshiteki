scriptencoding utf-8
if exists('g:loaded_goshiteki')
  finish
endif

let g:loaded_goshiteki = 1

function! g:goshiteki#start_review() abort
  let l:script_dir = expand('<sfile>:p:h') . '/../commands/'
  let l:current_branch = system("git symbolic-ref --short HEAD")
  let l:owner_and_name = split(matchstr(trim(system("git remote get-url origin")), ":.*/.*\.git$")[1:-5], '/')
  let l:owner = owner_and_name[0]
  let l:name = owner_and_name[1]

  return system([l:script_dir . 'pr-id.sh', owner, name, current_branch])
endfunction

function! g:goshiteki#add_review_comment() abort

endfunction

function! g:goshiteki#submit_reviews() abort

endfunction
