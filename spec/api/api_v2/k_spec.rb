# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::K, type: :request do
  describe 'GET /api/v2/k' do
    let(:points) do
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

    before { KlineDB.redis.rpush('peatio:btcusd:k:1', points) }
    after { KlineDB.redis.flushall }

    def load(query = {})
      api_get '/api/v2/k?' + query.merge(market: :btcusd).to_query
      expect(response).to have_http_status 200
    end

    def response_body
      JSON.parse(response.body)
    end

    context 'data exists' do
      it 'without time limits' do
        load
        expect(JSON.parse(response.body)).to eq points[-points_default_limit..-1]
      end

      context 'with time_from' do
        it 'smaller than first point timestamp' do
          load(time_from: first_point.first - 2 * point_period)
          expect(response_body).to eq points[0...points_default_limit - 2]
        end

        it 'bigger than last point timestamp' do
          load(time_from: last_point.first + 2 * point_period)
          expect(response_body).to eq []
        end

        it 'in range of first and last timestamp' do
          time_from = first_point.first + 10 * point_period
          load(time_from: time_from)
          expect(response_body).to eq points[10..-1]
          # First point timestamp should be eq to time_from.
          expect(response_body.first.first).to eq time_from

          time_from = first_point.first + 22 * point_period
          load(time_from: time_from)
          expect(response_body).to eq points[22..-1]
          # First point timestamp should be eq to time_from.
          expect(response_body.first.first).to eq time_from
        end
      end

      context 'with time_to' do
        it 'smaller than first point timestamp' do
          load(time_to: first_point.first - 2 * point_period)
          expect(response_body).to eq []
        end

        it 'bigger than last point timestamp' do
          load(time_to: last_point.first + 2 * point_period)
          # Returns (limit - 2) left points.
          points[(-points_default_limit + 2)..-1]
        end

        it 'in range of first and last timestamp' do
          load(time_to: first_point.first + 1 * point_period)
          expect(response_body).to eq points[0..1]

          load(time_to: first_point.first + 20 * point_period)
          expect(response_body).to eq points[0..20]
        end
      end

      context 'with time_from and time_to' do

        it 'time_to less than time_from' do
          time_from = first_point.first + 2 * point_period
          time_to = first_point.first - 2 * point_period

          load(time_from: time_from, time_to: time_to)
          expect(response_body).to eq []
        end

        it 'both less than first point timestamp' do
          time_from = first_point.first - 10 * point_period
          time_to = first_point.first - 4 * point_period

          load(time_from: time_from, time_to: time_to)
          expect(response_body).to eq []
        end

        it 'both bigger than last point timestamp' do
          time_from = last_point.first + 2 * point_period
          time_to = last_point.first + 12 * point_period

          load(time_from: time_from, time_to: time_to)
          expect(response_body).to eq []
        end

        it 'both in range of first and last timestamp' do
          time_from = first_point.first + 10 * point_period
          time_to = last_point.first - 10 * point_period

          load(time_from: time_from, time_to: time_to)
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
          load(limit: limit)
          expect(response_body).to eq points[-limit..-1]

          limit = 10
          load(limit: limit)
          expect(response_body).to eq points[-limit..-1]
        end

        it 'returns all points if limit greater than points number' do
          limit = points.length + 1
          load(limit: limit)
          expect(response_body).to eq points
        end
      end

      context 'with limits, time_from and time_to' do
        it 'ignores limit' do
          time_from = first_point.first + 1 * point_period
          time_to   = last_point.first - 1 * point_period
          limit     = 5
          load(time_from: time_from, time_to: time_to, limit: limit)

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
          load(time_from: time_from, limit: limit)

          expect(response_body.count).to eq limit
          # Points timestamps should be bigger than time_from and we select first 10.
          expect(response_body).to eq\
            points.select { |p| p.first >= time_from }[0...limit]
          expect(response_body.first.first).to eq time_from
        end
      end
    end

    context 'data is missing' do
      before { KlineDB.redis.flushall }

      it 'without time_from' do
        load
        expect(JSON.parse(response.body)).to eq []
      end

      it 'with time_from' do
        load(time_from: first_point.first)
        expect(JSON.parse(response.body)).to eq []
      end

      it 'with time_from and time_to' do
        load(time_from: first_point.first, time_to: last_point.first)
        expect(JSON.parse(response.body)).to eq []
      end
    end
  end
end
