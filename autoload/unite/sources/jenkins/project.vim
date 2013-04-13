"required
    "vimproc

call unite#util#set_default('g:unite_source_jenkins_job_source', 'jenkins/job')
let s:source = {
            \ 'name': 'jenkins/project',
            \ 'hooks': {},
            \ 'syntax': 'uniteSource__Jenkins',
            \ 'variables': {
            \       'relay_server_host': g:unite_source_jenkins_relay_server_host,
            \       'relay_server_port': g:unite_source_jenkins_relay_server_port,
            \       'job_source': g:unite_source_jenkins_job_source,
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
endfunction

function! s:source.hooks.on_syntax(args, cocntext)
    syntax match uniteSource__Jenkins_Success /\[SUCCESS]/ contained containedin=uniteSource__Jenkins
    syntax match uniteSource__Jenkins_Success /\[UNSTABLE]/ contained containedin=uniteSource__Jenkins
    syntax match uniteSource__Jenkins_Fail /\[FAILURE]/ contained containedin=uniteSource__Jenkins
    highlight link uniteSource__Jenkins_Fail Error
    highlight link uniteSource__Jenkins_Success Statement
endfunction

function! s:source.gather_candidates(args, context)
    let vars = unite#get_source_variables(a:context)
    let project_name = get(a:args, 0)

    let a:context.source__proc = http#request#get(
                \ vars.relay_server_host,
                \ vars.relay_server_port,
                \  printf("/%s", project_name))
    let a:context.source__project_name = project_name
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

    let done_message = 'get job list'
    call unite#print_source_message(done_message, s:source.name)

    if !http#response#is_success(a:context.source__res)
        call unite#print_error_message("FAIL", s:source.name)
        return []
    endif
    let data = http#response#get_content(a:context.source__res)
    let job_list = eval(data)

    let vars = unite#get_source_variables(a:context)
    let _ = []
    for job in job_list
        let job_status = toupper(get(job, 'status', ''))

        if job_status == "SUCCESS" || job_status == "FAILURE" || job_status == "UNSTABLE" || job_status == "ABORTED"
            let no_cache = 0
        else
            let no_cache = 1
        endif
        let source_candidates = {
                    \   "word": printf("%s.[%s] %s:%s", job["id"], job_status, job["repository"], job["branch"]),
                    \   "source": s:source.name,
                    \   "kind": "source",
                    \   "action__source_name": vars.job_source,
                    \   "action__source_args": [a:context.source__project_name, job["id"], no_cache],
                    \ }

        call add(_, source_candidates)
    endfor

    return _
endfunction

call unite#define_source(s:source)
"function! unite#sources#jenkins#project#define()
    "return s:source
"endfunction
