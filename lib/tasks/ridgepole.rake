# dotenv にて環境変数を読み込んだ上で config/database.yml を読み込みたいので rake タスクにしている
namespace :ridgepole do
  desc "Export schemafile"
  task export: :environment do
    ridgepole("--export", "--output #{schema_file}")
  end

  desc "Apply schemafile"
  task apply: :environment do
    ridgepole("--apply", "--file #{schema_file}")
    Rake::Task["db:schema:dump"].invoke
  end

  desc "Apply schemafile (dry-run)"
  task dry_run: :environment do
    ridgepole("--apply", "--file #{schema_file}", "--dry-run")
  end

  desc "Reset database and apply schemafile"
  task reset: :environment do
    Rake::Task["db:reset"].invoke
    ridgepole("--apply", "--file #{schema_file}")
    Rake::Task["db:schema:dump"].invoke
  end

  private

  def ridgepole(*options)
    command = ["bundle exec ridgepole", "--config #{config_file}"]
    system [command + options].join(" ")
  end

  def schema_file
    Rails.root.join("db/Schemafile")
  end

  def config_file
    Rails.root.join("config/database.yml")
  end
end
