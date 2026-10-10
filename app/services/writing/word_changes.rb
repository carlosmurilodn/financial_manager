require "diff/lcs"

module Writing
  class WordChanges
    def self.call(previous, current)
      # Keep case: changing a word is a replacement, unlike formatting changes.
      before = previous.unicode_normalize(:nfc).scan(ManuscriptText::WORD_PATTERN)
      after = current.unicode_normalize(:nfc).scan(ManuscriptText::WORD_PATTERN)
      added = 0
      removed = 0
      Diff::LCS.diff(before, after).each do |changes|
        changes.each do |change|
          added += 1 if change.action == "+"
          removed += 1 if change.action == "-"
        end
      end
      { previous_words: before.size, current_words: after.size, added_words: added, removed_words: removed,
        net_words: added - removed }
    end
  end
end
