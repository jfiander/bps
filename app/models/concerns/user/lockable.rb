module User::Lockable
  def locked?
    locked_at.present?
  end

  def lock
    update(locked_at: Time.now)
  end

  def unlock
    update(locked_at: nil)
  end
end
