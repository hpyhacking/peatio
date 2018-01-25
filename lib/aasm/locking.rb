module AASM::Locking
  def aasm_write_state(*)
    lock!
    super
  end
end
