PORT=5000
AgentFIX.session_defaults.merge! BeginString: "FIX.4.2", SocketAcceptPort: PORT, SocketConnectPort: PORT, SocketConnectHost: "localhost"

AgentFIX.define_acceptor :my_acceptor do |a|
  a.default ={SenderCompID: "TW"}
  a.session ={TargetCompID: "ARCA"}
end

AgentFIX.define_initiator :my_initiator do |i|
  i.default ={SenderCompID: "ARCA"}
  i.session ={TargetCompID:  "TW"}
end
