.PHONY: init
init:
	cp dotenv.dist .env
	gem install bundler
	bundle install
	bundle exec rails db:create
	bundle exec rails tmp:create
	mkdir -p log
	bundle exec rails log:clear

.PHONY: run
run:
	bundle exec spring stop
	bundle exec foreman start

.PHONY: test
test:
	bundle exec rails test

.PHONY: db-migrate
db-migrate:
	bundle exec rake ridgepole:apply

.PHONY: db-migrate-production
db-migrate-production:
	bundle exec rake ridgepole:apply RAILS_ENV=production

.PHONY: db-migrate-dry-run
db-migrate-dry-run:
	bundle exec rake ridgepole:dry_run

.PHONY: db-migrate-dry-run-production
db-migrate-dry-run-production:
	bundle exec rake ridgepole:dry_run RAILS_ENV=production

.PHONY: seed
seed:
	bundle exec rake db:seed

.PHONY: db-reset
db-reset:
	bundle exec rake ridgepole:reset
	bundle exec rake db:seed

.PHONY: update-schemafile
update-schemafile:
	bundle exec rake ridgepole:export

.PHONY: annotate
annotate:
	bundle exec annotate
