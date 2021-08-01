describe Digibot::Orderbook do
  let(:market)     { 'ethusd' }
  let(:orderbook)  { Digibot::Orderbook.new(market) }

  it 'creates orderbook' do
    orderbook = Digibot::Orderbook.new(market)

    expect(orderbook.book).to include({ sell: ::RBTree.new })
    expect(orderbook.book).to include({ index: ::RBTree.new })
  end

  context 'orderbook#add' do
    let(:order_buy)   { Digibot::Order.new(market, 1, 1, :buy) }
    let(:order_sell)  { Digibot::Order.new(market, 1, 1, :sell) }
    let(:order_sell2) { Digibot::Order.new(market, 1, 1, :sell) }

    it 'adds buy order to orderbook' do
      orderbook.update(order_buy)

      expect(orderbook.book[:buy]).not_to be_nil
      expect(orderbook.book[:buy][order_buy.price]).not_to be_nil
    end

    it 'adds sell order to orderbook' do
      orderbook.update(order_sell)

      expect(orderbook.book[:sell]).not_to be_nil
      expect(orderbook.book[:sell][order_sell.price]).not_to be_nil
    end

    it 'updates order with the same price' do
      orderbook.update(order_sell)
      orderbook.update(order_sell2)

      expect(orderbook.book[:sell][order_sell.price]).to eq(order_sell2.amount)
    end
  end

  context 'orderbook#contains?' do
    let(:order0) { Digibot::Order.new(market, 5, 1, :buy) }
    let(:order1) { Digibot::Order.new(market, 8, 1, :buy) }

    it 'returns true if order is in orderbook' do
      orderbook.update(order0)
      orderbook.update(order1)

      expect(orderbook.contains?(order0)).to equal(true)
      expect(orderbook.contains?(order1)).to equal(true)
    end

    it 'returns false if order is not in orderbook' do
      expect(orderbook.contains?(order0)).to equal(false)
    end
  end

  context 'orderbook#get' do
    let(:order_sell_0)     { Digibot::Order.new('ethusd', 5, 1, :sell) }
    let(:order_sell_1)     { Digibot::Order.new('ethusd', 8, 1, :sell) }
    let(:order_sell_cheap) { Digibot::Order.new('ethusd', 2, 1, :sell) }
    let(:order_buy_0)         { Digibot::Order.new('ethusd', 5, 1, :buy) }
    let(:order_buy_1)         { Digibot::Order.new('ethusd', 8, 1, :buy) }
    let(:order_buy_expensive) { Digibot::Order.new('ethusd', 9, 1, :buy) }

    it 'gets order with the lowest price for sell side' do
      orderbook.update(order_sell_0)
      orderbook.update(order_sell_1)
      orderbook.update(order_sell_cheap)

      expect(orderbook.get(:sell)[0]).to equal(order_sell_cheap.price)
    end

    it 'gets order with the highest price for buy side' do
      orderbook.update(order_buy_0)
      orderbook.update(order_buy_1)
      orderbook.update(order_buy_expensive)

      expect(orderbook.get(:buy)[0]).to equal(order_buy_expensive.price)
    end
  end

  context 'orderbook#remove' do
    let(:order_buy)   { Digibot::Order.new(market, 1, 1, :buy) }

    it 'removes correct order from orderbook' do
      orderbook.update(order_buy)
      orderbook.update(Digibot::Order.new(market, order_buy.price, 1, :buy))
      orderbook.update(Digibot::Order.new(market, 11, 1, :sell))

      orderbook.delete(order_buy)

      expect(orderbook.contains?(order_buy)).to eq(false)
      expect(orderbook.book[:buy][order_buy.price]).to be_nil
      expect(orderbook.book[:sell]).not_to be_nil
    end

    it 'does nothing if non existing id' do
      orderbook.update(order_buy)

      orderbook.delete(Digibot::Order.new(market, 10, 1, :buy))

      expect(orderbook.book[:buy]).not_to be_nil
      expect(orderbook.contains?(order_buy)).to eq(true)
    end
  end

  context 'orderbook#merge' do
    let(:ob1) { Digibot::Orderbook.new(market) }
    let(:ob2) { Digibot::Orderbook.new(market) }
    let(:ob3) { Digibot::Orderbook.new(market) }

    it 'merges two orderbooks into one' do
      ob1.update(Digibot::Order.new(market, 10, 10, :sell))
      ob1.update(Digibot::Order.new(market, 20, 15, :sell))
      ob1.update(Digibot::Order.new(market, 25, 5, :sell))

      ob2.update(Digibot::Order.new(market, 10, 30, :sell))
      ob2.update(Digibot::Order.new(market, 20, 20, :sell))
      ob2.update(Digibot::Order.new(market, 10, 10, :buy))

      ob3.update(Digibot::Order.new(market, 10, 40, :sell))
      ob3.update(Digibot::Order.new(market, 20, 35, :sell))
      ob3.update(Digibot::Order.new(market, 25, 5, :sell))
      ob3.update(Digibot::Order.new(market, 10, 10, :buy))

      ob1.merge!(ob2)

      expect(ob1.book[:index]).to eq(ob3.book[:index])
      expect(ob1.book[:sell]).to eq(ob3.book[:sell])
    end
  end
end
