set mouse=a
set encoding=utf-8

" this will install vim-plug if not installed
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif


call plug#begin('~/.config/nvim/plugged')
" Define your plugins here
Plug 'tpope/vim-surround'

" This is for auto complete, prettier, and tslinting
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
let g:coc_global_extensions = ['coc-eslint', 'coc-tslint-plugin', 'coc-tsserver', 'coc-css', 'coc-html', 'coc-json', 'coc-prettier', 'coc-graphql', 'coc-prisma', 'coc-toml', 'coc-yaml', 'coc-dash-complete', 'coc-explorer']

" Autoclose bracket pairs
Plug 'jiangmiao/auto-pairs'

" JSX and TSX Highlighting
Plug 'yuezk/vim-js'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'maxmellon/vim-jsx-pretty'

" File tree
" Plug 'kyazdani42/nvim-tree.lua'

" Line Numbers
Plug 'myusuf3/numbers.vim'

" Editing
Plug 'editorconfig/editorconfig-vim'
" Plug 'nathanaelkane/vim-indent-guides'
Plug 'glepnir/indent-guides.nvim'

" Color Highlighting
Plug 'norcalli/nvim-colorizer.lua'

" Neon Theme
Plug 'rafamadriz/neon'

" StatusLine
Plug 'nvim-lualine/lualine.nvim'
" If you want to have icons in your statusline choose one of these
Plug 'kyazdani42/nvim-web-devicons'

" Notify
Plug 'rcarriga/nvim-notify'

" Tabs
Plug 'romgrk/barbar.nvim'

" Git
Plug 'f-person/git-blame.nvim'

" Comments
Plug 'numToStr/Comment.nvim'

Plug 'karb94/neoscroll.nvim'

call plug#end()

" Enable Color Highlighting
set termguicolors
lua require'colorizer'.setup()

" Set ColorScheme
let g:neon_style = "dark"
colorscheme neon

" StatusLine Config
lua << END
require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {},
    always_divide_middle = true,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff',
                  {'diagnostics', sources={'nvim_lsp', 'coc'}}},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}
END

" Setup Indent Guides
lua require('indent_guides').setup()

lua require('Comment').setup()

lua require('neoscroll').setup()

" File Explorer
" File Highlighting
autocmd ColorScheme *
  \ hi CocExplorerNormalFloatBorder guifg=#414347 guibg=#272B34
  \ | hi CocExplorerNormalFloat guibg=#272B34
  \ | hi CocExplorerSelectUI guibg=blue
" Use preset argument to open it
nmap <space>ed <Cmd>CocCommand explorer --preset .vim<CR>
nmap <space>ef <Cmd>CocCommand explorer --preset floating<CR>
nmap <space>ec <Cmd>CocCommand explorer --preset cocConfig<CR>
nmap <space>eb <Cmd>CocCommand explorer --preset buffer<CR>

" List all presets
nmap <space>el <Cmd>CocList explPresets<CR>

nmap <space>e <Cmd>CocCommand explorer<CR>

set termguicolors " this variable must be enabled for colors to be applied properly


lua << END

local nvim_notify = require("notify")
nvim_notify.setup({ 
})
vim.notify = require("notify")

END
