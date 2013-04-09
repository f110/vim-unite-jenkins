function! s:http_request(host, port, method, path)
    let socket = vimproc#socket_open(a:host, a:port)
    call socket.write(printf("%s %s HTTP/1.0\r\n\r\n", a:method, a:path))

    return socket
endfunction

function! http#request#get(host, port, path)
    return s:http_request(a:host, a:port, "GET", a:path)
endfunction

function! http#request#get_content(result)
    let idx = stridx(a:result, "\r\n\r\n") + 4
    return a:result[idx : ]
endfunction
