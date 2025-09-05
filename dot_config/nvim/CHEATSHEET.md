# Neovim Configuration Cheat Sheet
*Comprehensive TypeScript/JavaScript IDE with AI Integration*

## 🚀 Quick Start

### Launch & Dashboard
- Open Neovim: `nvim` → Shows dashboard with quick actions
- Dashboard shortcuts:
  - `f` → Find files
  - `n` → New file  
  - `r` → Recent files
  - `g` → Find text
  - `c` → Config
  - `l` → Lazy (plugin manager)
  - `q` → Quit

---

## 📁 File Management & Navigation

### File Explorer (Neo-tree)
| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file explorer |
| `<leader>E` | Explorer (current file location) |
| `Y` | Copy file path |
| `<space>` | Toggle file/folder |

### Fuzzy Finding (Telescope)
| Key | Action |
|-----|--------|
| `<leader><space>` | Find files |
| `<leader>ff` | Find files |
| `<leader>fF` | Find all files (hidden) |
| `<leader>fr` | Recent files |
| `<leader>/` | Live grep (search in files) |
| `<leader>sg` | Grep in project |
| `<leader>sb` | Search in current buffer |
| `<leader>,` | Switch buffers |
| `<leader>:` | Command history |

### Buffer Management
| Key | Action |
|-----|--------|
| `<S-h>` or `[b` | Previous buffer |
| `<S-l>` or `]b` | Next buffer |
| `<leader>bb` | Switch to other buffer |
| `<leader>bo` | Close other buffers |
| `<leader>bp` | Pin buffer |
| `<leader>bd` | Delete buffer |

---

## 🤖 AI & Code Assistance

### GitHub Copilot
| Key | Action |
|-----|--------|
| `<C-J>` | Accept suggestion |
| `<C-L>` | Accept word |
| `<C-Down>` | Next suggestion |
| `<C-Up>` | Previous suggestion |

### Copilot Chat (Claude-like)
| Key | Action |
|-----|--------|
| `<leader>ccq` | Quick chat |
| `<leader>ccb` | Chat with buffer |
| `<leader>cce` | Explain code |
| `<leader>cct` | Generate tests |
| `<leader>ccr` | Review code |
| `<leader>ccf` | Refactor code |
| `<leader>ccn` | Better naming |
| `<leader>ccv` | Visual mode chat |

### Claude Integration (if available)
| Key | Action |
|-----|--------|
| `<leader>cc` | Claude chat |
| `<leader>cg` | Claude generate |

---

## 💻 TypeScript/JavaScript Development

### LSP (Language Server)
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format document |

### TypeScript Specific
| Key | Action |
|-----|--------|
| `<leader>to` | Organize imports |
| `<leader>tr` | Rename file |
| `<leader>ti` | Add missing imports |
| `<leader>tu` | Remove unused |

### Diagnostics & Errors
| Key | Action |
|-----|--------|
| `<leader>xx` | Toggle diagnostics (Trouble) |
| `<leader>xX` | Buffer diagnostics |
| `]d` | Next diagnostic |
| `[d` | Previous diagnostic |
| `<leader>sd` | Document diagnostics |
| `<leader>sD` | Workspace diagnostics |

---

## 🎨 Code Editing & Navigation

### Smart Movement
| Key | Action |
|-----|--------|
| `j/k` | Move by visual lines |
| `<C-h/j/k/l>` | Navigate windows |
| `<A-j/k>` | Move lines up/down |
| `<C-d/u>` | Half page scroll |

### Text Objects & Selection
| Key | Action |
|-----|--------|
| `<C-space>` | Expand selection |
| `<bs>` | Shrink selection |
| `af/if` | Function outer/inner |
| `ac/ic` | Class outer/inner |
| `aa/ia` | Parameter outer/inner |

