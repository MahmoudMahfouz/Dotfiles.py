set hidden
"Share the clipboard between vim and OS
set clipboard=unnamed

" Encoding
set encoding=utf8

"" To make docker file events work
set backupcopy=yes

set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" folding
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=2

" tabs and spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab
set backspace=2 " make backspace work like most other apps"
" shift + tab = real tab"
inoremap <S-Tab> <C-V><Tab>

"Write the old file out when switching between files.
set autowrite

"Display current cursor position in lower right corner.
set ruler

"Show lines numbers
"set relativenumber
set number

"Indent stuff
set smartindent
set autoindent

" case insensitive search
set ignorecase
set smartcase

" faster vim
set synmaxcol=200
set ttyfast
set lazyredraw
set re=1

" for auto reloading files
set autoread

" toggle to paste without indenting
set pastetoggle=<F2>

" Saves file when Vim window loses focus
au FocusLost * :wa"

set timeoutlen=500
" KEY MAPPINGS "
  nnoremap <Leader>y "+yy
  nnoremap <Leader>d "+dd
  noremap  <Leader>p "+p
  noremap  <Leader>P "+P
  vnoremap <Leader>y "+y
  vnoremap <Leader>d "+d
" Workflow
set hidden
"" tabs (should be changed to not conflict with till command)
nnoremap <leader>t  :tabnext<CR>
nnoremap <leader>T  :tabprev<CR>
nnoremap <leader>tn  :tabnew<CR>
nnoremap <leader>td  :tabclose<CR>

" buffer managment
map ˙ :bp<cr>
map ¬ :bn<cr>

"" windows
noremap <C-h>              :wincmd h<cr>
noremap <C-k>              :wincmd k<cr>
noremap <C-l>              :wincmd l<cr>
noremap <C-j>              :wincmd j<cr>

" Mac only alt+M/m
noremap Â :call MaximizeToggle()<CR>
nnoremap µ :call MaximizeToggle()<CR>

" Move windows Mac only alt/hjkl
noremap <leader>h :wincmd H<cr>
noremap <leader>k :wincmd K<cr>
noremap <leader>l :wincmd L<cr>
noremap <leader>j :wincmd J<cr>

"resize windows"
nmap <left>  :3wincmd <<cr>
nmap <right> :3wincmd ><cr>
nmap <up>    :3wincmd +<cr>
nmap <down>  :3wincmd -<cr>
map <leader>m :tabedit %<CR>

"Map escape key to jj -- much faster
imap jj <esc>
imap kk <esc>

" search
nnoremap <leader>/ :Ag<SPACE>
nnoremap <leader>f :Ag <cword><CR>

" GENERAL "
colorscheme one
set background=dark
map <Esc><Esc> :w<CR>

" Key mappings "

" space + w closes buffer
nnoremap <leader>w :bw<CR>
" space + q closes all
nnoremap <leader>q :qa<CR>
" closing aliases "
command WQ wq
command Wq wq
command W w
command Q q

" Syntastic
map <leader>tt :SyntasticCheck<cr>              " Run the syntastic checks

" Vim airline
set laststatus=2
let g:airline_powerline_fonts = 1
let g:airline_theme='one'
let g:Powerline_symbols = 'fancy'
let g:airline#extensions#tabline#enabled = 1

" Vim sessions
let g:session_autosave_periodic = 5
let g:session_autosave_silent = 1
let g:session_autosave = 'yes'

" toggle the C tagbar
nmap <leader>tb :TagbarToggle<CR>

" Multiple cursors
" Default mapping
let g:multi_cursor_next_key='<C-n>'
let g:multi_cursor_prev_key='<C-p>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'

" CTRL+P "
let g:ctrlp_map = '<c-p>'
let g:ctrlp_show_hidden = 1
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v\.(git|hg|svn|orig)$|\vtmp|\vdoc|\vcoverage|\vtags',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': '',
  \ }
