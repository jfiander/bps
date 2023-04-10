# frozen_string_literal: true

module Ordered
  def order_sql_path
    Rails.root.join("app/models/concerns/#{name.underscore}/order.sql")
  end

  def order_sql
    File.read(order_sql_path)
  end

  def ordered
    order(Arel.sql(order_sql))
  end
end