### Code Folding
| Key | Action |
|-----|--------|
| `za` | Toggle fold |
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zo` | Open fold |
| `zc` | Close fold |

---

## 🔧 Git Integration

### Git Signs (In Editor)
| Key | Action |
|-----|--------|
| `]h` | Next hunk |
| `[h` | Previous hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghp` | Preview hunk |
| `<leader>ghb` | Blame line |

### LazyGit
| Key | Action |
|-----|--------|
| `<leader>gg` | Open LazyGit |

### Git Status & Commits
| Key | Action |
|-----|--------|
| `<leader>gc` | Git commits |
| `<leader>gs` | Git status |

### Diff View
| Key | Action |
|-----|--------|
| `<leader>gdo` | Open diff view |
| `<leader>gdc` | Close diff view |
| `<leader>gdh` | File history |

---

## 🔍 Search & Replace

### Search
| Key | Action |
|-----|--------|
| `/` | Search forward |
| `?` | Search backward |
| `n` | Next match |
| `N` | Previous match |
| `<esc>` | Clear search highlight |

### Advanced Search
| Key | Action |
|-----|--------|
| `<leader>sw` | Search word under cursor |
| `<leader>sg` | Live grep |
| `<leader>sR` | Resume last search |
| `<leader>ss` | Document symbols |
| `<leader>sS` | Workspace symbols |

---

## ⚙️ Window & Tab Management

### Windows
| Key | Action |
|-----|--------|
| `<leader>w-` | Split horizontal |
| `<leader>w\|` | Split vertical |
| `<leader>wd` | Delete window |
| `<leader>ww` | Other window |
| `<C-Up/Down>` | Resize height |
| `<C-Left/Right>` | Resize width |

### Tabs
| Key | Action |
|-----|--------|
| `<leader><tab><tab>` | New tab |
| `<leader><tab>]` | Next tab |
| `<leader><tab>[` | Previous tab |
| `<leader><tab>d` | Close tab |

---

## 🎯 Productivity Features

### Quick Actions
| Key | Action |
|-----|--------|
| `<C-s>` | Save file |
| `<leader>fn` | New file |
| `<leader>qq` | Quit all |
| `<leader>l` | Lazy (plugins) |

### Terminal
| Key | Action |
|-----|--------|
| `<esc><esc>` | Exit terminal mode |
| `<C-/>` | Hide terminal |
| `<C-h/j/k/l>` | Navigate from terminal |

### Comments & TODOs
| Key | Action |
|-----|--------|
| `gcc` | Toggle line comment |
| `gc` | Comment selection |
| `]t` | Next TODO |
| `[t` | Previous TODO |
| `<leader>xt` | TODO list |

---

## 🎨 UI & Appearance

### Theme & Display
- **Theme**: Tokyo Night (dark)
- **Status line**: Shows mode, git, diagnostics, time
- **Buffer line**: Shows open files with diagnostics
- **Indent guides**: Visual indentation lines

### UI Toggles
| Key | Action |
|-----|--------|
| `<leader>ut` | Toggle Treesitter context |
| `<leader>ui` | Inspect position |

---

## 📋 Completion & Snippets

### In Insert Mode
| Key | Action |
|-----|--------|
| `<C-space>` | Trigger completion |
| `<C-n/p>` | Next/previous completion |
| `<CR>` | Accept completion |
| `<C-e>` | Close completion |
| `<Tab>` | Navigate snippet placeholders |

---

## 🚨 Help & Discovery

### Getting Help
| Key | Action |
|-----|--------|
| `<leader>sk` | Show all keymaps |
| `<leader>sh` | Help pages |
| `<leader>sC` | Commands |
| `:help <topic>` | Vim help |
| `:WhichKey` | Show key mappings |

### Plugin Management
| Key | Action |
|-----|--------|
| `<leader>l` | Open Lazy |
| `:Lazy sync` | Update plugins |
| `:Lazy clean` | Remove unused |
| `:Mason` | Manage LSP tools |

---

## 🔧 Configuration Files

### Key Files Location
```
~/.config/nvim/
├── init.lua                 # Main config
├── lua/config/
│   ├── options.lua         # Neovim options
│   ├── keymaps.lua         # Key mappings
│   ├── autocmds.lua        # Auto commands
│   └── ai.lua              # AI settings
└── lua/plugins/
    ├── lsp.lua             # Language servers
    ├── completion.lua      # Code completion
    ├── ai.lua              # AI integration
    ├── treesitter.lua      # Syntax highlighting
    ├── ui.lua              # File explorer & fuzzy finder
    ├── git.lua             # Git integration
    ├── formatting.lua      # Formatting & linting
    └── colorscheme.lua     # Themes & appearance
```

---

## 💡 Pro Tips

### Workflow Recommendations
1. **Start with `<leader>ff`** to find files quickly
2. **Use `<leader>/`** for project-wide searches
3. **Enable Copilot** for AI assistance: `<C-J>` to accept
4. **Use `gd`** constantly for navigation
5. **Format on save** is automatic for TS/JS files
6. **Use `<leader>gg`** for all Git operations

### TypeScript Development
- **Inlay hints** show parameter names and types
- **Auto-import** works with `<leader>ti`
- **Organize imports** automatically on save
- **ESLint** and **Prettier** run automatically

### AI-Powered Coding
- **Copilot Chat** (`<leader>cc*`) for code discussions
- **Code reviews** with `<leader>ccr`
- **Generate tests** with `<leader>cct`
- **Refactoring help** with `<leader>ccf`

### Performance
- **Lazy loading** keeps startup fast
- **Large files** automatically disable heavy features
- **Treesitter** provides fast, accurate highlighting

---

## 🆘 Troubleshooting

### Common Issues
- **LSP not working**: `:LspInfo` to check status
- **Missing language servers**: `:Mason` to install
- **Plugin issues**: `:Lazy` to check/update
- **Slow startup**: Check `:Lazy profile`

### Reset & Rebuild
```bash
# Backup and reset
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak

# Re-apply from dotfiles
chezmoi apply ~/.config/nvim
```

---

*This configuration is managed by Chezmoi - edit source files in `~/.local/share/chezmoi/`*