function! http#response#get_content(result)
    let idx = stridx(a:result, "\r\n\r\n") + 4
    return a:result[idx : ]
endfunction

function! http#response#is_success(result)
    let lines = split(a:result, "\n")

    for line in lines
        if stridx(line, "HTTP/") == 0
            let status_line = split(line, " ")
            if status_line[1] == 200
                return 1
            else
                return 0
            endif
        endif
    endfor

    return 0
endfunction
