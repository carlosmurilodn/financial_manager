class ConvertChapterTextsToScenes < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      WITH converted AS (
        INSERT INTO writing_scenes
          (writing_book_id, writing_chapter_id, title, content, document_version, position, lock_version, created_at, updated_at)
        SELECT chapter.writing_book_id, chapter.id, 'Texto inicial', chapter.content,
          chapter.document_version,
          COALESCE((SELECT MIN(scene.position) FROM writing_scenes scene WHERE scene.writing_chapter_id = chapter.id), 0) - 1,
          0, chapter.created_at, chapter.updated_at
        FROM writing_chapters chapter
        WHERE jsonb_path_exists(chapter.content, '$.** ? (@.type == "text" && @.text != "")')
          OR jsonb_path_exists(chapter.content, '$.** ? (@.type == "horizontalRule" || @.type == "hardBreak")')
        RETURNING writing_chapter_id
      )
      UPDATE writing_chapters chapter
      SET content = '{"type":"doc","content":[{"type":"paragraph","attrs":{"textAlign":"left","firstLineIndent":true}}]}'::jsonb,
        lock_version = chapter.lock_version + 1
      FROM converted
      WHERE chapter.id = converted.writing_chapter_id
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Os textos convertidos podem ter sido editados como cenas."
  end
end
