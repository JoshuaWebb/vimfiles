" make the plugins under /bundles work
execute pathogen#infect()

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

hi RegularSp ctermfg=23 guifg=#005f5f
match RegularSp / /
hi TrailingSp ctermfg=210 guifg=#ff8787
match TrailingSp / \+$/

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
