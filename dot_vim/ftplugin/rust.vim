call ale#linter#Define('rust', {
      \   'name': 'rust-analyzer',
      \   'lsp': 'stdio',
      \   'executable': 'rust-analyzer',
      \   'command': '%e',
      \   'project_root': '.',
      \})
augroup RustFtpluginLocal
    au!
    "au insertleave <buffer> silent! update
augroup END
