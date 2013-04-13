"required
    "vimproc

call unite#util#set_default('g:unite_source_jenkins_server_host', 'localhost')
call unite#util#set_default('g:unite_source_jenkins_server_port', '9002')
call unite#util#set_default('g:unite_source_jenkins_relay_server_host', 'localhost')
call unite#util#set_default('g:unite_source_jenkins_relay_server_port', '9001')

let s:project_list_cache = []
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

    if len(s:project_list_cache) == 0
        let a:context.source__proc = http#request#get(
                    \ vars.relay_server_host,
                    \ vars.relay_server_port,
                    \  '/')
        let a:context.source__res = ''
    endif

    return []
endfunction

function! s:source.async_gather_candidates(args, context)
    if len(s:project_list_cache) == 0
        let vars = unite#get_source_variables(a:context)
        let socket = a:context.source__proc

        if !socket.eof
            let a:context.source__res .= socket.read()
            return []
        endif

        call unite#print_source_message('got a project list', s:source.name)
        let data = http#response#get_content(a:context.source__res)
        let s:project_list_cache = eval(data)
    else
        call unite#print_source_message('from cache', s:source.name)
    endif

    let a:context.is_async = 0

    let project_list = copy(s:project_list_cache)
    return map(project_list, '{
    \   "word": v:val,
    \   "source": s:source.name,
    \   "kind": "source",
    \   "action__source_name": "jenkins/project",
    \   "action__source_args": [v:val],
    \ }')
endfunction

function! unite#sources#jenkins#define()
    return s:source
endfunction
