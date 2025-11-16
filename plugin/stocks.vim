let s:lib_path = expand("<sfile>:p:h:h") .. "/lib"

function s:printStock(quotes)
    if stocks#ck_requirements() == v:false
        return
    endif

    for l:quote in a:quotes
        call stocks#printstock(l:quote)
    endfor
endfun

let s:last_prices = {}

function s:updatestocks(output_start, output_buf, data) abort
    let l:data = a:data

    "vim doesnt put it in a list, neovim does
    if type(l:data) != v:t_list
        let l:data = [l:data]
    endif

    if l:data[0] == ""
        return
    endif

    let l:data = json_decode(l:data[0])
    let formatted_text_lines = stocks#format_data(l:data)

    let higherMatch = '^\$\('
    let hasHigherMatch = v:false
    let lowerMatch = '^\$\('
    let hasLowerMatch = v:false
    for stock in keys(s:last_prices)
        let curPrice = l:data["prices"][stock]
        let lastPrice = s:last_prices[stock]

        if curPrice > lastPrice
            let higherMatch ..= stock .. '\|'
            let hasHigherMatch = v:true
        elseif curPrice < lastPrice
            let lowerMatch ..= stock .. '\|'
            let hasLowerMatch = v:true
        endif
    endfor

    if hasHigherMatch
        "match up until the chg column
        " :-3 removes the ending, invalid \|
        let higherMatch = higherMatch[:-3] .. '\)\t[[:digit:].]\+\t[[:digit:].]\+'

        exec 'match DiffAdd /' .. higherMatch .. '/'
    endif

    if hasLowerMatch
        "match up until the chg column
        " :-3 removes the ending, invalid \|
        let lowerMatch = lowerMatch[:-3] .. '\)\t[[:digit:].]\+\t[[:digit:].]\+'

        exec 'match DiffDelete /' .. lowerMatch .. '/'
    endif

    let s:last_prices = l:data["prices"]

    let line = getbufline(a:output_buf, a:output_start)[0]
    call setbufline(a:output_buf, a:output_start, [line] + formatted_text_lines)
endfun

function s:realtime()
    if stocks#ck_requirements() == v:false
        return
    endif

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
