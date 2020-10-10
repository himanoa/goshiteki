scriptencoding utf-8
if exists('g:loaded_goshiteki')
  finish
endif

let g:loaded_goshiteki = 1
let s:script_dir = expand('<sfile>:p:h') . '/../commands/'
let s:review_comment_state_path = ""
let s:pr_id = ""

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

  let s:pr_id =  system([s:script_dir . 'pr-id.sh', trim(l:owner), trim(l:name), trim(l:current_branch)])
endfunction

function! g:goshiteki#add_review_comment() abort
  let s:tempname = tempname()
  let s:git_root = trim(system(['git', 'rev-parse', '--show-toplevel'])) . '/'
  let s:absolute_current_file_path = expand('%:p')
  let s:relative_file_path_from_git_root = split(s:absolute_current_file_path, s:git_root)[0]

  echo(split(s:git_root, s:absolute_current_file_path))
  let s:position = line(".")

  execute 'split ' . s:tempname

  au BufHidden <buffer> :call g:goshiteki#post_write_review_comment(s:relative_file_path_from_git_root, s:position, s:tempname, s:review_comment_state_path)
endfunction

function! g:goshiteki#post_write_review_comment(relative_path_from_git_root, position, comment_file_name, output_json) abort
  let l:comment = join(readfile(a:comment_file_name), "\n")
  let s:review_comment_state_path = system([s:script_dir . 'review-comments.sh', a:relative_path_from_git_root, a:position, l:comment, a:output_json])
endfunction

function! g:goshiteki#submit_reviews() abort

endfunction
