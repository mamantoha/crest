test: test_unit test_integration

test_unit:
	-crystal spec ./spec/unit/**

test_integration:
	mkdir -p ./tmp
	crystal build ./spec/support/server.cr -o ./tmp/server
	./tmp/server -p 4567 > ./tmp/server.log & echo $$! >> ./tmp/server.pid
	-crystal spec ./spec/integration/**
	[ -e ./tmp/server.pid ] && $$(ps $$(cat ./tmp/server.pid) | grep -q $$(cat ./tmp/server.pid)) && kill $$(cat ./tmp/server.pid) || true
	rm -rf ./tmp
