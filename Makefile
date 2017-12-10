.PHONY: init
init:
	cp dotenv.dist .env
	gem install bundler
	bundle install
	bundle exec rails tmp:create
	mkdir -p log
	bundle exec rails log:clear
	bundle exec rails db:create
	bundle exec rails ridgepole:apply
	bundle exec rails db:seed

.PHONY: run
run:
	bundle exec spring stop
	bundle exec foreman start

.PHONY: test
test:
	bundle exec rails test

.PHONY: db-migrate
db-migrate:
	bundle exec rails ridgepole:apply

.PHONY: db-migrate-production
db-migrate-production:
	bundle exec rails ridgepole:apply RAILS_ENV=production

.PHONY: db-migrate-dry-run
db-migrate-dry-run:
	bundle exec rails ridgepole:dry_run

.PHONY: db-migrate-dry-run-production
db-migrate-dry-run-production:
	bundle exec rails ridgepole:dry_run RAILS_ENV=production

.PHONY: seed
seed:
	bundle exec rails db:seed

.PHONY: db-reset
db-reset:
	bundle exec rails ridgepole:reset
	bundle exec rails db:seed

.PHONY: update-schemafile
update-schemafile:
	bundle exec rails ridgepole:export

.PHONY: annotate
annotate:
	bundle exec annotate
