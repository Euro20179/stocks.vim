python3 <<EOF
try:
    import requests
except ModuleNotFoundError:
    vim.command('echohl Error | echom "[stocks.vim]: The python requests library is not installed" | echohl Normal')
try:
    import websockets
except ModuleNotFoundError:
    vim.command('echohl Error | echom "[stocks.vim]: The python websockets library is not installed" | echohl Normal')
EOF
