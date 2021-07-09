# frozen_string_literal: true

# RankChart.new.only_with_rank.sort_by_rank.print
# RankChart.new.only_with_rank.sort_by_name.print
# RankChart.new.all_by_name.print
class RankChart
  def self.print(users = nil)
    new(users).print
  end

  def initialize(users = nil)
    @users = users || User.unlocked
  end

  def print
    puts "Lists all candidate ranks for the specified users."
    puts "  If no users are specified, shows users with a rank_override.\n\n"
    puts "*Auto* chooses the highest priority rank shown to its right.\n\n"
    puts headers, ranks
  end

  def all_by_name
    @users = User.unlocked.order(:last_name, :first_name)
    self
  end

  def only_with_rank
    @users = User.unlocked.select(&:auto_rank)
    self
  end

  def sort_by_rank
    priority = @users.first.send(:rank_priority)
    @users = @users.sort_by { |user| priority[user.auto_rank(html: false)] }
    self
  end

  def sort_by_name
    @users = @users.sort_by { |u| [u.last_name, u.first_name] }
    self
  end

private

  def headers
    [
      'Name'.ljust(30, ' '),
      %w[Imported Override *Auto* Database Bridge Committee].map { |r| r.to_s.ljust(10, ' ') }
    ].flatten.join("\t")
  end

  def ranks
    @users.map do |u|
      [
        u.simple_name.ljust(30, ' '),
        [
          u.rank,
          u.rank_override,
          u.auto_rank(html: false),
          u.send(:override_rank, html: false),
          u.send(:bridge_rank, html: false),
          u.send(:committee_rank)
        ].map { |r| r.to_s.ljust(10, ' ') }
      ].flatten.join("\t")
    end
  end

  def users_with_override
    User.unlocked.where.not(rank_override: nil)
  end
end
