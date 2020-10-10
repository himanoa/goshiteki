scriptencoding utf-8
if exists('g:loaded_goshiteki')
  finish
endif

let g:loaded_goshiteki = 1

command! GoshitekiStart call goshiteki#start_review()
command! GoshitekiLineComment call goshiteki#add_review_comment()
command! GoshitekiApprove call goshiteki#submit_reviews("APPROVE")
command! GoshitekiComment call goshiteki#submit_reviews("COMMENT")
command! GoshitekiRequestChanges call goshiteki#submit_reviews("REQUEST_CHANGES")
