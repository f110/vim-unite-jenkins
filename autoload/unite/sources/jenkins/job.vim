"required
    "vimproc

let s:source = {
            \ 'name': 'jenkins/job',
            \ 'hooks': {},
            \ 'variables': {
            \       'jenkins_server_host': g:unite_source_jenkins_server_host,
            \       'jenkins_server_port': g:unite_source_jenkins_server_port,
            \       'relay_server_host': g:unite_source_jenkins_relay_server_host,
            \       'relay_server_port': g:unite_source_jenkins_relay_server_port,
            \   }
            \ }

function! s:source.hooks.on_init(args, context)
    if !unite#util#has_vimproc()
        call unite#print_source_error('vimproc is required', s:source.name)
        return
    endif

    if get(a:args, 0, '') == ''
        call unite#print_source_error('required project name', s:source.name)
        return
    endif

    if get(a:args, 1, '') == ''
        call unite#print_source_error('required job name', s:source.name)
        return
    endif
endfunction

function! s:source.gather_candidates(args, context)
    let project_name = get(a:args, 0)
    let job_name = get(a:args, 1)

    let vars = unite#get_source_variables(a:context)

    let a:context.source__proc = http#request#get(
                \ vars.jenkins_server_host,
                \ vars.jenkins_server_port,
                \ printf("/%s/%s", project_name, job_name))
    let a:context.source__project_name = project_name
    let a:context.source__job_name = job_name
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

    let done_message = 'get job result'
    call unite#print_source_message(done_message, s:source.name)

    let data = http#request#get_content(a:context.source__res)
    let job_list = eval(data)

    return map(job_list, '{
    \   "word": v:val,
    \   "source": s:source.name,
    \   "kind": "jump_list",
    \   "action__path": v:val,
    \ }')
endfunction

call unite#define_source(s:source)
"function! unite#sources#jenkins#project#define()
    "return s:source
"endfunction
