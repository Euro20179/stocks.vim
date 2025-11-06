let s:lib_path = expand("<sfile>:p:h:h") .. "/lib"

function s:printStock(quotes)
    for l:quote in a:quotes
        call stocks#printstock(l:quote)
    endfor
endfun

function s:updatestocks(output_start, output_buf, data) abort
    let l:data = a:data

    "vim doesnt put it in a list, neovim does
    if type(l:data) != v:t_list
        let l:data = [l:data]
    endif

    if l:data[0] == ""
        return
    endif

    if bufnr() == a:output_buf
        let l:startpos = getpos(".")
    endif

    let l:data = json_decode(l:data[0])
    let formatted_text_lines = stocks#format_data(l:data)

    let line = getbufline(a:output_buf, a:output_start)[0]
    call deletebufline(a:output_buf, a:output_start, "$")
    call appendbufline(a:output_buf, a:output_start - 1, [line] + formatted_text_lines)

    if bufnr() == a:output_buf
        "set pos back to starting pos, i think deletebufline() moves the
        "cursor if the cursor is within one of those lines
        call setpos(".", l:startpos)
    endif

endfun

function s:realtime()
    let l:quotes = stocks#listfrombuf()

    set buftype=nofile
    set ft=stock-rt

    let [l:lnum, l:_] = searchpos("^-\\+$", "n")

    let l:output_start = l:lnum
    let output_buf = bufnr()

    if has("nvim")
        let l:job = jobstart(["python", s:lib_path .. "/realtime.py", json_encode(l:quotes), g:stocks_api_key], #{on_stdout: {j,data,_ -> s:updatestocks(l:output_start, output_buf, data)}})
    else
        let l:job = job_start(["python", s:lib_path .. "/realtime.py", json_encode(l:quotes), g:stocks_api_key], #{out_cb: {j, data -> s:updatestocks(l:output_start, output_buf, data)}})
    endif

    "call stocks#realtime(l:quotes, l:job)
endfun

command -nargs=+ Stock call <SID>printStock([<f-args>])

command StockRT call <SID>realtime()
