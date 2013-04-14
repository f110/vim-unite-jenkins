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
        let socket = http#request#get(
                    \ vars.relay_server_host,
                    \ vars.relay_server_port,
                    \  '/')
        if exists('socket')
            let a:context.source__proc = socket
        endif
        let a:context.source__res = ''
    endif

    return []
endfunction

function! s:source.async_gather_candidates(args, context)
    if len(s:project_list_cache) == 0
        if !has_key(a:context, 'source__proc')
            call unite#print_source_error('Could not open socket', s:source.name)
            let a:context.is_async = 0
            return []
        endif

        let vars = unite#get_source_variables(a:context)
        let socket = a:context.source__proc

        if !socket.eof
            let a:context.source__res .= socket.read()
            return []
        endif

        if !http#response#is_success(a:context.source__res)
            call unite#print_source_error('could not get project list', s:source.name)
            let a:context.is_async = 0
            return []
        endif

        call unite#print_source_message('done', s:source.name)
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
    let sources = []
    for command in s:get_commands()
        let source = call(s:to_define_func(command), [])
        if type({}) == type(source)
            call add(sources, source)
        elseif type([]) == type(source)
            call extend(sources, source)
        endif
        unlet source
    endfor
    return add(sources, s:source)
endfunction

function! s:get_commands()
    return map(
            \   split(
            \     globpath(&runtimepath, 'autoload/unite/sources/jenkins/*.vim'),
            \     '\n'
            \   ),
            \   'fnamemodify(v:val, ":t:r")'
            \ )
endfunction

function! s:to_define_func(command)
    return 'unite#sources#jenkins#' . a:command . '#define'
endfunction
