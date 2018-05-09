" make the plugins under /bundles work
execute pathogen#infect()

" TODO: Use named constant for 1524891851
" TODO: Split into a plugin / bundle
" hack because termux cursor is always
" a single color, so at least this way
" we can set the ctermfg
function! s:Highlight_Char_Under_Cursor()
  silent! call matchdelete(1524891851)
  if pumvisible() || (&t_Co < 8 && !has("gui_running"))
    return
  endif
  let c_lnum = line('.')
  let c_col = col('.')

  call matchaddpos('CharUnderCursor', [[c_lnum, c_col]], 11, 1524891851)
endfunction

function! s:No_Highlight_Char_Under_Cursor()
  silent! call matchdelete(1524891851)
endfunction

augroup cursor_highlight
  autocmd!
  autocmd InsertEnter * call s:No_Highlight_Char_Under_Cursor()
  " hack to turn the cursor fully invisible
  " when in Normal mode, this lets us implement
  " the cursor purely using the background colour.
  " * Doesn't work when you exit insert mode via
  " <C-c>
  autocmd VimEnter * let &t_ve=''
  autocmd VimLeave * let &t_ve="\<Esc>[?25h"
  autocmd InsertEnter * let &t_ve="\<Esc>[?25h"
  autocmd InsertLeave * let &t_ve=''
  autocmd CmdLineEnter * let &t_ve="\<Esc>[?25h"
  autocmd CmdLineLeave * let &t_ve=''
  autocmd CursorMoved,InsertLeave,WinEnter * call s:Highlight_Char_Under_Cursor()
  " hack to temporarily toggle cursor on <C-z>
  nnoremap <silent> <C-z> :let &t_ve="\033[?25h"<CR><C-z>:let &t_ve=''<CR>
augroup END

" Set IBeam shape in insert mode
let &t_SI = "\<Esc>[6 q"
" Underline shape in replace mode
let &t_SR = "\<Esc>[4 q"
" Set IBeam shape in normal mode
" (closest thing to invisible that still works
" in the command line)
"     let &t_EI = "\<Esc>[?25h"
" doesn't seem to work, presumably it is being
" overridden by something.. &v_te(?)
let &t_EI = "\<Esc>[6 q" 

" Remove delay when escaping insert mode
" also has other effects that I don't understand
" at the moment.. if something is strange it could
" be caused by this.
set timeoutlen=1000 ttimeoutlen=0

set t_Co=256
set background=dark
set cursorline
set termguicolors
"colorscheme hybrid
"highlight Normal ctermbg=NONE
"highlight nonText ctermbg=NONE
"highlight Error ctermbg=1 
colorscheme Asatte-No-Yoru
highlight CharUnderCursor cterm=reverse

filetype plugin indent on

" keep file permissions when saving
set backupcopy=yes

" show line numbers
set number

" show matches while typing
set incsearch

" whitespace highlighting
set listchars=eol:$,tab:->,trail:■,extends:>,precedes:<,space:·

hi RegularSp ctermfg=23
match RegularSp / /
hi TrailingSp ctermfg=210
match TrailingSp / \+$/

" leave the paren under the cursor in reverse
" and set the matching paren to be black on dim grey
hi MatchParen cterm=reverse ctermbg=none
hi MatchParenMatched cterm=none ctermbg=242 ctermfg=233

" always show statusline
set laststatus=0

"set statusline=
"set statusline+=%#PmenuSel#
"set statusline+=test
"set statusline+=%#LineNr#
"set statusline+=\ %f
"set statusline+=%m
"set statusline+=%=
"set statusline+=%#1#
"set statusline+=\ %y
"set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
"set statusline+=\[%{&fileformat}\]
"set statusline+=\ %p%%
"set statusline+=\ %l:%c
"set statusline+=\ 

" don't have much space to work with
" 2 will have to do.
set tabstop=2 softtabstop=2 shiftwidth=2 expandtab

" this version of vim has no clipboard support =/
" we can however do a termux paste
" mapped by fakeclip
let g:fakeclip_write_clipboard_command = "termux-clipboard-set"
" chop the forced trailing newline, so it pastes in-place... 
let g:fakeclip_read_clipboard_command  = "termux-clipboard-get | head -c -1"
" this performs slightly differently to the other registers... probably requires further investigation... look into termux source?? can we get `"+p` to act like `"ap` with the same yank? while still getting the 'correct' result for legit android copy.

" force no tab expansion when make file detected
" e.g. when file is named Makefile, ft=make but
"      tabs are still expanded for some reason
" ... doesn't work
augroup tab_expansion
  autocmd!
  autocmd FileType make setlocal noexpandtab
augroup END

" Activate rainbow parens for lisps
let g:rainbow#blacklist = [248, "#f0c674"]
let g:rainbow#pairs = [['(', ')'], ['[', ']']]
augroup rainbow_lisp
  autocmd!
  autocmd FileType lisp,clojure,scheme RainbowParentheses
  "hi! rainbowParensShell16 ctermfg=204
  "hi! rainbowParensShell15 ctermfg=210
  "hi! rainbowParensShell14 ctermfg=216
  "hi! rainbowParensShell13 ctermfg=222
  "hi! rainbowParensShell12 ctermfg=228
augroup END

" run current file, open result in new tab
nmap © :w<CR>:silent !./% 2>&1 <bar> tee .tmp.xyz<CR>:tabnew<CR>:r .tmp.xyz<CR>:silent !rm .tmp.xyz<CR>:redraw!<CR>:setlocal buftype=nofile<CR>

" source this file
nmap ™ :so $MYVIMRC<CR>
" edit this file in a new tab
nmap £ :tabnew<CR>:e $MYVIMRC<CR>

" experiments
" run current file and pipe results into stdout
" and a file .tmp.xyz
nmap ¶ :!([[ -x % ]] && ./% <bar><bar> echo "${BRed}% is not executable") <bar> tee .tmp.xyz<CR>

" TODO: Make these wrap around like gt and gT
" http://stackoverflow.com/a/14689310
function! MoveToNextTab()
  "there is only one window
  if tabpagenr('$') == 1 && winnr('$') == 1
    return
  endif
 "preparing new window
  let l:tab_nr = tabpagenr('$')
  let l:cur_buf = bufnr('%')
  if tabpagenr() < l:tab_nr
    close!
    if l:tab_nr == tabpagenr('$')
      tabnext
    endif
    split
  else
    close!
    tabnew
  endif
  "opening current buffer in new window
  exe "b".l:cur_buf
endfunc

function! MoveToPrevTab()
  "there is only one window
  if tabpagenr('$') == 1 && winnr('$') == 1
    return
  endif
  "preparing new window
  let l:tab_nr = tabpagenr('$')
  let l:cur_buf = bufnr('%')
  if tabpagenr() != 1
    close!
    if l:tab_nr == tabpagenr('$')
      tabprev
    endif
    split
  else
    close!
    exe "0tabnew"
  endif
  "opening current buffer in new window
  exe "b".l:cur_buf
endfunc

nmap mt :call MoveToNextTab()<CR>
nmap mT :call MoveToPrevTab()<CR>

function! Synstack()
  echo join(reverse(map(synstack(line('.'), col('.')), 'synIDattr(v:val,"name")')),' ')
endfunc

nmap ¿ :call Synstack()<CR>

function! NREPL()
  let l:port = system('cat ~/.lein/repl-port')

  :silent! execute ':Connect nrepl://localhost:' . l:port
endfunction

nmap ® :call NREPL()<CR>
nmap ¢ :%Eval<CR>
