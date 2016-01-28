class Rank
  RANKS = %w{E-1 E-2 E-3 E-4 E-5 E-6 E-7 E-8 E-9 W-1 W-2 W-3 W-4 W-5 O-1 O-2 O-3 O-4 O-5 O-6 O-7 O-8 O-9 O-10}
  RANKS_WITHOUT_HYPHEN = RANKS.map{|r| r.gsub('-', '')}
  
  def self.all_for_display
    RANKS
  end

  def self.all
    RANKS_WITHOUT_HYPHEN
  end

  def self.combined
    RANKS.zip(RANKS_WITHOUT_HYPHEN)
  end
end