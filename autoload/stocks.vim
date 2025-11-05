function stocks#listfrombuf() abort
    call setpos(".", [0, 0, 0, 0])
    let l:temp = @a

    "setup the / register for yn to copy from start until the ---- line
    let @/ = "^-\\+$"
    keepmarks keepjumps noau norm! "ayn
    noh

    let l:ret = @a
    let @a = l:temp
    let l:raw_stock_data = split(l:ret, "\n")

    let l:stocks = {}

    for l:line in l:raw_stock_data
        let l:sp = split(l:line, ' ')
        if len(l:sp) == 1
            let l:stocks[l:sp[0]] = 0.0
        else
            let l:stocks[l:sp[0]] = str2float(l:sp[1])
        endif
    endfor

    return l:stocks
endfun

function stocks#quote(stock)
    return system($"curl -s 'https://finnhub.io/api/v1/quote?symbol={toupper(a:stock)}&token={g:stocks_api_key}' 2> /dev/null")->json_decode()
endfun

function stocks#printstock(quote)
    let l:res = stocks#quote(a:quote)

    let text = printf("%s %.2f - %.2f (%.2f%%)", a:quote, l:res["c"], l:res["d"], l:res["dp"])

    let l:hl = l:res["d"] < 0 ? "DiffDelete" : "DiffAdd"

    exec 'echohl ' . l:hl
    echo text
    echohl Normal
endfun

function stocks#format_data(data) abort
    let l:prices = a:data["prices"]
    let l:open = a:data["open"]
    let l:moneychg = a:data["moneychg"]

    let l:text = []

    for l:stock in keys(l:prices)
        let l:price = l:prices[l:stock]
        let l:text += [printf("%s\t%.2f\t-\t%.2f\t(%.2f)", l:stock, l:price, l:price - str2float(l:open[l:stock]), l:moneychg[l:stock])]
    endfor

    return l:text
endfun
