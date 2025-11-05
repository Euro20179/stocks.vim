syn match stockName "^\w\+"
syn match stockShares "\(^\w\+ \)\@<=[[:digit:].]\+$"
syn match stockPrice "\(^\w\+\t\)\@<=[[:digit:].]\+"
syn match stockPriceUp "\(\t-\t\)\@<=[[:digit:].]\+"
syn match stockProfit "(\@<=[[:digit:].]\+)\@="
syn match stockLoss "(\@<=-[[:digit:].]\+)\@="
syn match stockPriceDown "\(\t-\t\)\@<=-[[:digit:].]\+"

hi link stockShares Number
hi link stockPriceUp DiffAdd
hi link stockProfit DiffAdd
hi link stockLoss DiffDelete
hi link stockPriceDown DiffDelete
hi link stockName String
hi link stockPrice Number
