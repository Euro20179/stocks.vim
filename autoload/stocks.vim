function stocks#listfrombuf() abort
    call setpos(".", [0, 0, 0, 0])
    let [l:dividerLine, _] = searchpos('^-\+$', 'n')
    let l:raw_stock_data = getline(0, l:dividerLine - 1)

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

function s:sortstocksDict(allStocks, stockA, stockB)
    return a:allStocks[a:stockA] == a:allStocks[a:stockB] ? 0 : a:allStocks[a:stockA] < a:allStocks[a:stockB] ? 1 : -1
endfun

function stocks#format_data(data) abort
    let l:prices = a:data["prices"]
    let l:open = a:data["open"]
    let l:moneychg = a:data["moneychg"]
    let l:shares = a:data["shares"]

    let l:text = ["TICKER\tPRICE\tSHARES\tCHG\tDPROFIT"]

    let moneyChgTotal = 0
    let valueTotal = 0

    for l:stock in sort(keys(l:moneychg), {a,b -> s:sortstocksDict(l:moneychg, a, b)})
        let l:price = l:prices[l:stock]
        let l:text += [printf("$%s\t%.2f\t%.3f\t%.2f\t(%.2f)", l:stock, l:price, l:shares[l:stock], l:price - str2float(l:open[l:stock]), l:moneychg[l:stock])]
        let moneyChgTotal += l:moneychg[l:stock]
        let valueTotal += l:shares[l:stock] * l:price
    endfor

    let strVal = printf("%.2f", valueTotal)

    let l:text += [
                \ printf("--------------------"),
                \ printf("%-15sDPROFIT", "VALUE"),
                \ printf("%-*s(%.2f)", 15, strVal, moneyChgTotal)
                \ ]

    return l:text
endfun
