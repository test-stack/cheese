build:
	git add package.json && \
	git commit -m "update package.json" && \
	git push origin master && \
	npm publish
