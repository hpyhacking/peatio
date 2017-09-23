##needed login (action) and wallet , trades , market levels , orders (objects)
require 'quickfix_ruby'

class Application < Quickfix::Application

	def initialize
		super
		@orderID = 0
		@execID = 0
	end

	def onCreate(sessionID)
	end

	def onLogon(sessionID)
        ###
        ### PEATIO TODO
        ###
	end

	def onLogout(sessionID)
	end

	def toAdmin(sessionID, message)
	end

	def fromAdmin(sessionID, message)
	end

	def toApp(sessionID, message)
	end

	def fromApp(message, sessionID)

		beginString = Quickfix::BeginString.new
		msgType = Quickfix::MsgType.new
		message.getHeader().getField( beginString )
		message.getHeader().getField( msgType )

		symbol = Quickfix::Symbol.new
		side = Quickfix::Side.new
		ordType = Quickfix::OrdType.new
		orderQty = Quickfix::OrderQty.new
		price = Quickfix::Price.new
		clOrdID = Quickfix::ClOrdID.new
		avgPx = Quickfix::AvgPx.new

		message.getField( ordType )

		if( ordType.getValue() != Quickfix.OrdType_LIMIT )
			raise Quickfix::IncorrectTagValue.new( ordType.getField() )
		end

		message.getField( symbol )
		message.getField( side )
		message.getField( orderQty )
		message.getField( price )
		message.getField( clOrdID )

		executionReport = Quickfix::Message.new
		executionReport.getHeader().setField( beginString )
		executionReport.getHeader().setField( Quickfix::MsgType.new(Quickfix.MsgType_ExecutionReport) )

		executionReport.setField( Quickfix::OrderID.new(genOrderID()) )
		executionReport.setField( Quickfix::ExecID.new(genExecID()) )
		executionReport.setField( Quickfix::OrdStatus.new(Quickfix.OrdStatus_FILLED) )
		executionReport.setField( symbol )
		executionReport.setField( side )
		executionReport.setField( Quickfix::CumQty.new(orderQty.getValue()) )
		executionReport.setField( Quickfix::AvgPx.new(price.getValue()) )
		executionReport.setField( Quickfix::LastShares.new(orderQty.getValue()) )
		executionReport.setField( Quickfix::LastPx.new(price.getValue()) )
		executionReport.setField( clOrdID )
		executionReport.setField( orderQty )

		if( beginString.getValue() == Quickfix.BeginString_FIX40 || beginString.getValue() == Quickfix.BeginString_FIX41 || beginString.getValue() == Quickfix.BeginString_FIX42 )
			executionReport.setField( Quickfix::ExecTransType.new(Quickfix.ExecTransType_NEW) )
		end

		if( beginString.getValue() >= Quickfix.BeginString_FIX41 )
			executionReport.setField( Quickfix::ExecType.new(Quickfix.ExecType_FILL) )
			executionReport.setField( Quickfix::LeavesQty.new(0) )
		end

		begin
			Quickfix::Session.sendToTarget( executionReport, sessionID )
		rescue SessionNotFound
			return
		end
	end

	def genOrderID
		@orderID = @orderID+1
		return @orderID.to_s
	end

	def genExecID
		@execID = @execID+1
		return @execID.to_s
	end
end

begin
	file = ARGV[0]
	settings = Quickfix::SessionSettings.new( file )
	application = Application.new
	storeFactory = Quickfix::FileStoreFactory.new( settings )
	logFactory = Quickfix::ScreenLogFactory.new( settings )
	acceptor = Quickfix::SocketAcceptor.new( application, storeFactory, settings, logFactory )
        acceptor.start

	while( true )
		sleep(1)
	end
rescue Quickfix::ConfigError, Quickfix::RuntimeError => e
	print e
end
