# frozen_string_literal: true

class GitInfo
  MASTER_URL ||= 'https://api.github.com/repos/jfiander/bps/branches/master'
  STAGING_URL ||= 'https://api.github.com/repos/jfiander/bps/branches/staging'
  TAGS_URL ||= 'https://api.github.com/repos/jfiander/bps/tags'

  def local_ref
    return last_tag if ENV['DOMAIN'] == 'www.bpsd9.org'
    return staging_commit if ENV['DOMAIN'] == 'staging.bpsd9.org'

    local_commit
  rescue StandardError
    nil
  end

  def master_commit
    @master_commit ||= shorten(load_json(MASTER_URL)['commit']['sha'])
  end

  def staging_commit
    @staging_commit ||= shorten(load_json(STAGING_URL)['commit']['sha'])
  end

  def local_commit
    @local_commit ||= shorten(`git rev-parse HEAD`)
  end

  def last_tag
    @last_tag ||= load_json(TAGS_URL).first['name']
  end

  def master_time
    @master_time ||= Time.strptime(
      load_json(MASTER_URL)['commit']['commit']['author']['date'],
      '%Y-%m-%dT%H:%M:%S%Z'
    )
  end

private

  def load_json(url)
    JSON.parse(URI.parse(url).open.read)
  end

  def shorten(sha)
    sha.truncate(7, omission: '')
  end
end
