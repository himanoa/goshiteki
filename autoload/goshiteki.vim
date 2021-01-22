let g:loaded_goshiteki = 1
let s:script_dir = expand('<sfile>:p:h') . '/../commands/'
let s:pr_id = ''
let s:base_branch = ''
let s:start_position = 0
let s:end_position = 0

function! g:goshiteki#start_review() abort
  let l:current_branch = trim(system('git symbolic-ref --short HEAD'))
  let l:origin_url = trim(system('git remote get-url origin'))

  if match(l:origin_url, '^git[@:]') !=# -1
    let [l:owner, l:name] = split(matchstr(trim(system('git remote get-url origin')), ':.*/.*\.git$')[1:-5], '/')
  else
    let [l:owner, l:name] = split(matchstr(trim(system('git remote get-url origin')), '/.*/.*$')[1:], '/')
  endif

  let l:pr = systemlist([s:script_dir . 'pr-id.sh', l:owner, l:name, l:current_branch])
  if v:shell_error != 0
    echoerr l:pr[0]
    return
  endif

  let [s:pr_id, s:base_branch] = l:pr
  echo s:base_branch
endfunction

function! g:goshiteki#add_review_comment() range abort
  let s:add_review_comment_tempname = tempname()
  let s:git_root = trim(system(['git', 'rev-parse', '--show-toplevel'])) . '/'
  let s:git_dir = getenv('GIT_DIR')
  if s:git_dir == 0
    let s:git_dir = '.git'
  endif

  let s:absolute_current_file_path = expand('%:p')
  let s:relative_file_path_from_git_root = split(s:absolute_current_file_path, s:git_root)[0]

  let s:start_position = a:firstline
  let s:end_position = a:lastline
  let s:start_position = line('.')

  execute 'split ' . s:add_review_comment_tempname
  set filetype=markdown

  au BufHidden <buffer> :call g:goshiteki#post_write_review_comment(s:relative_file_path_from_git_root, s:start_position, s:end_position, s:add_review_comment_tempname, s:base_branch)
endfunction

function! g:goshiteki#post_write_review_comment(relative_path_from_git_root, start_position, end_position, comment_file_name, output_json) abort
  let l:comment = join(readfile(a:comment_file_name), "\n")
  let result = system([s:script_dir . 'review-comments.sh', a:relative_path_from_git_root, a:start_position, a:end_position, l:comment, a:output_json, s:base_branch])
  echo result

  " Clean up position variables
  let s:start_position = 0
  let s:end_position = 0
endfunction

function! g:goshiteki#submit_reviews(status) abort
  let s:goshiteki_review_status = a:status
  let s:submit_review_tempname = tempname()

  execute 'split ' . s:submit_review_tempname

  au BufHidden <buffer> :call g:goshiteki#post_submit(s:goshiteki_review_status, s:submit_review_tempname, s:pr_id)
endfunction

function! g:goshiteki#post_submit(status, tempname, pr_id) abort
  let l:body = ''
  if filereadable(a:tempname)
    let l:body = join(readfile(a:tempname), "\n")
  endif
  call system([s:script_dir . 'submit-review.sh', a:pr_id, l:body, a:status, s:git_root . s:git_dir . '/REVIEW_COMMENT_STATE'])
  echo 'Submit review(status: ' . a:status . ')'
endfunction

function! g:goshiteki#target() abort
  call setqflist([], ' ', {'lines': systemlist([s:script_dir . 'target.sh', s:base_branch])}) | cw
endfunction
