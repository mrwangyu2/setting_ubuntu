" 自定义命令来生成方法实现
function! GenerateMethodImplementation()
    " 获取当前行的内容
    let l:line = getline('.')
    
    " 提取返回类型、方法名称和参数
    let l:return_type = matchstr(l:line, '^\s*\zs\w\+\ze\s\+\w\+\s*(')
    let l:method_name = matchstr(l:line, '\w\+\s*\ze(')
    let l:params = matchstr(l:line, '(\_.\{-})')

    " 去除末尾的分号
    let l:method_name = substitute(l:method_name, ';', '', '')

    " 打开对应的 .cpp 文件
    let l:cpp_file = expand('%:r') . '.cpp'
    execute 'edit' l:cpp_file

    " 生成方法实现
    call append(line('$'), '')
    call append(line('$'), l:return_type . ' ' . l:method_name . l:params . ' {')
    call append(line('$'), '    // TODO: implement ' . l:method_name)
    call append(line('$'), '}')
    call append(line('$'), '')

    " 移动光标到方法体内
    execute 'normal! Gk'
endfunction

" 映射快捷键来生成方法实现
nnoremap <leader>gm :call GenerateMethodImplementation()<CR>




" 自定义命令来生成方法实现
" function! GenerateMethodImplementation()
"     " 获取当前行的内容
"     let l:line = getline('.')
"
"     " 提取返回类型、类名、方法名称和参数
"     let l:return_type = matchstr(l:line, '^\s*\zs\w\+\ze\s\+\%(\w\+\s*::\)\?\w\+\s*(')
"     let l:class_name = matchstr(l:line, '\w\+\s*\ze::\w\+\s*(')
"     let l:method_name = matchstr(l:line, '::\zs\w\+\ze\s*(')
"     let l:params = matchstr(l:line, '(\_.\{-})')
"
"     " 去除末尾的分号
"     let l:method_name = substitute(l:method_name, ';', '', '')
"
"     " 打开对应的 .cpp 文件
"     let l:cpp_file = expand('%:r') . '.cpp'
"     execute 'edit' l:cpp_file
"
"     " 生成方法实现
"     call append(line('$'), '')
"     call append(line('$'), l:return_type . ' ' . l:class_name . '::' . l:method_name . l:params . ' {')
"     call append(line('$'), '    // TODO: implement ' . l:class_name . '::' . l:method_name)
"     call append(line('$'), '}')
"     call append(line('$'), '')
"
"     " 移动光标到方法体内
"     execute 'normal! Gk'
" endfunction
"
" " 映射快捷键来生成方法实现
" nnoremap <leader>gm :call GenerateMethodImplementation()<CR>