let g:ctrlp_use_caching = 0
let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup
      \ --ignore .git
      \ --ignore .svn
      \ --ignore .hg
      \ --ignore .DS_Store
      \ --ignore "**/*.pyc"
      \ -g ""'

" Nerdtree
" go open and leave cursor in nt
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let NERDTreeShowHidden=1
let g:NERDTreeMouseMode = 3
noremap <Leader>nt :NERDTreeToggle<CR>
noremap <Leader>nf :NERDTreeFind<CR>

" easy motion
let g:EasyMotion_enter_jump_first=1
let g:EasyMotion_smartcase = 1 " case insensitive matching
let g:EasyMotion_use_smartsign_us = 1 " match 3 and #
map / <Plug>(easymotion-sn)
" map <Leader>l <Plug>(easymotion-lineforward)
" map <Leader>j <Plug>(easymotion-j)
" map <Leader>k <Plug>(easymotion-k)
" map <Leader>h <Plug>(easymotion-linebackward)

" Git Gutter
nnoremap ]h :GitGutterNextHunk<CR>
nnoremap [h :GitGutterPrevHunk<CR>
nnoremap <Leader>hv :GitGutterPreviewHunk<CR>
nnoremap <Leader>hr :GitGutterRevertHunk<CR>
nnoremap <Leader>hs :GitGutterStageHunk<CR>

" indent highlight activated with <leader>ig
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=0 guifg=#4F504B guibg=#3C3D38
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=0 guifg=#3C3D38 guibg=#4F504B

" emmet "
let g:user_emmet_leader_key='<C-Y>'
let g:user_emmet_mode='n'    "only enable normal mode functions.
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall

" Undo Tree "
nnoremap <leader>ut :UndotreeToggle<cr>

" "
" SURROUND "
" use cs"[  remember with change surrounding from " to [

" Syntastic "
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_mode_map = { "mode": "passive" }
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_signs = 1
let g:syntastic_ruby_exec = 'ruby'
let g:syntastic_ruby_checkers = ['mri', 'rubocop']

" Python "
let g:pymode_rope_goto_definition_bind = "<leader>pgd"
let g:pymode_run_bind = "<leader>pr"
let g:pymode_doc_bind = "<leader>pd"
autocmd BufWritePost *.py call Flake8()

" GO "
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>gdb <Plug>(go-doc-browser)
au FileType go nmap <leader>gr <Plug>(go-run)
au FileType go nmap <leader>gt <Plug>(go-test)
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1

" markdown "
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" JS "
" for beautify use <leader>sb"
" sourcetype that support by this plugin

" jquery "
au BufRead,BufNewFile jquery.*.js set ft=javascript syntax=jquery

" json "
au BufRead,BufNewFile *.json setf json

" beautify Mac only"
map ƒ :call RangeJsBeautify()<cr>
autocmd FileType javascript noremap <buffer> <leader>b :call RangeJsBeautify()<cr>
" for json
autocmd FileType json noremap <buffer> <leader>b :call RangeJsonBeautify()<cr>
" for jsx
autocmd FileType jsx noremap <buffer> <leader>b :call RangeJsxBeautify()<cr>
" for html
autocmd FileType html noremap <buffer> <leader>b :call RangeHtmlBeautify()<cr>
" for css or scss
autocmd FileType css noremap <buffer> <leader>b :call RangeCSSBeautify()<cr>

" for Python
let python_highlight_all=1
syntax on
au BufNewFile,BufRead *.py
    \ set tabstop=4
    \ set softtabstop=4
    \ set shiftwidth=4
    \ set textwidth=79
    \ set expandtab
    \ set autoindent
    \ set fileformat=unix"

" FUNCTIONS
function! MaximizeToggle()
  if exists("s:maximize_session")
    exec "source " . s:maximize_session
    call delete(s:maximize_session)
    unlet s:maximize_session
    let &hidden=s:maximize_hidden_save
    unlet s:maximize_hidden_save
  else
    let s:maximize_hidden_save = &hidden
    let s:maximize_session = tempname()
    set hidden
    exec "mksession! " . s:maximize_session
    only
  endif
endfunction
