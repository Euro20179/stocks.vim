syn match stockName "^\w\+"
syn match stockPrice "\(^\w\+ \)\@<=[[:digit:].]\+"
syn match stockPriceUp "\( - \)\@<=[[:digit:].]\+"
syn match stockProfit "(\@<=[[:digit:].]\+)\@="
syn match stockLoss "(\@<=-[[:digit:].]\+)\@="
syn match stockPriceDown "\( - \)\@<=-[[:digit:].]\+"

hi link stockPriceUp DiffAdd
hi link stockProfit DiffAdd
hi link stockLoss DiffDelete
hi link stockPriceDown DiffDelete
hi link stockName String
hi link stockPrice Number
