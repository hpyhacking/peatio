module AASM::Locking
  def aasm_write_state(state)
    lock!
    super(state)
  end
end
