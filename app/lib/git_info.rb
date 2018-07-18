# frozen_string_literal: true

class GitInfo
  MASTER_URL ||= 'https://api.github.com/repos/jfiander/bps/branches/master'
  STAGING_URL ||= 'https://api.github.com/repos/jfiander/bps/branches/staging'
  TAGS_URL ||= 'https://api.github.com/repos/jfiander/bps/tags'

  def local_ref
    return last_tag if ENV['DOMAIN'] == 'www.bpsd9.org'
    return staging_commit if ENV['DOMAIN'] == 'staging.bpsd9.org'
    nil
  end

  def master_commit
    @master_commit ||= shorten(load_json(MASTER_URL)['commit']['sha'])
  end

  def staging_commit
    @staging_commit ||= shorten(load_json(STAGING_URL)['commit']['sha'])
  end

  def last_tag
    @last_tag ||= load_json(TAGS_URL).first['name']
  end

  private

  def load_json(url)
    JSON.parse(open(url).read)
  end

  def shorten(sha)
    sha.truncate(7, omission: '')
  end
end
