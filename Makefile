.PHONY: server

server:
	rails assets:clobber && rails assets:precompile && rails server
