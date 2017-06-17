test: clean test_unit server test_integration clean

test_unit:
	crystal spec ./spec/unit/**

server:
	mkdir -p ./tmp
	crystal build ./spec/support/server.cr -o ./tmp/server
	./tmp/server -p 4567 > ./tmp/server.log & echo $$! > ./tmp/server.pid

test_integration:
	crystal spec ./spec/integration/**

clean:
	[ -e ./tmp/server.pid ] && $$(ps $$(cat ./tmp/server.pid) | grep -q $$(cat ./tmp/server.pid)) && kill $$(cat ./tmp/server.pid) || true
	rm -rf ./tmp
