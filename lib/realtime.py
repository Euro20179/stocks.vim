import json
import sys
import os
from collections import defaultdict

import requests
from websockets.sync.client import connect


stocklist = json.loads(sys.argv[1])
key = sys.argv[2]

def quote(stock: str):
    res = requests.get(f"https://finnhub.io/api/v1/quote?symbol={stock.upper()}&token={key}")
    return res.json()



prices = defaultdict(float)
open = defaultdict(float)
moneychg = defaultdict(float)

stocklist = {k.upper(): v for k, v in stocklist.items()}

for stock in stocklist:
    stockData = quote(stock)
    prices[stock] = float(stockData["c"])
    open[stock] = float(stockData["pc"])
    moneychg[stock] = (prices[stock] - open[stock]) * stocklist[stock]

data = json.dumps({
    "prices": prices,
    "open": open,
    "moneychg": moneychg,
    "shares": stocklist
})
print(data, flush=True)

with connect(f"wss://ws.finnhub.io?token={key}") as socket:
    for symbol in stocklist:
        socket.send(f'{{"type":"subscribe","symbol":"{symbol}"}}')
    while True:
        msg = socket.recv()
        data = json.loads(msg)
        if(data["type"] == "ping"):
            socket.send(json.dumps({"type": "ping"}))
            continue

        stock = data["data"][0]["s"]
        prices[stock] = data["data"][0]["p"]
        moneychg[stock] = (prices[stock] - open[stock]) * stocklist[stock]
        if data["type"] != "trade":
            continue
        data = json.dumps({
            "prices": prices,
            "open": open,
            "moneychg": moneychg,
            "shares": stocklist
        })

        if not data: continue
        print(data, flush=True)

