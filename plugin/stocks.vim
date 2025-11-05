function s:printStock(quotes)
    for l:quote in a:quotes
        call stocks#printstock(l:quote)
    endfor
endfun

function s:updatestocks(output_start, data)
    let formatted_text_lines = stocks#format_data(a:data)

    call append(a:output_start, formatted_text_lines)
endfun

function s:realtime()
    let l:quotes = stocks#listfrombuf()

    set buftype=nofile
    set ft=stocks-rt

    let [l:lnum, l:_] = searchpos("^-\\+$", "n")
    let l:output_start = l:lnum

    if has("nvim")
        let l:job = jobstart(["cat"], #{on_stdout: {j,data,_ -> s:updatestocks(l:output_start, json_decode(data))}})
    else
        let l:job = job_start("cat", #{out_cb: {j, data -> s:updatestocks(l:output_start, json_decode(data))}})
    endif

    call stocks#realtime(l:quotes, l:job)
endfun

command -nargs=+ Stock call <SID>printStock([<f-args>])

command StockRT call <SID>realtime()
