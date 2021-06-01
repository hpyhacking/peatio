# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Public::Markets, type: :request do

  before(:each) { clear_redis }
  describe 'GET /api/v2/markets' do
    before { create(:market, :ethusd) }

    let(:expected_keys) do
      %w[id symbol name type base_unit quote_unit min_price max_price
         min_amount amount_precision price_precision state]
    end

    it 'lists enabled markets' do
      get '/api/v2/public/markets'
      expect(response).to be_successful
      result = JSON.parse(response.body)

      expect(result.size).to eq Market.spot.enabled.size

      result.each do |market|
        expect(market.keys).to contain_exactly(*expected_keys)
      end
    end

    context 'api will return hidden markets' do
      before { create(:market, :btceur, state: :hidden) }
      it 'returns hidden market' do
        get '/api/v2/public/markets'
        expect(response).to be_successful
        result = JSON.parse(response.body)

        expect(result.find { |currency| currency['id'] == 'btceur' }['state']).to eq('hidden')
      end
    end

    context 'pagination' do
      it 'returns paginated markets' do
        get '/api/v2/public/markets', params: { limit: 2 }

        result = JSON.parse(response.body)

        expect(response).to be_successful

        expect(response.headers.fetch('Total').to_i).to eq Market.spot.enabled.size
        expect(result.size).to eq(2)
      end
    end

    context 'filters' do
      context 'base_unit & quote_unit' do
        it 'filters by base_unit' do
          get '/api/v2/public/markets', params: { base_unit: :btc }
          expect(response).to be_successful
          result = JSON.parse(response.body)

          expect(result.size).to eq Market.spot.enabled.where(base_unit: :btc).size
          result.each do |market|
            expect(market['base_unit']).to eq 'btc'
          end
        end

        it 'filters by quote_unit' do
          get '/api/v2/public/markets', params: { quote_unit: :usd }
          expect(response).to be_successful
          result = JSON.parse(response.body)

          expect(result.size).to eq Market.spot.enabled.where(quote_unit: :usd).size
          result.each do |market|
            expect(market['quote_unit']).to eq 'usd'
          end
        end

        it 'does not filter' do
          get '/api/v2/public/markets'
          expect(response).to be_successful
          result = JSON.parse(response.body)

          expect(result.size).to eq Market.spot.enabled.size
        end
      end

      context 'base_code & quote_code' do
        it 'filters by base_code' do
          get '/api/v2/public/markets', params: { search: { base_code: "bt" } }
          # Since we have next markets list:
          # btcusd, btceth, ethusd
          # Since 2 of them has 'bt' in base_unit (btc).
          # We expect them to be returned in API response.
          expect(response).to be_successful
          result = JSON.parse(response.body)

          expect(result.pluck('id')).to contain_exactly('btceth', 'btcusd')
        end

        it 'filters by quote_code' do
          Currency.find(:eur).update(status: :enabled)
          create(:market, :btceur)
          # Since we have next markets list:
          # btceur, btcusd, btceth, ethusd
          # Since 2 of them has 'e' in quote_unit (eur, eth).
          # We expect them to be returned in API response.
          get '/api/v2/public/markets', params: { search: { quote_code: "e" } }
          expect(response).to be_successful
          result = JSON.parse(response.body)

          expect(result.pluck('id')).to contain_exactly('btceth', 'btceur')
        end
      end

      context 'quote_name' do
        before do
          Currency.find(:eur).update(status: :enabled)
          create(:market, :btceur)
          create(:market, :btctrst)
        end

        it 'filters by name 1' do
          # Since we have next markets list:
          # btceur, btcusd, btceth, btctrst, ethusd
          # Since 3 of them has 'E' in quote name (Euro, Ethereum, We Trust).
          # We expect them to be returned in API response.
          get '/api/v2/public/markets', params: { search: { quote_name: 'E' } }
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result.pluck('id')).to contain_exactly('btceth', 'btceur', 'btctrst')
        end

        it 'filters by name 2' do
          # Since we have next markets list:
          # btceur, btcusd, btceth, btctrst, ethusd
          # Since 3 of them has 'uS' in quote name (US Dollar, We Trust).
          # We expect them to be returned in API response.
          get '/api/v2/public/markets', params: { search: { quote_name: 'uS' } }
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result.pluck('id')).to contain_exactly('btcusd', 'btctrst', 'ethusd')
        end
      end

      context 'complex filter' do
        before do
          Currency.find(:eur).update(status: :enabled)
          create(:market, :btceur)
          create(:market, :btctrst)
        end

        it 'filters by base_unit & quote_name or quote_code' do
          # Since we have next markets list:
          # btceur, btcusd, btceth, btctrst, ethusd
          # 1. Filter by base_unit btc: btceur, btcusd, btceth, btctrst
          # 2. Filter by quote_code or quote_name 'et': btceth, btctrst (Ethereum, WeTrust)
          # We expect them to be returned in API response.
          get '/api/v2/public/markets', params: { base_unit: :btc, search: { quote_name: 'et', quote_code: 'et' } }
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result.pluck('id')).to contain_exactly('btceth', 'btctrst')
        end

        it 'filters by base_unit & quote_code' do
          # Since we have next markets list:
          # btceur, btcusd, btceth, btctrst, ethusd
          # 1. Filter by base_unit btc: btceur, btcusd, btceth, btctrst
          # 2. Filter by quote_code 'et': btceth (eth)
          # We expect them to be returned in API response.
          get '/api/v2/public/markets', params: { base_unit: :btc, search: { quote_code: 'et' } }
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result.pluck('id')).to contain_exactly('btceth')
        end
      end
    end
  end

  describe 'GET /api/v2/public/markets/:market/order_book' do
    before do
      create_list(:order_bid, 5, :btcusd)
      create_list(:order_ask, 5, :btcusd)
    end

    let(:market) { :btcusd }

    it 'returns ask and bid orders on specified market' do
      get "/api/v2/public/markets/#{market}/order-book"
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result['asks'].size).to eq 5
      expect(result['bids'].size).to eq 5
    end

    context 'market name with dot' do
      let!(:currency) { create(:currency, :xagm_cx) }
      let!(:market) { create(:market, :xagm_cxusd) }

      it 'returns information about specified market' do
        get "/api/v2/public/markets/#{market.symbol}/order-book"
        expect(response).to be_successful

        result = JSON.parse(response.body)
        expect(result['asks'].size).to eq 0
        expect(result['bids'].size).to eq 0
      end
    end

    it 'returns limited asks and bids' do
      get "/api/v2/public/markets/#{market}/order-book", params: { asks_limit: 1, bids_limit: 1 }
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result['asks'].size).to eq 1
      expect(result['bids'].size).to eq 1
    end

    it 'validates market param' do
      get "/api/v2/public/markets/somecoin/order-book", params: { asks_limit: 1, bids_limit: 1 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('public.market.doesnt_exist')
    end

    it 'validates asks limit' do
      get "/api/v2/public/markets/somecoin/order-book", params: { asks_limit: 201, bids_limit: 1 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('public.order_book.invalid_ask_limit')
    end

    it 'validates bids limit' do
      get "/api/v2/public/markets/somecoin/order-book", params: { asks_limit: 1, bids_limit: 201 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('public.order_book.invalid_bid_limit')
    end
  end

  describe 'GET /api/v2/markets/:market/depth' do
    before do
      create_list(:order_bid, 5, :btcusd)
      create_list(:order_bid, 5, :btcusd, price: 2)
      create_list(:order_ask, 5, :btcusd)
      create_list(:order_ask, 5, :btcusd, price: 3)
    end

    let(:asks) { [["1.0", "5.0"], ["3.0", "5.0"]] }
    let(:bids) { [["2.0", "5.0"], ["1.0", "5.0"]] }

    let(:market) { :btcusd }

    context 'valid market param' do
      it 'sorts asks and bids from highest to lowest' do
        get "/api/v2/public/markets/#{market}/depth"
        expect(response).to be_successful

        result = JSON.parse(response.body)
        expect(result['asks']).to eq asks
        expect(result['bids']).to eq bids
      end
    end

    context 'market name with dot' do
      let!(:currency) { create(:currency, :xagm_cx) }
      let!(:market) { create(:market, :xagm_cxusd) }

      it 'returns information about specified market' do
        get "/api/v2/public/markets/#{market.symbol}/depth"
        expect(response).to be_successful

        result = JSON.parse(response.body)
        expect(result['asks'].size).to eq 0
        expect(result['bids'].size).to eq 0
      end
    end

    context 'invalid market param' do
      it 'validates market param' do
        api_get "/api/v2/public/markets/usdusd/depth"
        expect(response).to have_http_status 422
        expect(response).to include_api_error('public.market.doesnt_exist')
      end
    end
  end

  describe 'GET /api/v2/public/markets/market/k-line' do
    let(:points) do
      # [timestamp, open_price, max_price, min_price, last_price, period_volume]
      [[1537370460, 0.7079, 0.2204, 0.9794, 0.5273, 0.0747],
       [1537370520, 0.6293, 0.5054, 0.2253, 0.1969, 0.7276],
       [1537370580, 0.0939, 0.1949, 0.0032, 0.8328, 0.5895],
       [1537370640, 0.6416, 0.0772, 0.7045, 0.7794, 0.6151],
       [1537370700, 0.0566, 0.6377, 0.3007, 0.6855, 0.6976],
       [1537370760, 0.7868, 0.6465, 0.3207, 0.6428, 0.1771],
       [1537370820, 0.3318, 0.2124, 0.3773, 0.4274, 0.3473],
       [1537370880, 0.0704, 0.4902, 0.5957, 0.5214, 0.3687],
       [1537370940, 0.6629, 0.6585, 0.0756, 0.4559, 0.8554],
       [1537371000, 0.6627, 0.6627, 0.2128, 0.0788, 0.2013],
       [1537371060, 0.5165, 0.0435, 0.5228, 0.6447, 0.9237],
       [1537371120, 0.9311, 0.8886, 0.1605, 0.3223, 0.0211],
       [1537371180, 0.0704, 0.0103, 0.0325, 0.3846, 0.8957],
       [1537371240, 0.1445, 0.6031, 0.9533, 0.0866, 0.4871],
       [1537371300, 0.0974, 0.1344, 0.1533, 0.9029, 0.2009],
       [1537371360, 0.2609, 0.9687, 0.0287, 0.4465, 0.7088],
       [1537371420, 0.5671, 0.0576, 0.6617, 0.1041, 0.4942],
       [1537371480, 0.8355, 0.5336, 0.7419, 0.7062, 0.9562],
       [1537371540, 0.1805, 0.3577, 0.2768, 0.3162, 0.0209],
       [1537371600, 0.7971, 0.1799, 0.8307, 0.5074, 0.0122],
       [1537371660, 0.9491, 0.7448, 0.2019, 0.4662, 0.7035],
       [1537371720, 0.8126, 0.3899, 0.8823, 0.8115, 0.6067],
       [1537371780, 0.2632, 0.6558, 0.7411, 0.3894, 0.1509],
       [1537371840, 0.4274, 0.8187, 0.6661, 0.4331, 0.6335],
       [1537371900, 0.1356, 0.1787, 0.3081, 0.9549, 0.0723],
       [1537371960, 0.1931, 0.9486, 0.2469, 0.2295, 0.9366],
       [1537372020, 0.8323, 0.8168, 0.8453, 0.1278, 0.7975],
       [1537372080, 0.5663, 0.1374, 0.0025, 0.0358, 0.6063],
       [1537372140, 0.9296, 0.5443, 0.2732, 0.6434, 0.9173],
       [1537372200, 0.7292, 0.0367, 0.3569, 0.7876, 0.6626],
       [1537372260, 0.9979, 0.2182, 0.5141, 0.8984, 0.4512],
       [1537372320, 0.4363, 0.4416, 0.2354, 0.6053, 0.7398],
       [1537372380, 0.1815, 0.4969, 0.4091, 0.0798, 0.8797]]
    end
    let(:point_period)         { KLineService::POINT_PERIOD_IN_SECONDS }
    let(:points_default_limit) { 30 }
    let(:last_point)  { points.last }
    let(:first_point) { points.first }

    before { write_to_influx(points) }
    after { delete_measurments("candles_1m") }

    def influx_data(point)
      {
        values:
        {
          open: point[1],
          high: point[2],
          low: point[3],
          close: point[4],
          volume: point[5],
        },
        tags:
        {
          market: 'btcusd'
        },
        timestamp: point[0]
      }
    end

    def write_to_influx(points)
      points.each do |point|
        Peatio::InfluxDB.client(epoch: 's').write_point('candles_1m', influx_data(point), 's')
      end
    end

    def load_k_line(query = {})
      api_get '/api/v2/public/markets/btcusd/k-line?' + query.to_query
      expect(response).to have_http_status 200
    end

    def response_body
      JSON.parse(response.body)
    end

    context 'data exists' do
      it 'without time limits' do
        load_k_line
        expect(JSON.parse(response.body)).to eq points[-points_default_limit..-1]
      end

      context 'with time_from' do
        it 'smaller than first point timestamp' do
          load_k_line(time_from: first_point.first - 2 * point_period)
          expect(response_body).to eq points[0...points_default_limit]
        end

        it 'bigger than last point timestamp' do
          load_k_line(time_from: last_point.first + 2 * point_period)
          expect(response_body).to eq []
        end

        it 'in range of first and last timestamp' do
          time_from = first_point.first + 10 * point_period
          load_k_line(time_from: time_from)
          expect(response_body).to eq points[10..-1]
          # First point timestamp should be eq to time_from.
          expect(response_body.first.first).to eq time_from

          time_from = first_point.first + 22 * point_period
          load_k_line(time_from: time_from)
          expect(response_body).to eq points[22..-1]
          # First point timestamp should be eq to time_from.
          expect(response_body.first.first).to eq time_from
        end
      end

      context 'with time_to' do
        it 'smaller than first point timestamp' do
          load_k_line(time_to: first_point.first - 2 * point_period)
          expect(response_body).to eq []
        end

        it 'bigger than last point timestamp' do
          load_k_line(time_to: last_point.first + 2 * point_period)
          # Returns (limit - 2) left points.
          expect(response_body).to eq points[-points_default_limit..]
        end

        it 'in range of first and last timestamp' do
          load_k_line(time_to: first_point.first + 1 * point_period)
          expect(response_body).to eq points[0..1]

          load_k_line(time_to: first_point.first + 20 * point_period)
          expect(response_body).to eq points[0..20]
        end
      end

      context 'with time_from and time_to' do

        it 'time_to less than time_from' do
          time_from = first_point.first + 2 * point_period
          time_to = first_point.first - 2 * point_period

          load_k_line(time_from: time_from, time_to: time_to)
          expect(response_body).to eq []
        end

        it 'both less than first point timestamp' do
          time_from = first_point.first - 10 * point_period
          time_to = first_point.first - 4 * point_period

          load_k_line(time_from: time_from, time_to: time_to)
          expect(response_body).to eq []
        end

        it 'both bigger than last point timestamp' do
          time_from = last_point.first + 2 * point_period
          time_to = last_point.first + 12 * point_period

          load_k_line(time_from: time_from, time_to: time_to)
          expect(response_body).to eq []
        end

        it 'both in range of first and last timestamp' do
          time_from = first_point.first + 10 * point_period
          time_to = last_point.first - 10 * point_period

          load_k_line(time_from: time_from, time_to: time_to)
          # Points timestamps should be in range time_from..time_to (limit is bigger).
          expect(response_body).to eq\
            points.select { |p| p.first >= time_from && p.first <= time_to }
          expect(response_body.first.first).to eq time_from
          expect(response_body.last.first).to eq time_to
        end
      end

      context 'with limit' do
        it 'returns n last points' do
          limit = 5
          load_k_line(limit: limit)
          expect(response_body).to eq points[-limit..-1]

          limit = 10
          load_k_line(limit: limit)
          expect(response_body).to eq points[-limit..-1]
        end

        it 'returns all points if limit greater than points number' do
          limit = points.length + 1
          load_k_line(limit: limit)
          expect(response_body).to eq points
        end
      end

      context 'with limits, time_from and time_to' do
        it 'ignores limit' do
          time_from = first_point.first + 1 * point_period
          time_to   = last_point.first - 1 * point_period
          limit     = 5
          load_k_line(time_from: time_from, time_to: time_to, limit: limit)

          # All point in time_from..time_to including time_to (time_to - time_from) / 60 + 1.
          expect(response_body.count).to eq (time_to - time_from) / 60 + 1
          # Points timestamps should be in range time_from..time_to.
          expect(response_body).to eq\
            points.select { |p| p.first >= time_from && p.first <= time_to }
          expect(response_body.first.first).to eq time_from
          expect(response_body.last.first).to eq time_to
        end
      end

      context 'with limits and time_from' do
        it 'returns n right points from time_from (adds limit to time_from)' do
          time_from = first_point.first + 5 * point_period
          limit     = 10
          load_k_line(time_from: time_from, limit: limit)

          expect(response_body.count).to eq limit
          # Points timestamps should be bigger than time_from and we select first 10.
          expect(response_body).to eq\
            points.select { |p| p.first >= time_from }[0...limit]
          expect(response_body.first.first).to eq time_from
        end
      end
    end

    context 'data is missing' do
      before { delete_measurments("candles_1m") }

      it 'without time_from' do
        load_k_line
        expect(JSON.parse(response.body)).to eq []
      end

      it 'with time_from' do
        load_k_line(time_from: first_point.first)
        expect(JSON.parse(response.body)).to eq []
      end

      it 'with time_from and time_to' do
        load_k_line(time_from: first_point.first, time_to: last_point.first)
        expect(JSON.parse(response.body)).to eq []
      end
    end
  end

  describe 'GET /api/v2/markets/tickers' do
    after { delete_measurments("trades") }

    context 'no trades executed yet' do
      let(:expected_ticker) do
        { 'low' => '0.0', 'high' => '0.0',
          'open' => '0.0', 'last' => '0.0',
          'volume' => '0.0', 'vol' => '0.0', 'amount' => '0.0',
          'avg_price' => '0.0', 'price_change_percent' => '+0.00%' }
      end

      it 'returns ticker of all markets' do
        get '/api/v2/public/markets/tickers'
        expect(response).to be_successful
        expect(JSON.parse(response.body)['btcusd']['at']).not_to be_nil
        expect(JSON.parse(response.body)['btcusd']['ticker']).to include(expected_ticker)
      end
    end

    context 'single trade was executed' do
      let!(:trade) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d)}
      let(:expected_ticker) do
        { 'low' => '5.0', 'high' => '5.0',
          'open' => '5.0', 'last' => '5.0',
          'volume' => '5.5', 'vol' => '5.5', 'amount' => '1.1',
          'avg_price' => '5.0', 'price_change_percent' => '+0.00%' }
      end
      before do
        trade.write_to_influx
      end

      it 'returns market tickers' do
        get '/api/v2/public/markets/tickers'
        expect(response).to be_successful
        expect(JSON.parse(response.body)['btcusd']['at']).not_to be_nil
        expect(JSON.parse(response.body)['btcusd']['ticker']).to include(expected_ticker)
      end
    end

    context 'multiple trades were executed' do
      let!(:trade1) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d)}
      let!(:trade2) { create(:trade, :btcusd, price: '6.0'.to_d, amount: '0.9'.to_d, total: '5.4'.to_d)}

      let(:expected_ticker) do
        { 'low' => '5.0', 'high' => '6.0',
          'open' => '5.0', 'last' => '6.0',
          'vol' => '10.9', 'volume' => '10.9', 'amount' => '2.0',
          'avg_price' => '5.45', 'price_change_percent' => '+20.00%' }
      end
      before do
        trade1.write_to_influx
        trade2.write_to_influx
      end

      it 'returns market tickers' do
        get '/api/v2/public/markets/tickers'
        expect(response).to be_successful
        expect(JSON.parse(response.body)['btcusd']['at']).not_to be_nil
        expect(JSON.parse(response.body)['btcusd']['ticker']).to include(expected_ticker)
      end
    end
  end

  describe 'GET /api/v2/public/markets/:market/tickers' do
    after { delete_measurments("trades") }
    context 'no trades executed yet' do
      let(:expected_ticker) do
        { 'low' => '0.0', 'high' => '0.0',
          'open' => '0.0', 'last' => '0.0',
          'volume' => '0.0', 'vol' => '0.0', 'amount' => '0.0',
          'avg_price' => '0.0', 'price_change_percent' => '+0.00%'  }
      end

      it 'returns market tickers' do
        get '/api/v2/public/markets/btcusd/tickers'
        expect(response).to be_successful
        expect(JSON.parse(response.body)['ticker']).to include(expected_ticker)
      end

      context 'market name with dot' do
        let!(:currency) { create(:currency, :xagm_cx) }
        let!(:market) { create(:market, :xagm_cxusd) }

        it 'returns information about specified market' do
          get "/api/v2/public/markets/#{market.symbol}/tickers"
          expect(response).to be_successful
          expect(JSON.parse(response.body)['ticker']).to include(expected_ticker)
        end
      end
    end

    context 'single trade was executed' do
      let!(:trade) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d)}
      let(:expected_ticker) do
        { 'low' => '5.0', 'high' => '5.0',
          'open' => '5.0', 'last' => '5.0',
          'volume' => '5.5', 'vol' => '5.5', 'amount' => '1.1',
          'avg_price' => '5.0', 'price_change_percent' => '+0.00%' }
      end
      before do
        trade.write_to_influx
      end

      it 'returns market tickers' do
        get '/api/v2/public/markets/btcusd/tickers'
        expect(response).to be_successful
        expect(JSON.parse(response.body)['ticker']).to include(expected_ticker)
      end
    end

    context 'multiple trades were executed' do
      let!(:trade1) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d)}
      let!(:trade2) { create(:trade, :btcusd, price: '6.0'.to_d, amount: '0.9'.to_d, total: '5.4'.to_d)}

      # open = 6.0 because it takes last by default.
      # to make it work correctly need to run k-line daemon.
      let(:expected_ticker) do
        { 'low' => '5.0', 'high' => '6.0',
          'open' => '5.0', 'last' => '6.0',
          'vol' => '10.9', 'volume' => '10.9', 'amount' => '2.0',
          'avg_price' => '5.45', 'price_change_percent' => '+20.00%' }
      end
      before do
        trade1.write_to_influx
        trade2.write_to_influx
      end

      it 'returns market tickers' do
        get '/api/v2/public/markets/btcusd/tickers'
        expect(response).to be_successful
        expect(JSON.parse(response.body)['ticker']).to include(expected_ticker)
      end
    end
  end

  describe 'GET /api/v2/public/markets/#{market}/trades' do

    let(:member) do
      create(:member, :level_3).tap do |m|
        m.get_account(:btc).update_attributes(balance: 12.13,   locked: 3.14)
        m.get_account(:usd).update_attributes(balance: 2014.47, locked: 0)
      end
    end

    let(:ask) do
      create(
        :order_ask,
        :btcusd,
        price: '12.32'.to_d,
        volume: '123.12345678',
        member: member
      )
    end

    let(:bid) do
      create(
        :order_bid,
        :btcusd,
        price: '12.32'.to_d,
        volume: '123.12345678',
        member: member
      )
    end

    let(:market) { :btcusd }

    let!(:ask_trade) { create(:trade, :btcusd, maker_order: ask, created_at: 2.days.ago) }
    let!(:bid_trade) { create(:trade, :btcusd, taker_order: bid, created_at: 1.day.ago) }


    after do
      delete_measurments('trades')
    end

    before do
      ask_trade.write_to_influx
      bid_trade.write_to_influx
    end

    it 'returns all recent trades' do
      get "/api/v2/public/markets/#{market}/trades"

      expect(response).to be_successful
      expect(JSON.parse(response.body).size).to eq 2
    end

    context 'market name with dot' do
      let!(:currency) { create(:currency, :xagm_cx) }
      let!(:market) { create(:market, :xagm_cxusd) }

      it 'returns information about specified market' do
        get "/api/v2/public/markets/#{market.symbol}/trades"
        expect(response).to be_successful
        expect(JSON.parse(response.body).size).to eq 0
      end
    end

    it 'returns 1 trade' do
      get "/api/v2/public/markets/#{market}/trades", params: {limit: 1}

      expect(response).to be_successful
      expect(JSON.parse(response.body).size).to eq 1
    end

    it 'sorts trades in reverse creation order' do
      get "/api/v2/public/markets/#{market}/trades"

      expect(response).to be_successful
      expect(JSON.parse(response.body).first['id']).to eq bid_trade.id
    end

    it 'gets trades by limit' do
      trade = create(:trade, :btcusd, taker_order: bid, created_at: 6.hours.ago)
      trade.write_to_influx

      get "/api/v2/public/markets/#{market}/trades", params: { limit: 2, order_by: 'asc'}

      expect(response).to be_successful
      expect(JSON.parse(response.body).count).to eq 2

      get "/api/v2/public/markets/#{market}/trades", params: { market: 'btcusd', limit: 3, order_by: 'asc' }

      expect(response).to be_successful
      expect(JSON.parse(response.body).count).to eq 3
    end

    it 'validates market param' do
      api_get "/api/v2/public/markets/usdusd/trades"
      expect(response).to have_http_status 422
      expect(response).to include_api_error('public.market.doesnt_exist')
    end

    it 'validates limit param' do
      get "/api/v2/public/markets/#{market}/trades", params: { limit: 1001 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('public.trade.invalid_limit')
    end
  end
end
