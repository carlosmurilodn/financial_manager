module Writing
  class ManuscriptStatistics
    WORDS_PER_MINUTE = 220
    SHORT_PARAGRAPH_MAX = 40
    MEDIUM_PARAGRAPH_MAX = 100
    COMMON_WORDS = %w[a à às ao aos as o os um uma uns umas de da das do dos em no na nos nas
      por para pela pelas pelo pelos com sem sob sobre entre até e ou mas nem que se como quando
      porque pois então enquanto embora é são foi eram era ser estar está estão estava estavam
      tem têm tinha tinham há não sim muito mais menos já ainda também só eu tu ele ela eles elas
      nós vós você vocês me te lhe lhes nos vos meu minha meus minhas seu sua seus suas nosso nossa
      nossos nossas este esta estes estas esse essa esses essas isso isto aquele aquela aqueles
      aquelas aquilo quem qual quais onde tudo todo toda todos todas cada outro outra outros outras].freeze

    attr_reader :chapters, :totals, :paragraph_sizes, :frequencies, :chapter_count, :scene_count

    def initialize(book)
      @paragraph_sizes = []
      @frequencies = Hash.new(0)
      @scene_count = 0
      @chapters = book.writing_chapters.ordered.preload(:writing_scenes).each_with_index.map do |chapter, index|
        scenes = chapter.writing_scenes.sort_by { |scene| [ scene.position, scene.created_at, scene.id ] }
        @scene_count += scenes.size
        documents = scenes.map(&:content)
        # A migrated chapter may retain a copy of a scene; count that legacy copy only once.
        documents.unshift(chapter.content) unless documents.include?(chapter.content)
        text = ManuscriptText.new(documents)
        @paragraph_sizes.concat(text.paragraph_sizes)
        text.words.each { |word| @frequencies[word] += 1 }
        text.metrics.merge(id: chapter.id, title: chapter.title, order: index + 1, scenes: scenes.size)
      end
      @chapter_count = chapters.size
      @totals = %i[words characters characters_without_spaces paragraphs].index_with { |key| chapters.sum { |chapter| chapter[key] } }
    end

    def content_chapter_count
      chapters.count { |chapter| chapter[:characters_without_spaces].positive? }
    end

    def average_words_per_chapter
      content_chapter_count.zero? ? 0 : (totals[:words].to_f / content_chapter_count).round
    end

    def average_words_per_paragraph
      paragraph_sizes.empty? ? 0 : (paragraph_sizes.sum.to_f / paragraph_sizes.size).round(1)
    end

    def reading_minutes
      (totals[:words].to_f / WORDS_PER_MINUTE).ceil
    end

    def paragraph_distribution
      { short: paragraph_sizes.count { |size| size <= SHORT_PARAGRAPH_MAX },
        medium: paragraph_sizes.count { |size| size > SHORT_PARAGRAPH_MAX && size <= MEDIUM_PARAGRAPH_MAX },
        long: paragraph_sizes.count { |size| size > MEDIUM_PARAGRAPH_MAX } }
    end

    def frequent_words(include_common: false, limit: 30)
      frequencies.reject { |word, _count| !include_common && COMMON_WORDS.include?(word) }
        .sort_by { |word, count| [ -count, word ] }.first(limit)
    end
  end
end
