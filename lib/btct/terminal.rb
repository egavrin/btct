require 'curses'

require 'btct/bitstamp'
require 'btct/therock'
require 'btct/campbx'
require 'btct/mtgox'
require 'btct/btce'

module BTCT
  class Terminal
    def initialize(argv)
    end
 
    def run
      sources = [
        BitstampAPI.new,
        BtceAPI.new,
        CampBxAPI.new,
        MtGoxAPI.new,
        TheRockAPI.new
      ]
      begin
        def onsig(sig)
          Curses.close_screen
          exit sig
        end
        for i in %w[HUP INT QUIT TERM]
          if trap(i, "SIG_IGN") != 0 then  # 0 for SIG_IGN
            trap(i) {|sig| onsig(sig) }
          end
        end
        Curses.init_screen
        Curses.nl
        Curses.noecho
        Curses.setpos(0,  0) ; Curses.addstr "BTC/USD"
        Curses.setpos(0, 21) ; Curses.addstr "Bid"
        Curses.setpos(0, 46) ; Curses.addstr "Ask"
        Curses.setpos(1, 14) ; Curses.addstr "Amount       Price"
        Curses.setpos(1, 39) ; Curses.addstr "Price      Amount"
        Curses.refresh
        while true
          bids = Array.new
          asks = Array.new
          sources.each do |source|
            bid, ask = source.top
            bids.push(bid)
            asks.push(ask)
          end
          bids.sort! { |x,y| y.price <=> x.price }
          asks.sort! { |x,y| x.price <=> y.price }
          row = 2
          bids.zip(asks).each do |bid, ask|
            text = "%-10s %10.6f %12.6f  %-12.6f %-10.6f %-10s" % [bid.exchange, bid.amount, bid.price, ask.price, ask.amount, ask.exchange]
            Curses.setpos(row, 0) ; Curses.addstr text
            row = row + 1
          end
          Curses.refresh
          sleep 5
        end
      ensure
        Curses.close_screen
      end
    end
  end
end
