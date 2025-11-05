let s:lib_path = expand("<sfile>:p:h:h") .. "/lib"

function s:printStock(quotes)
    for l:quote in a:quotes
        call stocks#printstock(l:quote)
    endfor
endfun

function s:updatestocks(output_start, data) abort
    let l:data = a:data

    "vim doesnt put it in a list, neovim does
    if type(l:data) != v:t_list
        let l:data = [l:data]
    endif

    "FIXME: this should work whether or not the user is currently in the
    "buffer
    if &filetype != "stock-rt" || l:data[0] == ""
        return
    endif

    let l:pos = getpos(".")

    let l:data = json_decode(l:data[0])
    let formatted_text_lines = stocks#format_data(l:data)

    "go to the divider line
    exec a:output_start
    "store it
    let line = getline(".")
    "delete from the current line down
    norm "_dG
    "G moves cursor
                                    "add back the divider line
    call append(a:output_start - 1, [line] + formatted_text_lines)

    call setpos(".", l:pos)
endfun

function s:realtime()
    let l:quotes = stocks#listfrombuf()

    set buftype=nofile
    set ft=stock-rt

    let [l:lnum, l:_] = searchpos("^-\\+$", "n")
    let l:output_start = l:lnum

    if has("nvim")
        let l:job = jobstart(["python", s:lib_path .. "/realtime.py", json_encode(l:quotes), g:stocks_api_key], #{on_stdout: {j,data,_ -> s:updatestocks(l:output_start, data)}})
    else
        let l:job = job_start(["python", s:lib_path .. "/realtime.py", json_encode(l:quotes), g:stocks_api_key], #{out_cb: {j, data -> s:updatestocks(l:output_start, data)}})
    endif

    "call stocks#realtime(l:quotes, l:job)
endfun

command -nargs=+ Stock call <SID>printStock([<f-args>])

command StockRT call <SID>realtime()
