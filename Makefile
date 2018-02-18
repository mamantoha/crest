.PHONY: test
test: test_unit server test_integration clean

.PHONY: test_unit
test_unit:
	crystal spec ./spec/unit/**

.PHONY: server
server:
	mkdir -p ./tmp
	crystal build ./spec/support/server.cr -o ./tmp/server
	./tmp/server -p 4567 > ./tmp/server.log & echo $$! > ./tmp/server.pid

.PHONY: test_integration
test_integration:
	crystal spec ./spec/integration/**

.PHONY: clean
clean: stop_server
	rm -rf ./tmp

.PHONY: stop_server
stop_server:
	kill $$(ps aux | grep '/tmp/server -p 4567' | grep -v grep | awk '{print $$2}') || true
