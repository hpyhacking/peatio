# frozen_string_literal: true

module API
	module V2
		module Market
			class Mount < Grape::API
				mount Market::Orders
				mount Market::Trades
			end
		end
	end
end
