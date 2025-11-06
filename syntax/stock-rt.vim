"low priority, any float that does not match the rest of the patterns is
"considered a stockShares
syn match stockShares "[[:digit:].]\+"

syn match stockName "^\$\?[[:alpha:]]\+"


syn match stockProfit "(\@<=[[:digit:].]\+)\@="
syn match stockLoss "(\@<=-[[:digit:].]\+)\@="

syn match stockPrice "\(^\$\w\+\t\)\@<=[[:digit:].]\+"
syn match stockPriceUp "\t\@<=[[:digit:].]\+\(\t(\)\@="
syn match stockPriceDown "\t\@<=-[[:digit:].]\+\(\t(\)\@="

syn match stockTotalValue "^[[:digit:].]\+\>"

"this must have higher priority than stockName due to conflicts
syn match stockLabel "\(^\$[A-Z]*\)\@<!\<[A-Z]\+\>"

hi link stockShares Number

hi link stockName String

hi link stockProfit DiffAdd
hi link stockLoss DiffDelete

hi link stockPrice Number
hi link stockPriceUp DiffAdd
hi link stockPriceDown DiffDelete

hi link stockTotalValue Number

hi link stockLabel Title
