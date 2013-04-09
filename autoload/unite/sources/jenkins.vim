"required
    "vimproc
    "curl

call unite#util#set_default('g:unite_source_jenkins_server_host', 'localhost')
call unite#util#set_default('g:unite_source_jenkins_server_port', '9002')
call unite#util#set_default('g:unite_source_jenkins_relay_server_host', 'localhost')
call unite#util#set_default('g:unite_source_jenkins_relay_server_port', '9001')
let s:source = {
            \ 'name': 'jenkins',
            \ 'hooks': {},
            \ 'variables': {
            \       'relay_server_host': g:unite_source_jenkins_relay_server_host,
            \       'relay_server_port': g:unite_source_jenkins_relay_server_port,
            \   }
            \ }

function! s:source.hooks.on_init(args, context)
    if !unite#util#has_vimproc()
        call unite#print_source_error('vimproc is required', s:source.name)
        return
    endif
endfunction

function! s:source.gather_candidates(args, context)
    let vars = unite#get_source_variables(a:context)

    let a:context.source__proc = http#request#get(
                \ vars.relay_server_host,
                \ vars.relay_server_port,
                \  '/')
    let a:context.source__res = ''

    return []
endfunction

function! s:source.async_gather_candidates(args, context)
    let socket = a:context.source__proc

    if !socket.eof
        let a:context.source__res .= socket.read()
        return []
    endif

    let a:context.is_async = 0

    let data = http#request#get_content(a:context.source__res)

    let done_message = 'got a project list'
    call unite#print_source_message(done_message, s:source.name)
    let project_list = eval(data)

    return map(project_list, '{
    \   "word": v:val,
    \   "source": s:source.name,
    \   "kind": "source",
    \   "action__source_name": "jenkins/project",
    \   "action__source_args": [v:val],
    \ }')
endfunction

call unite#define_source(s:source)
"function! unite#sources#jenkins#define()
    "return s:source
"endfunction
